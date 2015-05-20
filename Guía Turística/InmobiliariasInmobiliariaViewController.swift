//
//  InmobiliariasInmobiliariaViewController.swift
//  GT1
//
//  Created by Pablo Pasqualino on 4/4/15.
//  Copyright (c) 2015 Pablo Pasqualino. All rights reserved.
//

import UIKit
import MapKit
import AddressBook

class InmobiliariasInmobiliariaViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate, CLLocationManagerDelegate, SWRevealViewControllerDelegate {
	
	@IBOutlet weak var tabla: UITableView!
	
	@IBOutlet weak var mapaCerrarBoton: UIButton!
	@IBOutlet weak var mapaComoLlegarBoton: UIButton!
	@IBOutlet weak var mapaPasoAPasoBoton: UIButton!
	@IBOutlet weak var statusLabel: UILabel!
	
	var mapa: MKMapView!
	
	let locationManager = CLLocationManager()
	
	var inmobiliaria: Lugar!
	var cellMapa: InmobiliariasInmobiliariaMapaTableViewCell!
	
	var ubicacionActual: CLLocationCoordinate2D?
	let mapManager = MapManager()
	var mapaDestino: MKPlacemark?
	var mapaRoute: MKPolyline?
	var mapaPin: MKPointAnnotation?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		locationManager.delegate = self
		
		locationManager.desiredAccuracy = kCLLocationAccuracyBest

		restea("Inmobiliaria","Detalle",["Token":"01234567890123456789012345678901","IdLugar":inmobiliaria.id]) { (request, response, JSON, error) in
			
			if error == nil, let info = JSON as? NSDictionary {
				
				self.inmobiliaria.detalle = info
				
				Lugar.armaInfo(self.inmobiliaria)
				Lugar.armaObservaciones(self.inmobiliaria)
				
				self.tabla.reloadRowsAtIndexPaths([NSIndexPath(forRow: 2, inSection: 0),NSIndexPath(forRow: 3, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
				
			}
			
		}
		
		mapa = MKMapView()
		
		mapa.frame = CGRectMake(0, -300, self.view.frame.size.width, 200)
		mapa.mapType = MKMapType.Standard
		self.view.addSubview(mapa)
		
		mapa.delegate = self
		
		mapaComoLlegarBoton.layer.cornerRadius = 5
		mapaPasoAPasoBoton.layer.cornerRadius = 5
		statusLabel.layer.cornerRadius = 7
		statusLabel.clipsToBounds = true

		if self.inmobiliaria.latitud != 0 {
		
			let inmobiliariaCoordinate = CLLocationCoordinate2DMake(self.inmobiliaria.latitud,self.inmobiliaria.longitud)
			let region = MKCoordinateRegionMakeWithDistance(inmobiliariaCoordinate, 800, 800)
			
			let annotation = MKPointAnnotation()
			annotation.coordinate = inmobiliariaCoordinate
			annotation.title = self.inmobiliaria.nombre
			annotation.subtitle = "\(self.inmobiliaria.calleNombre) \(self.inmobiliaria.calleAltura)"
			
			mapa.setRegion(region, animated: false)
			mapa.addAnnotation(annotation)
			
			mapaPin = annotation
			
			let options = MKMapSnapshotOptions()
			options.region = region
			options.size = self.mapa.frame.size
			options.scale = UIScreen.mainScreen().scale
			
			let snapshotter = MKMapSnapshotter(options: options)
			snapshotter.startWithCompletionHandler() {
				snapshot, error in
				
				if error != nil {
					println(error)
					return
				}
				
				let image = snapshot.image
				
				let finalImageRect = CGRectMake(0, 0, image.size.width, image.size.height)
				
				let pin = MKPinAnnotationView(annotation: nil, reuseIdentifier: "")
				
				let pinImage = pin.image
				
				UIGraphicsBeginImageContextWithOptions(image.size, true, image.scale);
				
				image.drawAtPoint(CGPointMake(0, 0))
				
				var point = snapshot.pointForCoordinate(inmobiliariaCoordinate)
				
				if CGRectContainsPoint(finalImageRect, point) {
					
					let pinCenterOffset = pin.centerOffset
					point.x -= pin.bounds.size.width / 2.0;
					point.y -= pin.bounds.size.height / 2.0;
					point.x += pinCenterOffset.x;
					point.y += pinCenterOffset.y;
					
					pinImage.drawAtPoint(point)
					
				}
				
				let finalImage = UIGraphicsGetImageFromCurrentImageContext();
				UIGraphicsEndImageContext();
				
				dispatch_async(dispatch_get_main_queue()) {
					
					self.cellMapa.imagenMapa.image = finalImage
					
					self.cellMapa.imagenMapa.frame.size.width = self.view.frame.size.width
					self.cellMapa.imagenMapa.frame.size.height = finalImage.size.height
					
					UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseOut, animations: {
						
						self.cellMapa.imagenMapa.alpha = 1
						
						}, completion: nil)
					
					let tap = UITapGestureRecognizer(target: self,action: "mapaAbrir")
					tap.numberOfTapsRequired = 1
					self.cellMapa.addGestureRecognizer(tap)
					
				}
				
			}
			
		}
			
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		armaNavegacion()
		self.revealViewController().delegate = self
		
	}
	
	func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
		
		if status == CLAuthorizationStatus.AuthorizedWhenInUse {
			locationManager.startUpdatingLocation()
		}
		
	}
	
