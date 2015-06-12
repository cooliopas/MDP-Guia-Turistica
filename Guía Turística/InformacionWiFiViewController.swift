//  InformacionWiFiViewController.swift
//  GT1
//
//  Created by Pablo Pasqualino on 3/26/15.
//  Copyright (c) 2015 Pablo Pasqualino. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class InformacionWiFiViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, SWRevealViewControllerDelegate {
	
	@IBOutlet weak var mapaView: MKMapView!
	@IBOutlet weak var statusLabel: UILabel!
	@IBOutlet weak var sinUbicacionLabel: UILabel!

	let locationManager = CLLocationManager()
	
	var ubicacionActual: CLLocation?
	
	var actualizoRegion = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if hayRed() {
			
			locationManager.delegate = self

			if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse {
				mapaView.showsUserLocation = true
			}

			mapaView.delegate = self
			
			if !actualizoRegion {
				
				mapaView.setRegion(MKCoordinateRegionMake(CLLocationCoordinate2DMake(-37.992820,-57.583932), MKCoordinateSpanMake(0.05, 0.05)), animated: false)
				
			}

		}
			
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		armaNavegacion()
		self.revealViewController().delegate = self
		
	}
	
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if !hayRed() {
            
            muestraError("No se detecta conección a Internet.\nNo es posible continuar.", volver: 1)
            
        }
        
    }
    
	func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
		
		if ubicacionActual == nil || ubicacionActual!.distanceFromLocation(userLocation.location) > 1000 {
			
			statusLabel.text = "Cargando datos ..."
			
			let parametros = [["latitud":"\(userLocation.coordinate.latitude)"],["longitud":"\(userLocation.coordinate.longitude)"],["distanciamaxima":"100"],["cantidadmaxima":"100"]]
			soapea("wifi_mgp", parametros) { (respuesta, error) in
				
				UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut | .BeginFromCurrentState, animations: {
					
					self.statusLabel.alpha = 0
					
					}, completion: nil)
				
				if error == nil {
					
					for wifi in respuesta {
						
						let annotation = MKPointAnnotation()
						annotation.coordinate = CLLocationCoordinate2DMake((wifi["latitud"]! as NSString).doubleValue,(wifi["longitud"]! as NSString).doubleValue)
						let nombre = "WiFi Público"
						let direccion = wifi["descripcion"]!
						
						annotation.title = nombre
						annotation.subtitle = direccion
						
						self.mapaView.addAnnotation(annotation)
						
					}
	
				} else {
					
					self.muestraError("No se encontraron los puntos de WiFi Público.",volver: 1)
//					println(error)
					
				}
				
			}

		}
		
		if !actualizoRegion {
			
			mapaView.setRegion(MKCoordinateRegionMake(userLocation.coordinate, MKCoordinateSpanMake(0.03, 0.03)), animated: true)
			actualizoRegion = true
			
		}
		
		ubicacionActual = userLocation.location
		
	}
	
	func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
		
		if annotation is MKUserLocation {
			
			return nil
			
		} else {
			
			let identificador = "wifi"
			let imagen = UIImage(named: "wifi")
			
			var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identificador)
			
			if annotationView != nil {
				
				annotationView.annotation = annotation
				
			} else {
				
				annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identificador)
				
			}
			
			annotationView.canShowCallout = true
			annotationView.image = imagen
			annotationView.centerOffset = CGPointMake(0, -12)
			
			return annotationView
			
		}
		
	}
	
	deinit {
//		println("deinit")
	}
	
	func alertaLocalizacion() {
		
		UIView.animateWithDuration(0.4, delay: 0, options: .CurveEaseOut, animations: {
			
			self.sinUbicacionLabel.alpha = 1
			
			}, completion: nil)
		
		var alertController = UIAlertController (title: "Acceso a la localización", message: "Para mostrar los puntos de WiFi Público más cercanos a tu ubicación, es necesario que permitas el acceso a la localización desde esta aplicación.\n\nPodes permitir el acceso desde \"Ajustes\".", preferredStyle: .Alert)
		
		var settingsAction = UIAlertAction(title: "Ir a Ajustes", style: .Default) { (_) -> Void in
			let settingsUrl = NSURL(string: UIApplicationOpenSettingsURLString)
			if let url = settingsUrl {
				UIApplication.sharedApplication().openURL(url)
			}
		}
		
		var cancelAction = UIAlertAction(title: "Ignorar", style: .Default, handler: nil)
		alertController.addAction(settingsAction)
		alertController.addAction(cancelAction)
		
		presentViewController(alertController, animated: true, completion: nil);
		
	}
	
	func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
		
		var autorizado = false
		var autorizacionStatus = ""
		
		switch status {
		case CLAuthorizationStatus.Restricted:
			autorizacionStatus = "Restringido"
			alertaLocalizacion()
		case CLAuthorizationStatus.Denied:
			autorizacionStatus = "Denegado"
			alertaLocalizacion()
		case CLAuthorizationStatus.NotDetermined:
			autorizacionStatus = "No determinado aún"
		default:
			autorizacionStatus = "Permitido"
			autorizado = true
		}
				
		if autorizado == true {
			
			UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
				
				self.statusLabel.alpha = 1
				self.sinUbicacionLabel.alpha = 0
				
				}, completion: nil)
			
			mapaView.showsUserLocation = true
			
		} else {
			
			locationManager.requestWhenInUseAuthorization()
			
		}
		
	}
	
	override func viewDidDisappear(animated: Bool) {
		
		super.viewDidDisappear(animated)
				
		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		appDelegate.arrayVC.removeValueForKey("informacionWiFi")
		
		locationManager.stopUpdatingLocation()
		locationManager.delegate = nil
		mapaView.delegate = nil
		
		self.removeFromParentViewController()
		
	}
	
}