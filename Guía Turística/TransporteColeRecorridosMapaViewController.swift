
//  TransporteColeRecorridosMapaViewController.swift
//  GT1
//
//  Created by Pablo Pasqualino on 3/26/15.
//  Copyright (c) 2015 Pablo Pasqualino. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import SwiftyJSON

class TransporteColeRecorridosMapaViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, SWRevealViewControllerDelegate {

	@IBOutlet weak var mapaView: MKMapView!

	var linea: String!
	
	let locationManager = CLLocationManager()
	
	let mapManager = MapManager()
	
    override func viewDidLoad() {
        super.viewDidLoad()

		if CLLocationManager.authorizationStatus() == .NotDetermined {
			locationManager.requestWhenInUseAuthorization()
		}

		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyBest

		mapaView.showsUserLocation = true
		mapaView.delegate = self
		
// leo recorrido de ida
		
		if let file = NSBundle.mainBundle().pathForResource("Recorridos.bundle/\(linea)-ida", ofType: "json"),
			let data = NSData(contentsOfFile: file),
			let coordenadasIda = JSON(data:data).array {

			let inicioIda = CLLocationCoordinate2DMake(coordenadasIda.first![0].doubleValue,coordenadasIda.first![1].doubleValue)
			let finIda = CLLocationCoordinate2DMake(coordenadasIda.last![0].doubleValue,coordenadasIda.last![1].doubleValue)

			var arrayPuntosIda = [CLLocationCoordinate2D]()

			for coordenada in coordenadasIda {
				
				let coordenadaArmada = 	CLLocationCoordinate2DMake(coordenada[0].doubleValue,coordenada[1].doubleValue)
				
				arrayPuntosIda.append(coordenadaArmada)
				
			}

			let polylineIda = MKPolyline(coordinates: &arrayPuntosIda, count: arrayPuntosIda.count)
			polylineIda.title = "ida"
			mapaView.addOverlay(polylineIda)

			let annotationInicioIda = MKPointAnnotation()
			annotationInicioIda.coordinate = inicioIda
			annotationInicioIda.title = "Inicio Ida"
			annotationInicioIda.subtitle = "Sub Inicio Ida"
			
			mapaView.addAnnotation(annotationInicioIda)
			
			let annotationFinIda = MKPointAnnotation()
			annotationFinIda.coordinate = finIda
			annotationFinIda.title = "Fin Ida"
			annotationFinIda.subtitle = "Sub Fin Ida"
			
			mapaView.addAnnotation(annotationFinIda)
			
		} else {
			
			println("Error leyendo recorrido ida")
			
		}
		

// leo recorrido de vuelta
		
		if let file = NSBundle.mainBundle().pathForResource("Recorridos.bundle/\(linea)-vuelta", ofType: "json"),
			let data = NSData(contentsOfFile: file),
			let coordenadasVuelta = JSON(data:data).array {
				
				let inicioVuelta = CLLocationCoordinate2DMake(coordenadasVuelta.first![0].doubleValue,coordenadasVuelta.first![1].doubleValue)
				let finVuelta = CLLocationCoordinate2DMake(coordenadasVuelta.last![0].doubleValue,coordenadasVuelta.last![1].doubleValue)
				
				var arrayPuntosVuelta = [CLLocationCoordinate2D]()
				
				for coordenada in coordenadasVuelta {
					
					let coordenadaArmada = 	CLLocationCoordinate2DMake(coordenada[0].doubleValue,coordenada[1].doubleValue)
					
					arrayPuntosVuelta.append(coordenadaArmada)
					
				}
				
				let polylineVuelta = MKPolyline(coordinates: &arrayPuntosVuelta, count: arrayPuntosVuelta.count)
				polylineVuelta.title = "vuelta"
				mapaView.addOverlay(polylineVuelta)
				
				let annotationInicioVuelta = MKPointAnnotation()
				annotationInicioVuelta.coordinate = inicioVuelta
				annotationInicioVuelta.title = "Inicio Vuelta"
				annotationInicioVuelta.subtitle = "Sub Inicio Vuelta"
				
				mapaView.addAnnotation(annotationInicioVuelta)
				
				let annotationFinVuelta = MKPointAnnotation()
				annotationFinVuelta.coordinate = finVuelta
				annotationFinVuelta.title = "Fin Vuelta"
				annotationFinVuelta.subtitle = "Sub Fin Vuelta"
				
				mapaView.addAnnotation(annotationFinVuelta)
				
		} else {
			
			println("Error leyendo recorrido vuelta")
			
		}
		
		mapaView.setRegion(MKCoordinateRegionMake(CLLocationCoordinate2DMake(-37.992820, -57.583932), MKCoordinateSpanMake(0.05, 0.05)), animated: false)

	}

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		armaNavegacion()
		self.revealViewController().delegate = self
		
	}
	
	func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
		
		if overlay is MKPolyline {
			
			let polylineRenderer = MKPolylineRenderer(overlay: overlay)
			
			if overlay.title == "ida" {
				polylineRenderer.strokeColor = UIColor.blueColor()
			} else {
				polylineRenderer.strokeColor = UIColor.redColor()
			}
			polylineRenderer.lineWidth = 5

			return polylineRenderer
			
		}
		
		return nil
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
		appDelegate.arrayVC.removeValueForKey("transporteColeRecorridosMapa")
		
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