	func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
		
		locationManager.stopUpdatingLocation()
		
		ubicacionActual = (locations.last as! CLLocation).coordinate
		
		if self.statusLabel.alpha == 1 {
			
			UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
				
				self.statusLabel.alpha = 0
				
				}, completion: nil)
			
			mapaComoLlegar()
			
		}
		
	}
	
	@IBAction func mapaCerrar() {
		
		let rectInTableView = tabla.rectForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0))
		let rectInSuperview = tabla.convertRect(rectInTableView, toView: tabla.superview)
		
		self.mapa.zoomEnabled = false
		self.mapa.rotateEnabled = false
		self.mapa.scrollEnabled = false
		
		UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseOut, animations: {
			
			self.mapaCerrarBoton.alpha = 0
			self.mapaComoLlegarBoton.alpha = 0
			self.mapaPasoAPasoBoton.alpha = 0
			self.statusLabel.alpha = 0
			self.mapaPasoAPasoBoton.userInteractionEnabled = false
			self.mapaComoLlegarBoton.userInteractionEnabled = false
			
			if self.mapaRoute != nil { self.mapa.removeOverlay(self.mapaRoute!) }
			
			for annotation in self.mapa.annotations {
				
				if let anotacion = annotation as? MKPointAnnotation {
					
					self.mapa.removeAnnotation(anotacion)
					
				}
				
			}

			self.mapa.addAnnotation(self.mapaPin!)
			
			}, completion: { finished in
				
				UIView.animateWithDuration(0.5, delay: 0, options: .CurveEaseOut, animations: {
					
					self.mapa.frame.size.height = 200
					self.mapa.frame.origin.y = rectInSuperview.origin.y //- self.topLayoutGuide.length
					
					self.view.layoutIfNeeded()
					
					}, completion: { finished in
						
						UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
							
							self.mapa.alpha = 0
							
							}, completion: { finished in
								
								self.mapa.frame.origin.y = -300
								
								self.view.layoutIfNeeded()
								
								let region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(self.inmobiliaria.latitud,self.inmobiliaria.longitud), 800, 800)
								self.mapa.setRegion(region, animated: false)
								
						})
						
				})
				
		})
		
	}
	
	func mapaAbrir() {
		
		self.view.bringSubviewToFront(self.mapa)
		self.view.bringSubviewToFront(self.mapaCerrarBoton)
		self.view.bringSubviewToFront(self.mapaComoLlegarBoton)
		self.view.bringSubviewToFront(self.mapaPasoAPasoBoton)
		self.view.bringSubviewToFront(self.statusLabel)

		let rectInTableView = tabla.rectForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0))
		let rectInSuperview = tabla.convertRect(rectInTableView, toView: tabla.superview)
		
		self.mapa.frame.origin.y = rectInSuperview.origin.y //- self.topLayoutGuide.length
		self.view.layoutIfNeeded()
		
		self.mapa.zoomEnabled = true
		self.mapa.rotateEnabled = true
		self.mapa.scrollEnabled = true
		
		self.mapa.alpha = 1
		
		UIView.animateWithDuration(0.5, delay: 0, options: .CurveEaseOut, animations: {
			
			self.mapa.frame.size.height = self.view.frame.height
			self.mapa.frame.origin.y = 0 //self.topLayoutGuide.length + self.navigationBar.frame.height
			
			self.view.layoutIfNeeded()
			
			}, completion: { finished in

				self.mapa.selectAnnotation(self.mapaPin!, animated: true)
				self.mapaComoLlegarBoton.userInteractionEnabled = true

				UIView.animateWithDuration(0.4, delay: 0, options: .CurveEaseOut, animations: {
					
					self.mapaCerrarBoton.alpha = 0.8
					self.mapaComoLlegarBoton.alpha = 0.9
					
					}, completion: nil)
				
		})
		
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
	
	@IBAction func mapaComoLlegar() {
		
		if self.ubicacionActual != nil {
		
			IJProgressView.shared.showProgressView(self.view, padding: false)
			
			UIView.animateWithDuration(0.5, delay: 0, options: .CurveEaseOut, animations: {
				
				self.mapaComoLlegarBoton.alpha = 0.5
				self.mapaComoLlegarBoton.userInteractionEnabled = false
				
				}, completion: nil)
		
			let origin = self.ubicacionActual!
			let destination = CLLocationCoordinate2DMake(self.inmobiliaria.latitud, self.inmobiliaria.longitud)
		
			self.mapManager.directionsUsingGoogle(from: origin, to: destination) { [weak self] (route,directionInformation, boundingRegion, error) -> () in
				
				if error != nil {
					
					println(error)
					
				} else {
					
					if self != nil {
						
						for annotation in self!.mapa.annotations {
							
							if let anotacion = annotation as? MKPointAnnotation {
									
								self!.mapa.removeAnnotation(anotacion)
								
							}
							
						}

						self!.mapaRoute = route!
					
						let pointOfOrigin = MKPointAnnotation()
						pointOfOrigin.title = "Tu ubicación actual"
						let duracion = directionInformation?.objectForKey("duration") as! String
						let distancia = directionInformation?.objectForKey("distance") as! String
						pointOfOrigin.subtitle = "A \(distancia) - Tiempo: \(duracion)"
						
						let pointOfDestination = MKPointAnnotation()
						pointOfDestination.title = self!.inmobiliaria.nombre
						pointOfDestination.subtitle = "\(self!.inmobiliaria.calleNombre) \(self!.inmobiliaria.calleAltura)"
						
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
							String(kABPersonAddressStreetKey): "\(self!.inmobiliaria.calleNombre) \(self!.inmobiliaria.calleAltura)",
							String(kABPersonAddressCityKey): "Mar del Plata",
							String(kABPersonAddressStateKey): "Buenos Aires",
							String(kABPersonAddressZIPKey): "7600",
							String(kABPersonAddressCountryKey): "Argentina",
							String(kABPersonAddressCountryCodeKey): "AR"
						]

						self!.mapaDestino = MKPlacemark(coordinate: coordDesitination, addressDictionary: addressDestino)
						
						dispatch_async(dispatch_get_main_queue()) {
							
							self!.mapa.addOverlay(self!.mapaRoute!)
							self!.mapa.addAnnotation(pointOfOrigin)
							self!.mapa.addAnnotation(pointOfDestination)
							self!.mapa.setVisibleMapRect(boundingRegion!, edgePadding: UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30), animated: true)
							
							if self!.revealViewController() != nil { IJProgressView.shared.hideProgressView() }
							
							UIView.animateWithDuration(0.5, delay: 0, options: .CurveEaseOut, animations: {
								
								self!.mapaPasoAPasoBoton.alpha = 0.9
								self!.mapaPasoAPasoBoton.userInteractionEnabled = true
								
								}, completion: nil)
								
						}
					}
				}
			}
		} else {
			
			if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse {
				
				UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
					
					self.statusLabel.alpha = 1
					
					}, completion: nil)
				
			} else {
				
				alertaLocalizacion()
				
			}
			
		}
	}
	
	func alertaLocalizacion() {
		
		var alertController = UIAlertController (title: "Acceso a la localización", message: "Para mostrar la ruta hasta la inmobiliaria, es necesario que permitas el acceso a la localización desde esta aplicación.\n\nPodes permitir el acceso desde \"Ajustes\".", preferredStyle: .Alert)
		
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
	
	@IBAction func mapaPasoAPaso() {
		
		let origen = MKMapItem.mapItemForCurrentLocation()
		
		let destino = MKMapItem(placemark: self.mapaDestino!)
		
		destino.name = inmobiliaria.nombre
		if inmobiliaria.telefono1 != "" || inmobiliaria.telefono2 != "" || inmobiliaria.telefono3 != "" {
			
			destino.phoneNumber = inmobiliaria.telefono1 ?? inmobiliaria.telefono2 ?? inmobiliaria.telefono3
			
		}
		if inmobiliaria.web != "" { destino.url = NSURL(string: inmobiliaria.web) }
		
		let mapItems = [origen,destino]
		
		let options = [MKLaunchOptionsDirectionsModeKey:
		MKLaunchOptionsDirectionsModeDriving]
		
		MKMapItem.openMapsWithItems(mapItems, launchOptions: options)
		
	}
	
	//MARK: UITableViewDataSource
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 4
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		var idCell = ""
		
		if indexPath.row == 0 {
			idCell = "inmobiliariaEncabezado"
		} else if indexPath.row == 1 {
			idCell = "inmobiliariaMapa"
		} else if indexPath.row == 2 {
			idCell = "inmobiliariaInformacion"
		} else if indexPath.row == 3 {
			idCell = "inmobiliariaObservaciones"
		}
		
		if indexPath.row == 0 {
			
			let cell = tableView.dequeueReusableCellWithIdentifier(idCell, forIndexPath: indexPath) as! InmobiliariasInmobiliariaDatosTableViewCell
			
			let datosNombre = inmobiliaria.nombre.componentsSeparatedByString(" - ")
			
			var titular = datosNombre.last!
			var nombre = ""
			
			if datosNombre.count > 1 {
				
				for var x = 0; x < (datosNombre.count - 1); x++ {
					
					nombre += datosNombre[x]
					if x < (datosNombre.count - 2) { nombre += " - " }
					
				}
				
			} else {
				
				nombre = titular
				titular = ""
				
			}
			
			cell.inmobiliariaNombre.text = nombre.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
			cell.inmobiliariaTitular.text = titular.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
			cell.inmobiliariaDireccion.text = inmobiliaria.calleNombre + " " + inmobiliaria.calleAltura
			cell.inmobiliariaTelefonoLink.setTitle((inmobiliaria.telefono1 ?? inmobiliaria.telefono2 ?? inmobiliaria.telefono3 ?? "No disponible"), forState: .Normal)
			cell.inmobiliariaTelefonoLink.addTarget(self, action: "botonTel:", forControlEvents: .TouchUpInside)
			cell.inmobiliariaTelefonoLink.titleLabel!.adjustsFontSizeToFitWidth = true
			cell.inmobiliariaTelefonoLink.titleLabel!.minimumScaleFactor = 0.7
			cell.inmobiliariaEmailLink.setTitle(inmobiliaria.email, forState: .Normal)
			cell.inmobiliariaEmailLink.addTarget(self, action: "botonEmail:", forControlEvents: .TouchUpInside)
			cell.inmobiliariaEmailLink.titleLabel!.adjustsFontSizeToFitWidth = true
			cell.inmobiliariaEmailLink.titleLabel!.minimumScaleFactor = 0.7
			cell.inmobiliariaWebLink.setTitle(inmobiliaria.web, forState: .Normal)
			cell.inmobiliariaWebLink.addTarget(self, action: "botonWeb:", forControlEvents: .TouchUpInside)
			cell.inmobiliariaWebLink.titleLabel!.adjustsFontSizeToFitWidth = true
			cell.inmobiliariaWebLink.titleLabel!.minimumScaleFactor = 0.7
			
			return cell
			
		} else if indexPath.row == 1 {
			
			let cell = tableView.dequeueReusableCellWithIdentifier(idCell, forIndexPath: indexPath) as! InmobiliariasInmobiliariaMapaTableViewCell
			
			cellMapa = cell
			
			return cell
			
		} else if indexPath.row == 2 {
			
			let cell = tableView.dequeueReusableCellWithIdentifier(idCell, forIndexPath: indexPath) as! InmobiliariasInmobiliariaInfoTableViewCell
			
			cell.texto.attributedText = inmobiliaria.info
			
			return cell
			
		} else if indexPath.row == 3 {
			
			let cell = tableView.dequeueReusableCellWithIdentifier(idCell, forIndexPath: indexPath) as! InmobiliariasInmobiliariaObservacionesTableViewCell
			
			cell.texto.attributedText = inmobiliaria.observaciones
			
			return cell
			
		}
		
		return UITableViewCell()
	}
	
	func botonTel(sender: UIButton!) {
		
		if let numero = sender.titleLabel?.text where numero != "No disponible" {
			
			if let url = NSURL(string: "tel://\(numero)") {
				
				UIApplication.sharedApplication().openURL(url)
				
			}
			
		}
		
	}
	
	func botonEmail(sender: UIButton!) {
		
		if let email = sender.titleLabel?.text {
			
			if let url = NSURL(string: "mailto://\(email)") {
				
				UIApplication.sharedApplication().openURL(url)
				
			}
			
		}
		
	}
	
	func botonWeb(sender: UIButton!) {
		
		if let web = sender.titleLabel?.text {
			
			if let url = NSURL(string: "http://\(web)") {
				
				UIApplication.sharedApplication().openURL(url)
				
			}
			
		}
		
	}
	
	//MARK: UITableViewDelegate
	
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		
		if indexPath.row == 0 {
			
			return 130
			
		} else if indexPath.row == 1 {
			
			if inmobiliaria.latitud != 0 {
			
				return 200
				
			} else {
				
				return 0
				
			}
			
		} else if indexPath.row == 2 || indexPath.row == 3 {
			
			let texto: NSAttributedString!
			
			if indexPath.row == 2 {
				
				texto = self.inmobiliaria.info
				
			} else {
				
				texto = self.inmobiliaria.observaciones
				
			}
			
			let font = UIFont(name: "HelveticaNeue", size: 13.0)!
			
			let height = heightForView(texto, width: (self.view.frame.size.width - 16))
			
			return height + 16 + 28 // 16 de padding top y bottom + 28 por el height del view para el título
			
		}
		
		return 50
		
	}
	
	override func viewDidDisappear(animated: Bool) {
		
		super.viewDidDisappear(animated)
		
		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		appDelegate.arrayVC.removeValueForKey("inmobiliariasInmobiliaria")
		
		mapa.delegate = nil
		
		IJProgressView.shared.hideProgressView()

		self.removeFromParentViewController()
		
	}
	
	deinit {
		println("deinit")
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
}