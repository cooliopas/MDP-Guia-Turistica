
//  TransporteEstacionarTarjetaMapaViewController.swift
//  GT1
//
//  Created by Pablo Pasqualino on 3/26/15.
//  Copyright (c) 2015 Pablo Pasqualino. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class TransporteEstacionarTarjetaMapaViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, SWRevealViewControllerDelegate {

	@IBOutlet weak var mapaView: MKMapView!
	@IBOutlet weak var sinUbicacionLabel: UILabel!
	@IBOutlet weak var statusLabel: UILabel!

	var linea: String!
	
	let locationManager = CLLocationManager()
	
	var ubicacionActual: CLLocation?
	
	let mapManager = MapManager()
	
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
			
				mapaView.setRegion(MKCoordinateRegionMake(CLLocationCoordinate2DMake(-38.000125, -57.549382), MKCoordinateSpanMake(0.01, 0.01)), animated: false)
				
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

		UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
			
			self.statusLabel.alpha = 0
			
			}, completion: nil)
		
		if ubicacionActual == nil || ubicacionActual!.distanceFromLocation(userLocation.location) > 100 {
			
			ubicacionActual = userLocation.location

			mostrarPuestos(ubicacionActual!.coordinate)

		}
		
	}
	
	func mostrarPuestos(coordenadas: CLLocationCoordinate2D) {
		
		statusLabel.text = "Cargando datos ..."
		
		UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
			
			self.statusLabel.alpha = 1
			
			}, completion: nil)
		
		let parametros = [["latitud":"\(coordenadas.latitude)"],["longitud":"\(coordenadas.longitude)"]]
		soapea("latlong_puestomedido", parametros) { (respuesta, error) in
			
			UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
				
				self.statusLabel.alpha = 0
				
				}, completion: nil)
			
			if error == nil {

				var arrayNuevosPuestos: [String] = []
				
				for puesto in respuesta {
					
					let latitud = (puesto["codigo"]!.componentsSeparatedByString(",")[0] as NSString).doubleValue
					let longitud = (puesto["codigo"]!.componentsSeparatedByString(",")[1] as NSString).doubleValue
					
					arrayNuevosPuestos.append("\(latitud),\(longitud)")
					
				}

				for annotation in self.mapaView.annotations {
					
					if let anotacion = annotation as? MKPointAnnotation {
						
						let latitud = anotacion.coordinate.latitude
						let longitud = anotacion.coordinate.longitude
						let stringCoordenadas = "\(latitud),\(longitud)"
						
						if !contains(arrayNuevosPuestos,stringCoordenadas) {
						
							self.mapaView.removeAnnotation(anotacion)
							
						} else {

							if let indexPuesto = find(arrayNuevosPuestos,stringCoordenadas) {

								arrayNuevosPuestos.removeAtIndex(indexPuesto)
								
							}
							
						}
						
					}
					
				}

				for puesto in arrayNuevosPuestos {
					
					let latitud = (puesto.componentsSeparatedByString(",")[0] as NSString).doubleValue
					let longitud = (puesto.componentsSeparatedByString(",")[1] as NSString).doubleValue
					
					let annotation = MKPointAnnotation()
					annotation.coordinate = CLLocationCoordinate2DMake(latitud,longitud)
					annotation.title = "Punto de venta"
					
					self.mapaView.addAnnotation(annotation)
					
				}
				
			} else {
				
				self.muestraError("No se encontraron puntos de venta de estacionamiento medido.",volver: 1)
//				println(error)
				
			}
			
		}
		
		if !actualizoRegion {
		
			mapaView.setRegion(MKCoordinateRegionMake(coordenadas, MKCoordinateSpanMake(0.007, 0.007)), animated: true)
			actualizoRegion = true
			
		}

	}
	
	func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
		
		if annotation is MKUserLocation {
			
			return nil
			
		} else {
			
			let identificador = "puestos"
			let imagen = UIImage(named: "estacionamiento")
			let centerOffset: CGFloat = 15
			
			var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identificador)
			
			if annotationView != nil {
				
				annotationView.annotation = annotation
				
			} else {
				
				annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identificador)
				
			}
			
			annotationView.canShowCallout = true
			annotationView.image = imagen
			annotationView.centerOffset = CGPointMake(centerOffset, 0)
			
			return annotationView
			
		}
		
	}
	
	deinit {
//		println("deinit")
	}
		
	func alertaLocalizacion() {
		
		mostrarPuestos(CLLocationCoordinate2DMake(-37.995816,-57.552115))

		UIView.animateWithDuration(0.4, delay: 0, options: .CurveEaseOut, animations: {
			
			self.sinUbicacionLabel.alpha = 1
			
			}, completion: nil)
		
		var alertController = UIAlertController (title: "Acceso a la localización", message: "Para mostrar los puestos de carga más cercanos a tu ubicación, es necesario que permitas el acceso a la localización desde esta aplicación.\n\nPodes permitir el acceso desde \"Ajustes\".", preferredStyle: .Alert)
		
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
			
			UIView.animateWithDuration(0.4, delay: 0, options: .CurveEaseOut, animations: {
				
				self.sinUbicacionLabel.alpha = 0
				self.statusLabel.alpha = 1
				
				}, completion: nil)
			
			mapaView.showsUserLocation = true
			
		} else {
			
			locationManager.requestWhenInUseAuthorization()
			
		}
		
	}
	
	override func viewDidDisappear(animated: Bool) {
		
		super.viewDidDisappear(animated)
		
		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		appDelegate.arrayVC.removeValueForKey("transporteEstacionarTarjetaMapa")
		
		locationManager.stopUpdatingLocation()
		locationManager.delegate = nil

		mapaView.delegate = nil
		
		self.removeFromParentViewController()
		
	}

}