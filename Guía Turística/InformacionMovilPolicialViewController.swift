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
	@IBOutlet weak var detectandoLabel: UILabel!
	@IBOutlet weak var telefonosView: UIView!
	@IBOutlet weak var telefonosViewHeight: NSLayoutConstraint!
	@IBOutlet weak var comisariaTitulo: UILabel!
	@IBOutlet weak var comisariaDetalle: UILabel!
	@IBOutlet weak var comisariaBoton: UIButton!
	
	let locationManager = CLLocationManager()
	
	var ubicacionActual: CLLocation?
	var comisariaCercana: [String:String]?
	
	override func viewDidLoad() {
		super.viewDidLoad()

		if hayRed() {
		
			locationManager.delegate = self
			locationManager.desiredAccuracy = kCLLocationAccuracyBest
			
		} else {
			
			detectandoLabel.text = "No hay conección a Internet."
			
		}
				
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		armaNavegacion()
		self.revealViewController().delegate = self
		
	}
	
	@IBAction func emergenciaLlamar(sender: UIButton) {
		
		if let numero = sender.titleLabel?.text {
			
			let numeroSinEspacios = numero.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
			
			if let url = NSURL(string: "tel://\(numeroSinEspacios)") {
				
				UIApplication.sharedApplication().openURL(url)
				
			}
			
		}
		
		
	}

	func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
		
		locationManager.stopUpdatingLocation()
		
		ubicacionActual = locations.last as? CLLocation
		
		detectandoLabel.text = "Buscando movil policial más cercano ..."
		
        if ubicacionActual != nil {
        
            let parametros = [["latitud":"\(ubicacionActual!.coordinate.latitude)"],["longitud":"\(ubicacionActual!.coordinate.longitude)"]]
            soapea("movilpolicial_lat_lng", parametros) { (respuesta, error) in
                
                if error == nil {
                    
                    var nuevoEmergenciaViewHeight: CGFloat = 0
                    
                    if respuesta.count > 0 && respuesta[0]["return"] != "NO" {
                        
                        self.emergenciaLabel.text = "En caso de emergencia, el teléfono celular del móvil policial más cercano es: "
                        self.emergenciaBoton.setTitle(respuesta[0]["return"], forState: UIControlState.Normal)
                        nuevoEmergenciaViewHeight = 120
                        
                    } else {
                        
                        self.emergenciaLabel.text = "Lamentablemente, el servicio de información no esta disponible en este momento."
                        self.emergenciaBoton.hidden = true
                        nuevoEmergenciaViewHeight = 80

                    }
                    
                    UIView.animateWithDuration(0.6, delay: 0.5, options: .CurveEaseOut, animations: {
                        
                        self.emergenciaViewHeight.constant = nuevoEmergenciaViewHeight
                        
                        self.detectandoView.alpha = 0

                        self.emergenciaView.alpha = 1
                        self.emergenciaView.userInteractionEnabled = true
                        
                        self.telefonosView.alpha = 1
                        
                        self.view.layoutIfNeeded()
                        
                        }, completion: nil)
                    
                } else {
                    
    //				println("No se encontro el movil más cercano")
    //				println(error)
                    
                }
                
            }
            
            soapea("comisaria_cercana", parametros) { (respuesta, error) in
                
                if error == nil {
                    
                    if respuesta.count > 0 {
                        
                        let comisaria = respuesta[0]
                        
                        self.comisariaCercana = comisaria
                        
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
                    
    //				println("No se encontro la comisaria más cercana")
    //				println(error)
                    
                }
                
            }

        }
            
	}
	
	func alertaLocalizacion() {
		
		emergenciaLabel.text = "No fue posible detectar tu ubicación."
		emergenciaBoton.hidden = true
		
		UIView.animateWithDuration(0.6, delay: 0.5, options: .CurveEaseOut, animations: {
			
			self.emergenciaViewHeight.constant = 80

			self.detectandoView.alpha = 0
			
			self.emergenciaView.alpha = 1
			self.emergenciaView.userInteractionEnabled = true
			
			self.telefonosView.alpha = 1
			
			self.view.layoutIfNeeded()
			
			}, completion: nil)
		
		var alertController = UIAlertController (title: "Acceso a la localización", message: "Para mostrar el movil policial más cercano a tu ubicación, es necesario que permitas el acceso a la localización desde esta aplicación.\n\nPodes permitir el acceso desde \"Ajustes\".", preferredStyle: .Alert)
		
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
			
			emergenciaBoton.hidden = false
			
			UIView.animateWithDuration(0.6, delay: 0, options: .CurveEaseOut, animations: {
				
				self.detectandoView.alpha = 1
				
				self.emergenciaView.alpha = 0
				self.emergenciaView.userInteractionEnabled = false
				
				self.telefonosView.alpha = 1
				
				}, completion: nil)
			
			locationManager.startUpdatingLocation()
			
		} else {
			
			locationManager.requestWhenInUseAuthorization()
			
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
//		println("deinit")
	}
	
	override func viewDidDisappear(animated: Bool) {
		
		super.viewDidDisappear(animated)
				
		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		appDelegate.arrayVC.removeValueForKey("informacionMovilPolicial")
		
		locationManager.stopUpdatingLocation()
		locationManager.delegate = nil
		
		self.removeFromParentViewController()
		
	}
	
}