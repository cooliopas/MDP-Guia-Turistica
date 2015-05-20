//  InformacionCentrosSaludViewController.swift
//  GT1
//
//  Created by Pablo Pasqualino on 3/26/15.
//  Copyright (c) 2015 Pablo Pasqualino. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class InformacionCentrosSaludViewController: UIViewController, MKMapViewDelegate, SWRevealViewControllerDelegate {
	
	@IBOutlet weak var mapaView: MKMapView!
	@IBOutlet weak var statusLabel: UILabel!

	let locationManager = CLLocationManager()
	
	var actualizoRegion = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse {
			mapaView.showsUserLocation = true
		}
		
		mapaView.delegate = self

		let parametros = [[String: String]]()
		soapea("centros_de_salud", parametros) { (respuesta, error) in
			
			if error == nil {
				
				for centro in respuesta {
					
					let annotation = MKPointAnnotation()
					annotation.coordinate = CLLocationCoordinate2DMake((centro["latitud"]! as NSString).doubleValue,(centro["longitud"]! as NSString).doubleValue)
					let nombre = centro["descripcion"]!
					let direccion = centro["ubicacion"]!
					
					annotation.title = nombre
					annotation.subtitle = direccion
					
					self.mapaView.addAnnotation(annotation)
					
				}
				
			} else {
				
				println("No se encontraron Centros de Salud")
				println(error)
				
			}
			
		}
		
		if !actualizoRegion {
			
			mapaView.setRegion(MKCoordinateRegionMake(CLLocationCoordinate2DMake(-37.992820,-57.583932), MKCoordinateSpanMake(0.04, 0.04)), animated: false)
			
		}
		
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		armaNavegacion()
		self.revealViewController().delegate = self
		
	}
	
	func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
		
		if !actualizoRegion {
			
			mapaView.setRegion(MKCoordinateRegionMake(userLocation.coordinate, MKCoordinateSpanMake(0.03, 0.03)), animated: true)
			actualizoRegion = true
			
		}
		
	}
	
	func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
		
		if annotation is MKUserLocation {
			
			return nil
			
		} else {
			
			let imagen = UIImage(named: "sociales")
			
			var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("centro")
			
			if annotationView != nil {
				
				annotationView.annotation = annotation
				
			} else {
				
				annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "centro")
				
			}
			
			annotationView.canShowCallout = true
			annotationView.image = imagen
			annotationView.centerOffset = CGPointMake(0, -12)
			
			return annotationView
			
		}
		
	}
	
	deinit {
		println("deinit")
	}
	
	override func viewDidDisappear(animated: Bool) {
		
		super.viewDidDisappear(animated)
				
		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		appDelegate.arrayVC.removeValueForKey("informacionCentrosSalud")
		
		mapaView.delegate = nil
		
		self.removeFromParentViewController()
		
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
}