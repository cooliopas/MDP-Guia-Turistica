//  InformacionFarmaciasViewController.swift
//  GT1
//
//  Created by Pablo Pasqualino on 3/26/15.
//  Copyright (c) 2015 Pablo Pasqualino. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import SwiftyJSON
import Alamofire

class InformacionFarmaciasViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, SWRevealViewControllerDelegate {
	
	@IBOutlet weak var mapaView: MKMapView!
	@IBOutlet weak var segmentadorTipo: UISegmentedControl!
	
	@IBOutlet weak var avisoFarmaciasDeTurnoView: UIView!
	@IBOutlet weak var avisoFarmaciasDeTurnoLabel: UILabel!
	@IBOutlet weak var statusLabel: UILabel!
	
	var linea: String!
	
	let locationManager = CLLocationManager()
	
	var ubicacionActual: CLLocation?
	
	let mapManager = MapManager()
	
	var farmacias: [Farmacia] = []
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if hayRed() {
		
			locationManager.delegate = self
			
			if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse {
				mapaView.showsUserLocation = true
			}
			
			mapaView.delegate = self

			// leemos todas las farmacias
			
			if let file = NSBundle.mainBundle().pathForResource("Varios.bundle/farmacias", ofType: "json"),
				let data = NSData(contentsOfFile: file),
				let listadoFarmacias = JSON(data:data).array {
					
					for farmacia in listadoFarmacias {
						
						farmacias.append(Farmacia(coordenadas: CLLocationCoordinate2DMake(farmacia[3].doubleValue,farmacia[4].doubleValue), nombre: farmacia[0].stringValue, direccion: farmacia[1].stringValue, direccionDeTurno: farmacia[5].stringValue,tipo: 0))
						
					}
					
			}
			
			// preparamos farmacias de turno
			
			segmentadorTipo.setEnabled(false, forSegmentAtIndex: 0)
			
			let hora = NSCalendar.currentCalendar().components(.CalendarUnitHour | .CalendarUnitMinute, fromDate: NSDate()).hour
			
			let dateFormatter = NSDateFormatter()
			dateFormatter.dateFormat = "dd/MM/yyyy"
			let fechaHoy = dateFormatter.stringFromDate(NSDate())
			
			let fechaTurno: String
			
			if hora >= 9 { // pedimos el listado de farmacias de turno de acuerdo a la hora actual
				
				fechaTurno = dateFormatter.stringFromDate(NSDate()) // si es después de las 9am, pedimos el listado de farmacias del día actual
				avisoFarmaciasDeTurnoLabel.text = "Farmacias de turno para HOY (\(fechaHoy)) desde las 9:00 hs."
				
			} else {
				
				fechaTurno = dateFormatter.stringFromDate(NSDate().dateByAddingTimeInterval(-86400)) // si es antes de las 9am, pedimos el listado del día anterior
				avisoFarmaciasDeTurnoLabel.text = "Farmacias de turno para HOY (\(fechaHoy)) hasta las 9:00 hs."
				
			}
			
			Alamofire.request(.GET, "http://www.colfarmamdp.com.ar/farmaturno3.php?fecha=\(fechaTurno)").responseJSON { (req, res, json, error) in
				
				if (error == nil) {
					
					let farmaciasDeTurno = JSON(json!).arrayValue
					
					if farmaciasDeTurno.count > 0 {
						
						self.segmentadorTipo.setEnabled(true, forSegmentAtIndex: 0)
						
					}
					
					for farmaciaDeTurno in farmaciasDeTurno {

						let direccion = farmaciaDeTurno["address"]
						let direccionString = "\(direccion)".stringByReplacingOccurrencesOfString(",MAR DEL PLATA,ARGENTINA", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
						
						for farmacia in self.farmacias {
							
							if farmacia.direccionDeTurno == direccionString {
								
								farmacia.tipo = 1
															
							}
							
						}
						
					}
					
				} else {
					
//					println("No se pudieron cargar las farmacias de turno.")
//					println(req)
//					println(res)
					
				}
				
			}
			
			mapaView.setRegion(MKCoordinateRegionMake(CLLocationCoordinate2DMake(-37.995526,-57.552260), MKCoordinateSpanMake(0.005, 0.005)), animated: false)
			mostrarFarmacias(segmentadorTipo.selectedSegmentIndex)
			
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
    
	func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
		
		if annotation is MKUserLocation {
			
			return nil
			
		} else {
			
			let imagen = UIImage(named: "farmacias")
			
			var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("farmacias")
			
			if annotationView != nil {
				
				annotationView.annotation = annotation
				
			} else {
				
				annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "farmacias")
				
			}
			
			annotationView.canShowCallout = true
			annotationView.image = imagen
			annotationView.centerOffset = CGPointMake(0, -16)
			
			return annotationView
			
		}
		
	}
	
