//
//  InformacionMovilPolicialViewController.swift
//  GT1
//
//  Created by Pablo Pasqualino on 3/18/15.
//  Copyright (c) 2015 Pablo Pasqualino. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import AddressBook

class InformacionMovilPolicialViewController: UIViewController, CLLocationManagerDelegate, SWRevealViewControllerDelegate {
	
	@IBOutlet weak var emergenciaView: UIView!
	@IBOutlet weak var emergenciaLabel: UILabel!
	@IBOutlet weak var emergenciaBoton: UIButton!
	@IBOutlet weak var emergenciaViewHeight: NSLayoutConstraint!
	@IBOutlet weak var detectandoView: UIView!
	@IBOutlet weak var telefonosView: UIView!
	@IBOutlet weak var telefonosViewHeight: NSLayoutConstraint!
	@IBOutlet weak var comisariaTitulo: UILabel!
	@IBOutlet weak var comisariaDetalle: UILabel!
	@IBOutlet weak var comisariaBoton: UIButton!
	
	let locationManager = CLLocationManager()
	
	var ubicacionActual: CLLocationCoordinate2D?
	var comisariaCercana: [String:String]?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if CLLocationManager.authorizationStatus() == .NotDetermined {
			locationManager.requestWhenInUseAuthorization()
		}
		
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyBest

		locationManager.startUpdatingLocation()
		
		emergenciaView.alpha = 0
		emergenciaView.userInteractionEnabled = false
		emergenciaView.layer.cornerRadius = 5

		telefonosView.layer.cornerRadius = 5
		telefonosView.alpha = 0
		
		comisariaTitulo.alpha = 0
		comisariaDetalle.alpha = 0
		comisariaBoton.alpha = 0
		
		detectandoView.layer.cornerRadius = 5

	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		armaNavegacion()
		self.revealViewController().delegate = self
		
	}
	
	@IBAction func emergenciaLlamar(sender: UIButton) {
		
		if let numero = sender.titleLabel?.text {
			
			let numeroSinEspacios = numero.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
			
			if let url = NSURL(string: "tel://\(numeroSinEspacios)") {
				
				UIApplication.sharedApplication().openURL(url)
				
				println("Llamando al \(numeroSinEspacios)")
				
			}
			
		}
		
		
	}

	func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
		
		println("Actualizo location")
		
		locationManager.stopUpdatingLocation()
		
		ubicacionActual = (locations.last as! CLLocation).coordinate
		
		let parametros = [["latitud":"\(ubicacionActual!.latitude)"],["longitud":"\(ubicacionActual!.longitude)"]]
		soapea("movilpolicial_lat_lng", parametros) { (respuesta, error) in
			
			if error == nil {
				
				if respuesta.count > 0 && respuesta[0]["return"] != "NO" {
					
					self.emergenciaLabel.text = "En caso de emergencia, el teléfono celular del móvil policial más cercano es: "
					self.emergenciaBoton.setTitle("0223 155 381575", forState: UIControlState.Normal)
					self.emergenciaViewHeight.constant = 120
					
				} else {
					
					self.emergenciaLabel.text = "Lamentablemente, el servicio de información no esta disponible en este momento."
					self.emergenciaBoton.hidden = true
					self.emergenciaViewHeight.constant = 80

				}
				
				UIView.animateWithDuration(0.6, delay: 0.5, options: .CurveEaseOut, animations: {
					
					self.detectandoView.alpha = 0

					self.emergenciaView.alpha = 1
					self.emergenciaView.userInteractionEnabled = true
					
					self.telefonosView.alpha = 1
					
					}, completion: nil)

				
			} else {
				
				println("No se encontro el movil más cercano")
				println(error)
				
			}
			
		}
		
		soapea("comisaria_cercana", parametros) { (respuesta, error) in
			
			if error == nil {
				
				if respuesta.count > 0 {
					
					let comisaria = respuesta[0]
					
					self.comisariaCercana = comisaria
					
//					annotation.coordinate = CLLocationCoordinate2DMake((comisaria["latitud"]! as NSString).doubleValue,(comisaria["longitud"]! as NSString).doubleValue)
					let nombre = comisaria["nro"]!
					let direccion = comisaria["ubicacion"]!
					let tel = comisaria["telefono"] ?? ""
					
					self.comisariaDetalle.text = "Comisaria \(nombre)\n\(direccion)"
					
					if tel != "" {
						
						self.comisariaDetalle.text! += "\nTeléfono(s): \(tel)"
						
					}
				
					UIView.animateWithDuration(0.4, delay: 0.5, options: .CurveEaseOut, animations: {
						
						self.comisariaTitulo.alpha = 1
						self.comisariaDetalle.alpha = 1
						self.comisariaBoton.alpha = 1
						
						if tel != "" {

							self.telefonosViewHeight.constant = 250
							
						} else {
							
							self.telefonosViewHeight.constant = 240
							
						}
						
						self.view.layoutIfNeeded()
						
						}, completion: nil)
					
				}
				
			} else {
				
				println("No se encontro la comisaria más cercana")
				println(error)
				
			}
			
		}
		
	}
	
	@IBAction func comisariaComoLlegar() {
		
		if comisariaCercana != nil {
		
			let origen = MKMapItem.mapItemForCurrentLocation()
			
			let nombre = comisariaCercana!["nro"]!
			let direccion = comisariaCercana!["ubicacion"]!
			let tel = comisariaCercana!["telefono"] ?? ""

			let addressDestino = [
				String(kABPersonAddressStreetKey): direccion,
				String(kABPersonAddressCityKey): "Mar del Plata",
				String(kABPersonAddressStateKey): "Buenos Aires",
				String(kABPersonAddressZIPKey): "7600",
				String(kABPersonAddressCountryKey): "Argentina",
				String(kABPersonAddressCountryCodeKey): "AR"
			]
			
			let coordDesitination = CLLocationCoordinate2D(latitude: (comisariaCercana!["latitud"]! as NSString).doubleValue, longitude: (comisariaCercana!["longitud"]! as NSString).doubleValue)
			
			let destino = MKMapItem(placemark: MKPlacemark(coordinate: coordDesitination, addressDictionary: addressDestino))
			
			destino.name = "Comisaría \(nombre)"
			if tel != "" { destino.phoneNumber = tel }
			
			let mapItems = [origen,destino]
			
			let options = [MKLaunchOptionsDirectionsModeKey:
			MKLaunchOptionsDirectionsModeDriving]
			
			MKMapItem.openMapsWithItems(mapItems, launchOptions: options)

		}
		
	}
	
	deinit {
		println("deinit")
	}
	
	override func viewDidDisappear(animated: Bool) {
		
		println("disapear")
		
		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		appDelegate.arrayVC.removeValueForKey("informacionMovilPolicial")
		
		locationManager.stopUpdatingLocation()
		locationManager.delegate = nil
		
		self.removeFromParentViewController()
		
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
}