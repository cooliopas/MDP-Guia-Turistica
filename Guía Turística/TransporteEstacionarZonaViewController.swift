
//  TransporteEstacionarZonaViewController.swift
//  GT1
//
//  Created by Pablo Pasqualino on 3/26/15.
//  Copyright (c) 2015 Pablo Pasqualino. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class TransporteEstacionarZonaViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, SWRevealViewControllerDelegate {

	@IBOutlet weak var mapaView: MKMapView!
	@IBOutlet weak var labelVerificando: UILabel!
	@IBOutlet weak var botonUbicacion: UIButton!
	@IBOutlet weak var sinUbicacionLabel: UILabel!

	var linea: String!
	
	let locationManager = CLLocationManager()

	var ubicacionActual: CLLocation?
	
	let mapManager = MapManager()
	
	var actualizoRegion = false
	var poligonoZonaSegura: MKPolygon!
	let polygonAsCGP = CGPathCreateMutable()
    
    var coordenadasZona = [
        CLLocationCoordinate2DMake(-37.993095,-57.554640),
        CLLocationCoordinate2DMake(-37.997755,-57.545455),
        CLLocationCoordinate2DMake(-37.998190,-57.544420),
        CLLocationCoordinate2DMake(-37.998780,-57.542330),
        CLLocationCoordinate2DMake(-37.998965,-57.541520),
        CLLocationCoordinate2DMake(-38.000257,-57.541319),
        CLLocationCoordinate2DMake(-38.000737,-57.541335),
        CLLocationCoordinate2DMake(-38.000984,-57.541391),
        CLLocationCoordinate2DMake(-38.002000,-57.541780),
        CLLocationCoordinate2DMake(-38.006105,-57.545018),
        CLLocationCoordinate2DMake(-37.998880,-57.559280)
    ]
    
    var coordenadasZonaSegura = [
        CLLocationCoordinate2DMake(-37.992934,-57.554683),
        CLLocationCoordinate2DMake(-37.997645,-57.545358),
        CLLocationCoordinate2DMake(-37.998055,-57.544291),
        CLLocationCoordinate2DMake(-37.998662,-57.542276),
        CLLocationCoordinate2DMake(-37.998889,-57.541348),
        CLLocationCoordinate2DMake(-38.000249,-57.541158),
        CLLocationCoordinate2DMake(-38.000729,-57.541163),
        CLLocationCoordinate2DMake(-38.000992,-57.541209),
        CLLocationCoordinate2DMake(-38.002059,-57.541598),
        CLLocationCoordinate2DMake(-38.006308,-57.544943),
        CLLocationCoordinate2DMake(-37.998888,-57.559527)
    ]
	
    override func viewDidLoad() {
        super.viewDidLoad()

		if hayRed() {
		
			locationManager.delegate = self
			
			if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse {
				mapaView.showsUserLocation = true
			}
			
			mapaView.delegate = self

			let poligonoZona = MKPolygon(coordinates: &coordenadasZona, count: coordenadasZona.count)
			mapaView.addOverlay(poligonoZona)

			poligonoZonaSegura = MKPolygon(coordinates: &coordenadasZonaSegura, count: coordenadasZonaSegura.count)

			let polygonPoints = poligonoZonaSegura.points()
			
			for var p = 0; p < poligonoZonaSegura.pointCount; p++ {
				
				let point = polygonPoints[p]
				
				if p == 0 {
					CGPathMoveToPoint(polygonAsCGP, nil, CGFloat(point.x), CGFloat(point.y))
				} else {
					CGPathAddLineToPoint(polygonAsCGP, nil, CGFloat(point.x), CGFloat(point.y))
				}
				
			}

			labelVerificando.backgroundColor = UIColor.clearColor()
			labelVerificando.layer.backgroundColor = UIColor(red: 0.454775, green: 0.602937, blue: 0.787375, alpha: 1).CGColor

//			mapaView.setRegion(MKCoordinateRegionMake(CLLocationCoordinate2DMake(-38.000125, -57.549382), MKCoordinateSpanMake(0.007, 0.007)), animated: false)
            mapaView.setRegion(regionIncluyendoCoordenadas(coordenadasZonaSegura), animated: true)

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
    
	func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
		
		if overlay is MKPolygon {
			
			let polygonRenderer = MKPolygonRenderer(overlay: overlay)
			
			polygonRenderer.fillColor = UIColor.cyanColor().colorWithAlphaComponent(0.2)
			polygonRenderer.strokeColor = UIColor.blueColor().colorWithAlphaComponent(0.7)
			polygonRenderer.lineWidth = 3
			
			return polygonRenderer
			
		}
		
		return nil
	}
	
//	location
	
	func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
		
		ubicacionActual = userLocation.location
		
		if !actualizoRegion {

			labelVerificando.layer.removeAllAnimations()

			UIView.animateWithDuration(0.6, delay: 0.0, options: .CurveEaseOut, animations: {
				
				self.labelVerificando.alpha = 1
				self.botonUbicacion.alpha = 1
				self.botonUbicacion.userInteractionEnabled = true
				
				}, completion: nil)
			
			actualizoRegion = true
			
		}

		let mapPointActual = MKMapPointForCoordinate(userLocation.coordinate)
		let mapPointAsCGP = CGPointMake(CGFloat(mapPointActual.x), CGFloat(mapPointActual.y))
		
		let pointIsInPolygon = CGPathContainsPoint(polygonAsCGP, nil, mapPointAsCGP, false);
		
		if !pointIsInPolygon {
			
			labelVerificando.text = " No es zona de estacionamiento medido   "
			
			UIView.animateWithDuration(0.6, delay: 0.0, options: .CurveEaseOut, animations: {
				
				self.labelVerificando.layer.backgroundColor = UIColor.blueColor().CGColor
				
				}, completion: nil)
			
		} else {
			
			labelVerificando.text = " Estas en zona de estacionamiento medido "
			
			UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseOut, animations: {
				
				self.labelVerificando.layer.backgroundColor = UIColor.redColor().CGColor
				
				}, completion: nil)
			
		}
		
	}
	
	@IBAction func mostrarUbicacion() {
		
//		mapaView.setRegion(MKCoordinateRegionMake(ubicacionActual!.coordinate, MKCoordinateSpanMake(0.04, 0.04)), animated: true)
        mapaView.setRegion(regionIncluyendoCoordenadas(coordenadasZonaSegura + [ubicacionActual!.coordinate]), animated: true)
        
	}
	
	deinit {
//		println("deinit")
	}
	
	func alertaLocalizacion() {
		
		UIView.animateWithDuration(0.4, delay: 0, options: .CurveEaseOut, animations: {
			
			self.sinUbicacionLabel.alpha = 1
			self.labelVerificando.alpha = 0
			
			}, completion: nil)
		
		var alertController = UIAlertController (title: "Acceso a la localización", message: "Para detectar si estas dentro de la zona de estacionamiento medido, es necesario que permitas el acceso a la localización desde esta aplicación.\n\nPodes permitir el acceso desde \"Ajustes\".", preferredStyle: .Alert)
		
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
			
			mapaView.showsUserLocation = true
			
			UIView.animateWithDuration(0.6, delay: 0.0, options: .Repeat | .Autoreverse, animations: {
				
				self.labelVerificando.alpha = 0.8
				self.sinUbicacionLabel.alpha = 0
				
				}, completion: nil)
			
		} else {
			
			locationManager.requestWhenInUseAuthorization()
			
		}
		
	}
	
	override func viewDidDisappear(animated: Bool) {
		
		super.viewDidDisappear(animated)
		
		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		appDelegate.arrayVC.removeValueForKey("transporteEstacionarZona")
		
		locationManager.delegate = nil
		mapaView.delegate = nil
		
		self.removeFromParentViewController()
		
	}
	
}