	@IBAction func mostrarFarmaciasActualiza() {
		
		if segmentadorTipo.selectedSegmentIndex == 1 && ubicacionActual == nil {
			
			if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse {
				
				UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
					
					self.statusLabel.alpha = 1
					
					}, completion: nil)
				
			} else {
				
				segmentadorTipo.selectedSegmentIndex = 2
				alertaLocalizacion()
				
			}
			
		} else {

			UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
				
				self.statusLabel.alpha = 0
				
				}, completion: nil)
			
			mostrarFarmacias(segmentadorTipo.selectedSegmentIndex)
			
			if segmentadorTipo.selectedSegmentIndex == 1 {
				
                var arrayCoordenadasAnnotations = [CLLocationCoordinate2D]()
                
                if ubicacionActual != nil {
                    
                    arrayCoordenadasAnnotations.append(ubicacionActual!.coordinate)
                    
                }
                
                for annotation in self.mapaView.annotations {
                    
                    if let annotation = annotation as? MKPointAnnotation {
                        
                        arrayCoordenadasAnnotations.append(annotation.coordinate)
                        
                    }
                    
                }
                
                mapaView.setRegion(regionIncluyendoCoordenadas(arrayCoordenadasAnnotations), animated: true)
                
			}
			
		}
		
		if segmentadorTipo.selectedSegmentIndex == 0 {
			
			UIView.animateWithDuration(0.6, delay: 0.0, options: .CurveEaseOut, animations: {
				
				self.avisoFarmaciasDeTurnoView.alpha = 0.8
				
				}, completion: nil)
            
            var arrayCoordenadasAnnotations = [CLLocationCoordinate2D]()
            
            if ubicacionActual != nil {
                
                arrayCoordenadasAnnotations.append(ubicacionActual!.coordinate)
                
            }
            
            for annotation in self.mapaView.annotations {
                
                if let annotation = annotation as? MKPointAnnotation {
                    
                    arrayCoordenadasAnnotations.append(annotation.coordinate)
                    
                }
                
            }
            
            mapaView.setRegion(regionIncluyendoCoordenadas(arrayCoordenadasAnnotations), animated: true)
			
		} else {
			
			UIView.animateWithDuration(0.6, delay: 0.0, options: .CurveEaseOut, animations: {
				
				self.avisoFarmaciasDeTurnoView.alpha = 0
				
				}, completion: nil)
			
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
    
	func sorterForDistancia(this:Farmacia, that:Farmacia) -> Bool {
		if this.distancia == nil {
			return false
		} else if that.distancia == nil {
			return true
		} else {
			return this.distancia! < that.distancia!
		}
	}
	
	func mostrarFarmacias(tipo: Int) {
		
		for annotation in mapaView.annotations {
			
			if annotation is MKAnnotation {
				
				mapaView.removeAnnotation(annotation as! MKAnnotation)
				
			}
			
		}
		
		if tipo == 1 && ubicacionActual != nil { farmacias.sort(sorterForDistancia) }
		
		var farmaciasMostradas = 0
		
		for farmacia in farmacias {
			
			if tipo > 0 || (tipo == 0 && farmacia.tipo == 1) {
			
				let annotation = MKPointAnnotation()
				annotation.coordinate = farmacia.coordenadas
				annotation.title = farmacia.nombre
				annotation.subtitle = farmacia.direccion
				
				mapaView.addAnnotation(annotation)
				
				farmaciasMostradas++
				
				if tipo == 1 && farmaciasMostradas == 10 { break }

			}
				
		}
		
	}
	
	func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {

		if userLocation.location.horizontalAccuracy < 20 && (ubicacionActual == nil || ubicacionActual!.distanceFromLocation(userLocation.location) > 100) {
			
			if ubicacionActual == nil {
				
				mapaView.setRegion(MKCoordinateRegionMake(userLocation.coordinate, MKCoordinateSpanMake(0.04, 0.04)), animated: true)
				
			}
			
			ubicacionActual = userLocation.location
			
			for farmacia in farmacias {
				
				farmacia.distancia = ubicacionActual!.distanceFromLocation(CLLocation(latitude: farmacia.coordenadas.latitude,longitude: farmacia.coordenadas.longitude))
				
			}
			
			if segmentadorTipo.selectedSegmentIndex == 1 {
			
				mostrarFarmacias(segmentadorTipo.selectedSegmentIndex)
				
			}

			if statusLabel.alpha == 1 {

				UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {

					self.statusLabel.alpha = 0

					}, completion: nil)

			}

		}

	}
	
	deinit {
//		println("deinit")
	}
	
	func alertaLocalizacion() {
		
		var alertController = UIAlertController (title: "Acceso a la localización", message: "Para mostrar las farmacias más cercanas a tu ubicación, es necesario que permitas el acceso a la localización desde esta aplicación.\n\nPodes permitir el acceso desde \"Ajustes\".", preferredStyle: .Alert)
		
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
		
		if status == CLAuthorizationStatus.AuthorizedWhenInUse {
			mapaView.showsUserLocation = true
		} else {
			locationManager.requestWhenInUseAuthorization()
		}
		
	}
	
	override func viewDidDisappear(animated: Bool) {
		
		super.viewDidDisappear(animated)
				
		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		appDelegate.arrayVC.removeValueForKey("informacionFarmacias")
		
		locationManager.stopUpdatingLocation()
		locationManager.delegate = nil
		mapaView.delegate = nil
		
		self.removeFromParentViewController()
		
	}
	
}