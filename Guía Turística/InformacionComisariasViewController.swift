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
	@IBOutlet weak var statusLabel: UILabel!
	@IBOutlet weak var sinUbicacionLabel: UILabel!
	
	let locationManager = CLLocationManager()
	
	var ubicacionActual: CLLocation?
    
    var mostroComisarias = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if hayRed() {
			
			locationManager.delegate = self
			
			mapaView.delegate = self
						
            statusLabel.text = "Cargando datos ..."
            
			UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
				
				self.statusLabel.alpha = 1
				
				}, completion: nil)
			
			let parametros = [[String: String]]()
			soapea("comisarias", parametros) { (respuesta, error) in
				
                self.mostroComisarias = true

                if self.ubicacionActual != nil {
                    
                    UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut | .BeginFromCurrentState, animations: {
                        
                        self.statusLabel.alpha = 0
                        
                        }, completion: nil)
                    
                } else {
                    
                    self.statusLabel.text = "Detectando ubicación ..."
                    
                }
                
				if error == nil && respuesta.count > 1 {
                    
					for comisaria in respuesta {
						
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
						
						if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse {

							self.mapaView.showsUserLocation = true
							
						}
						
					}
                    
                    if self.ubicacionActual != nil {
                        
                        self.cargaComisariaCercanaYMovil()
                        
                    }
					
				} else {
					
					self.muestraError("No se encontraron comisarias.",volver: 1)
					
				}
				
			}
			
			mapaView.setRegion(MKCoordinateRegionMake(CLLocationCoordinate2DMake(-37.992820,-57.583932), MKCoordinateSpanMake(0.05, 0.05)), animated: false)
			
		}
		
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		armaNavegacion()
		self.revealViewController().delegate = self
		
		var tracker = GAI.sharedInstance().defaultTracker
		tracker.set(kGAIScreenName, value: self.restorationIdentifier!)

		var builder = GAIDictionaryBuilder.createScreenView()
		tracker.send(builder.build() as [NSObject : AnyObject])

	}
	
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if !hayRed() {
            
            muestraError("No se detecta conección a Internet.\nNo es posible continuar.", volver: 1)
            
        }
        
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
		
		if ubicacionActual == nil && userLocation.location.horizontalAccuracy < 20 {
			
            ubicacionActual = userLocation.location
            
			mapaView.setRegion(MKCoordinateRegionMake(userLocation.coordinate, MKCoordinateSpanMake(0.04, 0.04)), animated: true)

            if mostroComisarias == true {

                UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut | .BeginFromCurrentState, animations: {
                    
                    self.statusLabel.alpha = 0
                    
                    }, completion: nil)
                
                cargaComisariaCercanaYMovil()
                
            }
            
		}
		
	}
	
    func cargaComisariaCercanaYMovil() {
        
        if ubicacionActual != nil {
        
            var parametros = [["latitud":"\(ubicacionActual!.coordinate.latitude)"],["longitud":"\(ubicacionActual!.coordinate.longitude)"]]
            soapea("comisaria_cercana", parametros) { (respuesta, error) in
                
                if error == nil {
                    
                    if respuesta[0].count > 0, let direccion = respuesta[0]["ubicacion"] {

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

                    } else {
                        
                        println("No se encontro la comisaria más cercana")
                        
                    }
                    
                } else {
                    
                    println("No se encontro la comisaria más cercana")
                    println(error)
                    
                }
                
            }
            
            parametros = [["latitud":"\(ubicacionActual!.coordinate.latitude)"],["longitud":"\(ubicacionActual!.coordinate.longitude)"]]
            soapea("movilpolicial_lat_lng", parametros) { (respuesta, error) in
                
                if error == nil {
                    
                    if respuesta.count > 0 && respuesta[0]["return"] != "NO" {
                        
                        self.emergenciaLabel.text = "En caso de emergencia, el teléfono celular del móvil policial más cercano es: "
                        self.emergenciaBoton.setTitle(respuesta[0]["return"], forState: UIControlState.Normal)
                        
                        UIView.animateWithDuration(0.6, delay: 0.0, options: .CurveEaseOut, animations: {
                            
                            self.emergenciaView.alpha = 1
                            self.emergenciaView.userInteractionEnabled = true
                            
                            }, completion: nil)
                        
                    } else {
                        
                        //						println("No se encontro el movil más cercano")
                        
                    }
                    
                } else {
                    
                    //					println("No se encontro el movil más cercano")
                    //					println(error)
                    
                }
                
            }

        }
            
    }
    
	deinit {
//		println("deinit")
	}
	
	func alertaLocalizacion() {
		
		UIView.animateWithDuration(0.4, delay: 0, options: .CurveEaseOut, animations: {
			
			self.sinUbicacionLabel.alpha = 1
			self.statusLabel.alpha = 0
			
			}, completion: nil)
		
		var alertController = UIAlertController (title: "Acceso a la localización", message: "Para mostrar la comisaría más cercana a tu ubicación, es necesario que permitas el acceso a la localización desde esta aplicación.\n\nPodes permitir el acceso desde \"Ajustes\".", preferredStyle: .Alert)
		
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
			
			UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
				
				self.statusLabel.alpha = 1
				self.sinUbicacionLabel.alpha = 0
				
				}, completion: nil)
			
			self.mapaView.showsUserLocation = true
			
		} else {
			
			locationManager.requestWhenInUseAuthorization()
			
		}
		
	}
	
	override func viewDidDisappear(animated: Bool) {
		
		super.viewDidDisappear(animated)
				
		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		appDelegate.arrayVC.removeValueForKey("informacionComisarias")
		
		locationManager.stopUpdatingLocation()
		locationManager.delegate = nil
		mapaView.delegate = nil
		
		self.removeFromParentViewController()
		
	}
	
}