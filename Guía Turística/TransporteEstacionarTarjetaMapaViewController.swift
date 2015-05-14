
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

	var linea: String!
	
	let locationManager = CLLocationManager()
	
	var ubicacionActual: CLLocationCoordinate2D?
	
	let mapManager = MapManager()
	
	var actualizoRegion = false

    override func viewDidLoad() {
        super.viewDidLoad()

		if CLLocationManager.authorizationStatus() == .NotDetermined {
			locationManager.requestWhenInUseAuthorization()
		}

		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyBest

		mapaView.showsUserLocation = true
		mapaView.delegate = self
		
		if !actualizoRegion {
		
			mapaView.setRegion(MKCoordinateRegionMake(CLLocationCoordinate2DMake(-38.000125, -57.549382), MKCoordinateSpanMake(0.01, 0.01)), animated: false)
			
		}

	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		armaNavegacion()
		self.revealViewController().delegate = self
		
	}
	
	func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
		
		ubicacionActual = userLocation.coordinate
		
		if !actualizoRegion {

			let parametros = [["latitud":"\(ubicacionActual!.latitude)"],["longitud":"\(ubicacionActual!.longitude)"]]
			soapea("latlong_puestomedido", parametros) { (respuesta, error) in
				
				if error == nil {
					
					for puesto in respuesta {
												
						let annotation = MKPointAnnotation()
						annotation.coordinate = CLLocationCoordinate2DMake((puesto["codigo"]!.componentsSeparatedByString(",")[0] as NSString).doubleValue,(puesto["codigo"]!.componentsSeparatedByString(",")[1] as NSString).doubleValue)
						annotation.title = "Punto de venta"
						
						self.mapaView.addAnnotation(annotation)
						
					}
					
				} else {
					
					println("No se encontraron puntos de venta de estacionamiento medido")
					println(error)
					
				}
				
			}
			
			mapaView.setRegion(MKCoordinateRegionMake(userLocation.coordinate, MKCoordinateSpanMake(0.03, 0.03)), animated: true)
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
		println("deinit")
	}
		
	func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
		
		var autorizado = false
		var autorizacionStatus = ""
		
		switch status {
			case CLAuthorizationStatus.Restricted:
				autorizacionStatus = "Restringido"
			case CLAuthorizationStatus.Denied:
				autorizacionStatus = "Denegado"
			case CLAuthorizationStatus.NotDetermined:
				autorizacionStatus = "No determinado aún"
			default:
				autorizacionStatus = "Permitido"
				autorizado = true
		}
		
		if autorizado == true {
			
			locationManager.startUpdatingLocation()
			
		}
		
	}
	
	override func viewDidDisappear(animated: Bool) {
		
		println("disapear")
		
		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		appDelegate.arrayVC.removeValueForKey("transporteEstacionarTarjetaMapa")
		
		locationManager.stopUpdatingLocation()
		locationManager.delegate = nil
		mapaView.delegate = nil
		
		self.removeFromParentViewController()
		
	}

	override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
}