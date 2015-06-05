
//  MediosDeAccesoMapaViewController.swift
//  GT1
//
//  Created by Pablo Pasqualino on 3/26/15.
//  Copyright (c) 2015 Pablo Pasqualino. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import AddressBook

class MediosDeAccesoMapaViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, SWRevealViewControllerDelegate {

	@IBOutlet weak var mapaView: MKMapView!
	@IBOutlet weak var mapaPasoAPasoBoton: UIButton!
	@IBOutlet weak var sinUbicacionLabel: UILabel!
	
	let locationManager = CLLocationManager()
	
	let mapManager = MapManager()
	
	var ubicacionActual: CLLocation?
	var mapaDestino: MKPlacemark?

    override func viewDidLoad() {
        super.viewDidLoad()

		if hayRed() {
			
			locationManager.delegate = self

			if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse {
				mapaView.showsUserLocation = true
			}
			
			mapaView.delegate = self
			
		}
		
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		armaNavegacion()
		self.revealViewController().delegate = self
		
		if !hayRed() {
			
			muestraError("No se detecta conección a Internet.\nNo es posible continuar.", volver: 1)
			
		}

	}
	
	func alertaLocalizacion() {
		
		UIView.animateWithDuration(0.4, delay: 0, options: .CurveEaseOut, animations: {
			
			self.sinUbicacionLabel.alpha = 1
			
			}, completion: nil)

		var alertController = UIAlertController (title: "Acceso a la localización", message: "Para mostrar la ruta desde tu ubicación hasta Mar del Plata, es necesario que permitas el acceso a la localización desde esta aplicación.\n\nPodes permitir el acceso desde \"Ajustes\".", preferredStyle: .Alert)
		
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
	
	func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
		
		if overlay is MKPolyline {
			
			let polylineRenderer = MKPolylineRenderer(overlay: overlay)
			
			polylineRenderer.strokeColor = UIColor.blueColor()
			polylineRenderer.lineWidth = 5

			return polylineRenderer
			
		}
		
		return nil
	}
	
	func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
		
		mapaView.showsUserLocation = false
		
		ubicacionActual = userLocation.location
		
		muestroRuta()
		
	}
	
	deinit {
//		println("deinit")
	}

	func muestroRuta() {

		let origin = ubicacionActual!.coordinate
		
		let destination = CLLocationCoordinate2DMake(-37.995526, -57.552260) // Luro e Independencia
		
		mapManager.directionsUsingGoogle(from: origin, to: destination) { [weak self] (route,directionInformation, boundingRegion, error) -> () in
			
			if error != nil {
				
				self!.muestraError("No se pudo encontrar el recorrido.",volver: 0)
//				println(error)
				
			} else {

				if self != nil {
				
					let pointOfOrigin = MKPointAnnotation()
					pointOfOrigin.coordinate = route!.coordinate
					pointOfOrigin.title = "Tu ubicación actual"

					let pointOfDestination = MKPointAnnotation()
					pointOfDestination.coordinate = route!.coordinate
					pointOfDestination.title = "Mar del Plata"
					pointOfDestination.subtitle = directionInformation?.objectForKey("distance") as! String
					
					let start_location = directionInformation?.objectForKey("start_location") as! NSDictionary
					let originLat = start_location.objectForKey("lat")?.doubleValue
					let originLng = start_location.objectForKey("lng")?.doubleValue
					
					let end_location = directionInformation?.objectForKey("end_location") as! NSDictionary
					let destLat = end_location.objectForKey("lat")?.doubleValue
					let destLng = end_location.objectForKey("lng")?.doubleValue
					
					let coordOrigin = CLLocationCoordinate2D(latitude: originLat!, longitude: originLng!)
					let coordDesitination = CLLocationCoordinate2D(latitude: destLat!, longitude: destLng!)
					
					pointOfOrigin.coordinate = coordOrigin
					pointOfDestination.coordinate = coordDesitination

					let addressDestino = [
						String(kABPersonAddressStreetKey): "Avenida Luro 3200",
						String(kABPersonAddressCityKey): "Mar del Plata",
						String(kABPersonAddressStateKey): "Buenos Aires",
						String(kABPersonAddressZIPKey): "7600",
						String(kABPersonAddressCountryKey): "Argentina",
						String(kABPersonAddressCountryCodeKey): "AR"
					]
					
					self!.mapaDestino = MKPlacemark(coordinate: coordDesitination, addressDictionary: addressDestino)
					
					dispatch_async(dispatch_get_main_queue()) {

						self!.mapaView.addOverlay(route!)
						self!.mapaView.addAnnotation(pointOfOrigin)
						self!.mapaView.addAnnotation(pointOfDestination)
						self!.mapaView.setVisibleMapRect(boundingRegion!, edgePadding: UIEdgeInsets(top: 30, left: 30, bottom: 30, right: 30), animated: true)

						if self!.revealViewController() != nil { IJProgressView.shared.hideProgressView() }
						
						UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseOut, animations: {
							
							self!.mapaPasoAPasoBoton.alpha = 0.9
							self!.mapaPasoAPasoBoton.userInteractionEnabled = true

							}, completion: nil)
						
					}
				}
			}
		}
		
	}
	
	@IBAction func mostrarMapa() {

		let origen = MKMapItem.mapItemForCurrentLocation()
		
		let destino = MKMapItem(placemark: mapaDestino!)
		
		destino.name = "Mar del Plata"
		
		let mapItems = [origen,destino]
		
		let options = [MKLaunchOptionsDirectionsModeKey:
		MKLaunchOptionsDirectionsModeDriving]
		
		MKMapItem.openMapsWithItems(mapItems, launchOptions: options)

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
				
				}, completion: nil)
			
			mapaView.showsUserLocation = true
			
			self.view.sendSubviewToBack(mapaView)
			
			IJProgressView.shared.showProgressView(self.view, padding: true, texto: "Detectando ubicación")
			
		} else {
			
			locationManager.requestWhenInUseAuthorization()
			
		}
		
	}
	
	override func viewDidDisappear(animated: Bool) {
		
		super.viewDidDisappear(animated)
				
		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		appDelegate.arrayVC.removeValueForKey("mediosDeAccesoMapa")
		
		locationManager.stopUpdatingLocation()
		locationManager.delegate = nil
		
		mapaView.delegate = nil
		
		IJProgressView.shared.hideProgressView()

		self.removeFromParentViewController()
		
	}
	
}