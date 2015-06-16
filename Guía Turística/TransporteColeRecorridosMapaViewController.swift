
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

class TransporteColeRecorridosMapaViewController: UIViewController, MKMapViewDelegate, SWRevealViewControllerDelegate {

	@IBOutlet weak var mapaView: MKMapView!
	@IBOutlet weak var segmentadorRecorridos: UISegmentedControl!
	@IBOutlet weak var statusLabel: UILabel!

	var linea: String!
	
	let mapManager = MapManager()
	
	var polylineIda = MKPolyline()
	let annotationInicioIda = MKPointAnnotation()
	let annotationFinIda = MKPointAnnotation()
    var hayRecorridosIda = false

	var polylineVuelta = MKPolyline()
	let annotationInicioVuelta = MKPointAnnotation()
	let annotationFinVuelta = MKPointAnnotation()
    var hayRecorridosVuelta = false
	
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if count(linea) < 10 {
        
            navBar?.topItem?.title = "Recorrido linea \(linea)"
            
        } else {
            
            navBar?.topItem?.title = "Recorrido \(linea)"
            
        }
		
		if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse {
			mapaView.showsUserLocation = true
		}
		
		mapaView.delegate = self
		
		mapaView.setRegion(MKCoordinateRegionMake(CLLocationCoordinate2DMake(-37.992820, -57.583932), MKCoordinateSpanMake(0.05, 0.05)), animated: false)

        // leo recorrido de ida
        
        linea = linea.lowercaseString.stringByReplacingOccurrencesOfString(" ", withString: "-", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
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
                
                polylineIda = MKPolyline(coordinates: &arrayPuntosIda, count: arrayPuntosIda.count)
                polylineIda.title = "ida"
                
                annotationInicioIda.coordinate = inicioIda
                annotationInicioIda.title = "Inicio recorrido de ida"
                
                annotationFinIda.coordinate = finIda
                annotationFinIda.title = "Final recorrido de ida"
                
                hayRecorridosIda = true
                
        } else {
            
            segmentadorRecorridos.setEnabled(false, forSegmentAtIndex: 0)
            segmentadorRecorridos.setEnabled(false, forSegmentAtIndex: 2)
            
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
                
                polylineVuelta = MKPolyline(coordinates: &arrayPuntosVuelta, count: arrayPuntosVuelta.count)
                polylineVuelta.title = "vuelta"
                
                annotationInicioVuelta.coordinate = inicioVuelta
                annotationInicioVuelta.title = "Inicio recorrido de vuelta"
                
                annotationFinVuelta.coordinate = finVuelta
                annotationFinVuelta.title = "Fin recorrido de vuelta"
                
                hayRecorridosVuelta = true
                
        } else {
            
            segmentadorRecorridos.setEnabled(false, forSegmentAtIndex: 1)
            segmentadorRecorridos.setEnabled(false, forSegmentAtIndex: 2)
            
        }
        
        if hayRecorridosIda && hayRecorridosVuelta {
            
            segmentadorRecorridos.selectedSegmentIndex = 2
            
        } else if hayRecorridosIda {
            
            segmentadorRecorridos.selectedSegmentIndex = 0
            
        } else if hayRecorridosVuelta {
            
            segmentadorRecorridos.selectedSegmentIndex = 1
            
        }
        
	}

    func regionForAnnotations(puntos: [MKPointAnnotation]) -> MKCoordinateRegion {

        var minLat = 90.0
        var maxLat = -90.0
        var minLon = 180.0
        var maxLon = -180.0
    
        for punto in puntos {
            
            if punto.coordinate.latitude < minLat { minLat = punto.coordinate.latitude }
            if punto.coordinate.latitude > maxLat { maxLat = punto.coordinate.latitude }
            if punto.coordinate.longitude < minLon { minLon = punto.coordinate.longitude }
            if punto.coordinate.longitude > maxLon { maxLon = punto.coordinate.longitude }
            
        }
        
        let center = CLLocationCoordinate2DMake((minLat+maxLat)/2.0, (minLon+maxLon)/2.0)
        let span = MKCoordinateSpanMake(maxLat-minLat, maxLon-minLon);
        let region = MKCoordinateRegionMake (center, span);
        
        return region
        
    }
    
	@IBAction func segmentarRecorrido() {
		
		mapaView.removeOverlay(polylineIda)
		mapaView.removeAnnotation(annotationInicioIda)
		mapaView.removeAnnotation(annotationFinIda)
		mapaView.removeOverlay(polylineVuelta)
		mapaView.removeAnnotation(annotationInicioVuelta)
		mapaView.removeAnnotation(annotationFinVuelta)

		switch segmentadorRecorridos.selectedSegmentIndex {
		case 0:
			mapaView.addOverlay(polylineIda)
			mapaView.addAnnotation(annotationInicioIda)
			mapaView.addAnnotation(annotationFinIda)
            mapaView.setRegion(regionForAnnotations([annotationInicioIda,annotationFinIda]), animated: true)
		case 1:
			mapaView.addOverlay(polylineVuelta)
			mapaView.addAnnotation(annotationInicioVuelta)
			mapaView.addAnnotation(annotationFinVuelta)
            mapaView.setRegion(regionForAnnotations([annotationInicioVuelta,annotationFinVuelta]), animated: true)
		case 2:
			mapaView.addOverlay(polylineIda)
			mapaView.addAnnotation(annotationInicioIda)
			mapaView.addAnnotation(annotationFinIda)
			mapaView.addOverlay(polylineVuelta)
			mapaView.addAnnotation(annotationInicioVuelta)
			mapaView.addAnnotation(annotationFinVuelta)
            mapaView.setRegion(regionForAnnotations([annotationInicioIda,annotationFinIda,annotationInicioVuelta,annotationFinVuelta]), animated: true)
		default:
			break
		}
		
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		armaNavegacion()
		self.revealViewController().delegate = self
		
	}
	
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if !hayRecorridosIda && !hayRecorridosVuelta {
            
            muestraError("Ocurrío un error al leer los recorridos.",volver: 1)

        } else {
        
            segmentarRecorrido()
            
        }
        
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
//		println("deinit")
	}
	
	override func viewDidDisappear(animated: Bool) {
		
		super.viewDidDisappear(animated)
				
		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		appDelegate.arrayVC.removeValueForKey("transporteColeRecorridosMapa")
		
		mapaView.delegate = nil
		
		self.removeFromParentViewController()
		
	}

}