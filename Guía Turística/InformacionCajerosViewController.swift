//  InformacionCajerosViewController.swift
//  GT1
//
//  Created by Pablo Pasqualino on 3/26/15.
//  Copyright (c) 2015 Pablo Pasqualino. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import SwiftyJSON
import Alamofire

class InformacionCajerosViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, SWRevealViewControllerDelegate {
	
	@IBOutlet weak var mapaView: MKMapView!
	@IBOutlet weak var segmentadorTipo: UISegmentedControl!
	
	@IBOutlet weak var statusLabel: UILabel!
	
	var linea: String!
	
	let locationManager = CLLocationManager()
	
	var ubicacionActual: CLLocation?
	
	let mapManager = MapManager()
	
	var cajeros: [Cajero] = []
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if hayRed() {
		
			locationManager.delegate = self
			
			if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse {
				mapaView.showsUserLocation = true
			}
			
			mapaView.delegate = self

			// leemos todas los cajeros
			
			if let file = NSBundle.mainBundle().pathForResource("Varios.bundle/cajeros", ofType: "json"),
				let data = NSData(contentsOfFile: file),
				let listadoCajeros = JSON(data:data).array {
					
					for cajero in listadoCajeros {
						
						cajeros.append(Cajero(coordenadas: CLLocationCoordinate2DMake(cajero[0].doubleValue,cajero[1].doubleValue), banco: cajero[2].stringValue, direccion: cajero[3].stringValue,tipo: cajero[4].intValue))
						
					}
					
			}
			
			mapaView.setRegion(MKCoordinateRegionMake(CLLocationCoordinate2DMake(-37.995526,-57.552260), MKCoordinateSpanMake(0.005, 0.005)), animated: false)
			mostrarCajeros(segmentadorTipo.selectedSegmentIndex)
			
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
    
	func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
		
		if annotation is MKUserLocation {
			
			return nil
			
		} else {

			var cajeroId = ""

			if annotation.title!.rangeOfString("Cajero Link") != nil {

				cajeroId = "cajeroLink"

			} else {

				cajeroId = "cajeroBanelco"

			}

			var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(cajeroId)
			
			if annotationView != nil {
				
				annotationView.annotation = annotation
				
			} else {
				
				annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: cajeroId)
				
			}
			
			annotationView.canShowCallout = true
			annotationView.image = UIImage(named: cajeroId)
			annotationView.centerOffset = CGPointMake(-5, -21)
			
			return annotationView
			
		}
		
	}
	
	@IBAction func mostrarCajerosActualiza() {
		
		if segmentadorTipo.selectedSegmentIndex == 0 && ubicacionActual == nil {
			
			if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse {
				
				UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
					
					self.statusLabel.alpha = 1
					
					}, completion: nil)
				
			} else {
				
				segmentadorTipo.selectedSegmentIndex = 1
				alertaLocalizacion()
				
			}
			
		} else {

			UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
				
				self.statusLabel.alpha = 0
				
				}, completion: nil)
			
			mostrarCajeros(segmentadorTipo.selectedSegmentIndex)
			
			if segmentadorTipo.selectedSegmentIndex == 0 {
				
                var arrayCoordenadasAnnotations = [CLLocationCoordinate2D]()
                
                if ubicacionActual != nil {
                    
                    arrayCoordenadasAnnotations.append(ubicacionActual!.coordinate)
                    
                }
                
                for annotation in self.mapaView.annotations {
                    
                    if let annotation = annotation as? MKPointAnnotation {
                        
                        arrayCoordenadasAnnotations.append(annotation.coordinate)
                        
                    }
                    
                }
                
                mapaView.setRegion(regionIncluyendoCoordenadas(arrayCoordenadasAnnotations), animated: true)
                
			}
			
		}
		
	}
	
    func regionIncluyendoCoordenadas(puntos: [CLLocationCoordinate2D]) -> MKCoordinateRegion {
        
        var minLat = 90.0
        var maxLat = -90.0
        var minLon = 180.0
        var maxLon = -180.0
        
        for punto in puntos {
            
            if punto.latitude < minLat { minLat = punto.latitude }
            if punto.latitude > maxLat { maxLat = punto.latitude }
            if punto.longitude < minLon { minLon = punto.longitude }
            if punto.longitude > maxLon { maxLon = punto.longitude }
            
        }
        
        let center = CLLocationCoordinate2DMake((minLat+maxLat)/2.0, (minLon+maxLon)/2.0)
        let span = MKCoordinateSpanMake(maxLat-minLat + 0.01, maxLon-minLon + 0.01);
        let region = MKCoordinateRegionMake (center, span);
        
        return region
        
    }
    
	func sorterForDistancia(this:Cajero, that:Cajero) -> Bool {
		if this.distancia == nil {
			return false
		} else if that.distancia == nil {
			return true
		} else {
			return this.distancia! < that.distancia!
		}
	}
	
	func mostrarCajeros(tipo: Int) {
		
		for annotation in mapaView.annotations {
			
			if annotation is MKAnnotation {
				
				mapaView.removeAnnotation(annotation as! MKAnnotation)
				
			}
			
		}
		
		if tipo == 0 && ubicacionActual != nil { cajeros.sort(sorterForDistancia) }
		
		var cajerosMostrados = 0
		
		for cajero in cajeros {
			
			let annotation = MKPointAnnotation()
			annotation.coordinate = cajero.coordenadas
			annotation.title = (cajero.tipo == 0 ? "Cajero Banelco" : "Cajero Link") + " - " + cajero.banco
			annotation.subtitle = cajero.direccion
			
			mapaView.addAnnotation(annotation)
			
			cajerosMostrados++
			
			if tipo == 0 && cajerosMostrados == 10 { break }

		}
		
	}
	
	func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
		
		if ubicacionActual == nil || ubicacionActual!.distanceFromLocation(userLocation.location) > 100 {
			
			if ubicacionActual == nil {
				
				mapaView.setRegion(MKCoordinateRegionMake(userLocation.coordinate, MKCoordinateSpanMake(0.04, 0.04)), animated: true)
				
			}
			
			ubicacionActual = userLocation.location
			
			for cajero in cajeros {
				
				cajero.distancia = ubicacionActual!.distanceFromLocation(CLLocation(latitude: cajero.coordenadas.latitude,longitude: cajero.coordenadas.longitude))
				
			}
			
			if segmentadorTipo.selectedSegmentIndex == 0 {
			
				mostrarCajeros(segmentadorTipo.selectedSegmentIndex)
				
			}
			
		}
		
		if statusLabel.alpha == 1 {
			
			UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
				
				self.statusLabel.alpha = 0
				
				}, completion: nil)
			
		}
		
	}
	
	deinit {
//		println("deinit")
	}
	
	func alertaLocalizacion() {
		
		var alertController = UIAlertController (title: "Acceso a la localización", message: "Para mostrar los cajeros automáticos más cercanos a tu ubicación, es necesario que permitas el acceso a la localización desde esta aplicación.\n\nPodes permitir el acceso desde \"Ajustes\".", preferredStyle: .Alert)
		
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
		
		if status == CLAuthorizationStatus.AuthorizedWhenInUse {
			mapaView.showsUserLocation = true
		} else {
			locationManager.requestWhenInUseAuthorization()
		}
		
	}
	
	override func viewDidDisappear(animated: Bool) {
		
		super.viewDidDisappear(animated)
				
		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		appDelegate.arrayVC.removeValueForKey("informacionCajeros")
		
		locationManager.stopUpdatingLocation()
		locationManager.delegate = nil
		mapaView.delegate = nil
		
		self.removeFromParentViewController()
		
	}
	
}