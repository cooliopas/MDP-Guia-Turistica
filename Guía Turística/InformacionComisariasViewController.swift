//  InformacionComisariasViewController.swift
//  GT1
//
//  Created by Pablo Pasqualino on 3/26/15.
//  Copyright (c) 2015 Pablo Pasqualino. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class InformacionComisariasViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, SWRevealViewControllerDelegate {
	
	@IBOutlet weak var mapaView: MKMapView!
	@IBOutlet weak var emergenciaView: UIView!
	@IBOutlet weak var emergenciaLabel: UILabel!
	@IBOutlet weak var emergenciaBoton: UIButton!

	let locationManager = CLLocationManager()
	
	var ubicacionActual: CLLocationCoordinate2D?
	
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
		
		emergenciaView.alpha = 0
		emergenciaView.userInteractionEnabled = false
		emergenciaView.layer.cornerRadius = 10
		
		if !actualizoRegion {
			
			mapaView.setRegion(MKCoordinateRegionMake(CLLocationCoordinate2DMake(-37.992820,-57.583932), MKCoordinateSpanMake(0.05, 0.05)), animated: false)
			
		}
		
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		armaNavegacion()
		self.revealViewController().delegate = self
		
	}
	
	@IBAction func emergenciaLlamar() {

		if let numero = emergenciaBoton.titleLabel?.text {

			let numeroSinEspacios = numero.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
			
			if let url = NSURL(string: "tel://\(numeroSinEspacios)") {
				
				UIApplication.sharedApplication().openURL(url)
				
			}
			
		}

		
	}
	
	func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
		
		ubicacionActual = userLocation.coordinate
		
		if !actualizoRegion {
			
			let parametros = [[String: String]]()
			soapea("comisarias", parametros) { (respuesta, error) in
				
				if error == nil {
					
					for comisaria in respuesta {
						
//						println(comisaria)
						
						let annotation = MKPointAnnotation()
						annotation.coordinate = CLLocationCoordinate2DMake((comisaria["latitud"]! as NSString).doubleValue,(comisaria["longitud"]! as NSString).doubleValue)
						let nombre = comisaria["nro"]!
						let direccion = comisaria["ubicacion"]!
						let tel = comisaria["telefono"] ?? ""
						
						annotation.title = "Comisaria \(nombre)"
						
						if tel != "" {

							annotation.title = "\(annotation.title) - \(tel)"
							
						}
						
						annotation.subtitle = direccion
						
						self.mapaView.addAnnotation(annotation)
						
					}
					
					var parametros = [["latitud":"\(userLocation.coordinate.latitude)"],["longitud":"\(userLocation.coordinate.longitude)"]]
					soapea("comisaria_cercana", parametros) { (respuesta, error) in
						
						if error == nil {
							
							if respuesta.count > 0 {
								
								let comisaria = respuesta[0]
								let direccion = comisaria["ubicacion"]!
								
								for annotation in self.mapaView.annotations {
									
									if !(annotation is MKUserLocation) {

										if annotation.subtitle == direccion {
										
											let comisariaCercana = annotation as! MKAnnotation
											
											let annotation = MKPointAnnotation()
											annotation.coordinate = comisariaCercana.coordinate
											annotation.title = comisariaCercana.title
											annotation.subtitle = "\(comisariaCercana.subtitle!) - COMISARIA MAS CERCANA"
											
											self.mapaView.addAnnotation(annotation)
											
											self.mapaView.selectAnnotation(annotation, animated: true)

											self.mapaView.removeAnnotation(comisariaCercana)
											
										}
										
									}
									
								}
								
							}
							
						} else {
							
							println("No se encontro la comisaria más cercana")
							println(error)
							
						}
						
					}

					parametros = [["latitud":"\(userLocation.coordinate.latitude)"],["longitud":"\(userLocation.coordinate.longitude)"]]
					soapea("movilpolicial_lat_lng", parametros) { (respuesta, error) in
						
						if error == nil {
							
							if respuesta.count > 0 && respuesta[0]["return"] != "NO" {
							
								self.emergenciaLabel.text = "En caso de emergencia, el teléfono celular del móvil policial más cercano es: "
								self.emergenciaBoton.setTitle("0223 155 381575", forState: UIControlState.Normal)
								
								UIView.animateWithDuration(0.6, delay: 0.0, options: .CurveEaseOut, animations: {
									
									self.emergenciaView.alpha = 1
									self.emergenciaView.userInteractionEnabled = true
									
									}, completion: nil)
								
							} else {

								println("No se encontro el movil más cercano")
								
							}
						
						} else {
							
							println("No se encontro el movil más cercano")
							println(error)
							
						}
						
					}
					
				} else {
					
					println("No se encontraron comisarias")
					println(error)
					
				}
				
			}
			
			mapaView.setRegion(MKCoordinateRegionMake(userLocation.coordinate, MKCoordinateSpanMake(0.03, 0.03)), animated: true)
			actualizoRegion = true
			
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
		appDelegate.arrayVC.removeValueForKey("informacionComisarias")
		
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