//
//  PlayasPlayaViewController.swift
//  GT1
//
//  Created by Pablo Pasqualino on 4/4/15.
//  Copyright (c) 2015 Pablo Pasqualino. All rights reserved.
//

import UIKit
import MapKit
import AddressBook

class PlayasPlayaViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate, CLLocationManagerDelegate, SWRevealViewControllerDelegate {
	
	@IBOutlet weak var tabla: UITableView!
	
	@IBOutlet weak var mapaCerrarBoton: UIButton!
	@IBOutlet weak var mapaComoLlegarBoton: UIButton!
	@IBOutlet weak var mapaPasoAPasoBoton: UIButton!
	@IBOutlet weak var statusLabel: UILabel!

	var mapa: MKMapView!
	
	let locationManager = CLLocationManager()

	var playa: Lugar!
	var cellMapa: PlayasPlayaMapaTableViewCell!

	var ubicacionActual: CLLocation?
	let mapManager = MapManager()
	var mapaDestino: MKPlacemark?
	var mapaRoute: MKPolyline?
	var mapaPin: MKPointAnnotation?

	override func viewDidLoad() {
		super.viewDidLoad()
		
		locationManager.delegate = self
		
		locationManager.desiredAccuracy = kCLLocationAccuracyBest

		restea("Playa","Detalle",["Token":"01234567890123456789012345678901","IdLugar":playa.id]) { (request, response, JSON, error) in
			
			if error == nil, let info = JSON as? NSDictionary {
				
				self.playa.detalle = info
				
				Lugar.armaInfo(self.playa)
				Lugar.armaObservaciones(self.playa)
				
			} else {
				
				self.playa.info = NSAttributedString(string: "No fue posible cargar esta información.", attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue", size: 13.0)!])
				self.playa.observaciones = NSAttributedString(string: "No fue posible cargar las observaciones.", attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue", size: 13.0)!])
				
			}
			
			self.tabla.reloadRowsAtIndexPaths([NSIndexPath(forRow: 3, inSection: 0),NSIndexPath(forRow: 4, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
				
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

		if playa.latitud != 0 {

			let playaCoordinate = CLLocationCoordinate2DMake(playa.latitud,playa.longitud)
			let region = MKCoordinateRegionMakeWithDistance(playaCoordinate, 800, 800)
			
			let annotation = MKPointAnnotation()
			annotation.coordinate = playaCoordinate
			annotation.title = playa.nombre
			annotation.subtitle = "\(playa.calleNombre) \(playa.calleAltura)"
			
			mapa.setRegion(region, animated: false)
			mapa.addAnnotation(annotation)
			
			mapaPin = annotation

			let options = MKMapSnapshotOptions()
			options.region = region
			options.size = mapa.frame.size
			options.scale = UIScreen.mainScreen().scale
			
			let snapshotter = MKMapSnapshotter(options: options)
			snapshotter.startWithCompletionHandler() {
				snapshot, error in
				
				if error != nil {
//					println(error)
					return
				}
				
				let image = snapshot.image
				
				let finalImageRect = CGRectMake(0, 0, image.size.width, image.size.height)
				
				let pin = MKPinAnnotationView(annotation: nil, reuseIdentifier: "")
				
				let pinImage = pin.image
				
				UIGraphicsBeginImageContextWithOptions(image.size, true, image.scale);
				
				image.drawAtPoint(CGPointMake(0, 0))
				
				var point = snapshot.pointForCoordinate(playaCoordinate)
				
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
		
		ubicacionActual = locations.last as? CLLocation
	
		if statusLabel.alpha == 1 {
			
			UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
				
				self.statusLabel.alpha = 0
				
				}, completion: nil)
			
			mapaComoLlegar()
			
		}
		
	}
	
	@IBAction func mapaCerrar() {
		
		let rectInTableView = tabla.rectForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0))
		let rectInSuperview = tabla.convertRect(rectInTableView, toView: tabla.superview)
		
		mapa.zoomEnabled = false
		mapa.rotateEnabled = false
		mapa.scrollEnabled = false
		
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
								
								let region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(self.playa.latitud,self.playa.longitud), 800, 800)
								self.mapa.setRegion(region, animated: false)
								
						})
						
				})
				
		})
		
	}
	
	func mapaAbrir() {
		
		self.view.bringSubviewToFront(mapa)
		self.view.bringSubviewToFront(mapaCerrarBoton)
		self.view.bringSubviewToFront(mapaComoLlegarBoton)
		self.view.bringSubviewToFront(mapaPasoAPasoBoton)
		self.view.bringSubviewToFront(statusLabel)

		let rectInTableView = tabla.rectForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0))
		let rectInSuperview = tabla.convertRect(rectInTableView, toView: tabla.superview)
		
		mapa.frame.origin.y = rectInSuperview.origin.y //- self.topLayoutGuide.length
		self.view.layoutIfNeeded()
		
		mapa.zoomEnabled = true
		mapa.rotateEnabled = true
		mapa.scrollEnabled = true
		
		mapa.alpha = 1
		
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
		
		if !hayRed() {
			
			muestraError("No se detecta conección a Internet.\nNo es posible continuar.", volver: 0)
			
		} else {
			
			if ubicacionActual != nil {

				IJProgressView.shared.showProgressView(self.view, padding: false, texto: "Calculando recorrido ...")
				
				UIView.animateWithDuration(0.5, delay: 0, options: .CurveEaseOut, animations: {
					
					self.mapaComoLlegarBoton.alpha = 0.5
					self.mapaComoLlegarBoton.userInteractionEnabled = false
					
					}, completion: nil)
				
				let origin = ubicacionActual!.coordinate
				let destination = CLLocationCoordinate2DMake(playa.latitud, playa.longitud)
				
				mapManager.directionsUsingGoogle(from: origin, to: destination) { [weak self] (route,directionInformation, boundingRegion, error) -> () in
					
					if self!.revealViewController() != nil {
						
						dispatch_async(dispatch_get_main_queue()) {
							
							IJProgressView.shared.hideProgressView()
							
						}
						
					}
					
					if error != nil {
						
						self!.muestraError("No se pudo encontrar el recorrido.",volver: 0)
//						println(error)
						
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
							pointOfDestination.title = self!.playa.nombre
							pointOfDestination.subtitle = "\(self!.playa.calleNombre) \(self!.playa.calleAltura)"
							
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
								String(kABPersonAddressStreetKey): "\(self!.playa.calleNombre) \(self!.playa.calleAltura)",
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
	}
	
	func alertaLocalizacion() {
		
		var alertController = UIAlertController (title: "Acceso a la localización", message: "Para mostrar la ruta hasta la playa, es necesario que permitas el acceso a la localización desde esta aplicación.\n\nPodes permitir el acceso desde \"Ajustes\".", preferredStyle: .Alert)
		
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
		
		let destino = MKMapItem(placemark: mapaDestino!)
		
		destino.name = playa.nombre
		if playa.telefono1 != "" || playa.telefono2 != "" || playa.telefono3 != "" {
			
			destino.phoneNumber = playa.telefono1 ?? playa.telefono2 ?? playa.telefono3
			
		}
		if playa.web != "" { destino.url = NSURL(string: playa.web) }
		
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
		return 5
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		var idCell = ""
		
		if indexPath.row == 0 {
			idCell = "playaFotos"
		} else if indexPath.row == 1 {
			idCell = "playaEncabezado"
		} else if indexPath.row == 2 {
			idCell = "playaMapa"
		} else if indexPath.row == 3 {
			idCell = "playaInformacion"
		} else if indexPath.row == 4 {
			idCell = "playaObservaciones"
		}
		
		if indexPath.row == 0 {
			
			let cell = tableView.dequeueReusableCellWithIdentifier(idCell, forIndexPath: indexPath) as! PlayasPlayaFotosTableViewCell
			
			if playa.foto != "" {
				
				if playa.fotoCache != nil {

					cell.foto.image = playa.fotoCache!
					cell.foto.frame.size.width = 320
					cell.foto.frame.size.height = 200
					
					UIView.animateWithDuration(1.0, delay: 0.0, options: .CurveEaseOut, animations: {
						
						cell.foto.alpha = 1
						
						}, completion: nil)
					
				} else {
					
					IJProgressView.shared.showProgressView(cell, padding: false)
					
					let urlImagen = playa.foto.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
					
					if urlImagen != "" {
						
						let imgURL = NSURL(string: urlImagen!)
						
						let request: NSURLRequest = NSURLRequest(URL: imgURL!)
						NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
							
							if error == nil {
								
								self.playa.fotoCache = UIImage(data: data)
								
								dispatch_async(dispatch_get_main_queue(), {
									
									if let cellVisible = self.tabla.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as? PlayasPlayaFotosTableViewCell {
										
										if self.revealViewController() != nil { IJProgressView.shared.hideProgressView() }
										cellVisible.foto.image = self.playa.fotoCache
										
										UIView.animateWithDuration(1.0, delay: 0.0, options: .CurveEaseOut, animations: {
											
											cellVisible.foto.alpha = 1
											
											}, completion: nil)
										
									}
								})
								
							} else {
								
//								println("Error para bajar la imagen")
								
							}
						})
						
					}
					
				}
				
			}
			
			return cell
			
		} else if indexPath.row == 1 {
			
			let cell = tableView.dequeueReusableCellWithIdentifier(idCell, forIndexPath: indexPath) as! PlayasPlayaDatosTableViewCell
			
			cell.playaNombre.text = playa.nombre
			cell.playaDireccion.text = playa.calleNombre + " " + playa.calleAltura
			cell.playaTelefonoLink.setTitle((playa.telefono1 ?? playa.telefono2 ?? playa.telefono3 ?? "No disponible"), forState: .Normal)
			cell.playaTelefonoLink.addTarget(self, action: "botonTel:", forControlEvents: .TouchUpInside)
			cell.playaTelefonoLink.titleLabel!.adjustsFontSizeToFitWidth = true
			cell.playaTelefonoLink.titleLabel!.minimumScaleFactor = 0.7
			cell.playaEmailLink.setTitle(playa.email, forState: .Normal)
			cell.playaEmailLink.addTarget(self, action: "botonEmail:", forControlEvents: .TouchUpInside)
			cell.playaEmailLink.titleLabel!.adjustsFontSizeToFitWidth = true
			cell.playaEmailLink.titleLabel!.minimumScaleFactor = 0.7
			cell.playaWebLink.setTitle(playa.web, forState: .Normal)
			cell.playaWebLink.addTarget(self, action: "botonWeb:", forControlEvents: .TouchUpInside)
			cell.playaWebLink.titleLabel!.adjustsFontSizeToFitWidth = true
			cell.playaWebLink.titleLabel!.minimumScaleFactor = 0.7
			
			return cell
			
		} else if indexPath.row == 2 {
			
			let cell = tableView.dequeueReusableCellWithIdentifier(idCell, forIndexPath: indexPath) as! PlayasPlayaMapaTableViewCell
			
			cellMapa = cell
			
			return cell
			
		} else if indexPath.row == 3 {
			
			let cell = tableView.dequeueReusableCellWithIdentifier(idCell, forIndexPath: indexPath) as! PlayasPlayaInfoTableViewCell
			
			cell.texto.attributedText = playa.info
			
			return cell
			
		} else if indexPath.row == 4 {
			
			let cell = tableView.dequeueReusableCellWithIdentifier(idCell, forIndexPath: indexPath) as! PlayasPlayaObservacionesTableViewCell
			
			cell.texto.attributedText = playa.observaciones
			
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
			
			if playa.foto != "" {
				
				return 200
				
			} else {
				
				return 0
				
			}
			
		} else if indexPath.row == 1 {
			
			return 142
			
		} else if indexPath.row == 2 {
			
			if playa.latitud != 0 {
				
				return 200
				
			} else {
				
				return 0
				
			}
			
		} else if indexPath.row == 3 || indexPath.row == 4 {
			
			let texto: NSAttributedString!
			
			if indexPath.row == 3 {
				
				texto = playa.info
				
			} else {
				
				texto = playa.observaciones
				
			}
						
			let height = heightForView(texto, (self.view.frame.size.width - 16))
			
			return height + 16 + 28 // 16 de padding top y bottom + 28 por el height del view para el título
			
		}
		
		return 50
		
	}
	
	override func viewDidDisappear(animated: Bool) {
		
		super.viewDidDisappear(animated)
		
		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		appDelegate.arrayVC.removeValueForKey("playasPlaya")
		
		mapa.delegate = nil

		IJProgressView.shared.hideProgressView()

		self.removeFromParentViewController()
		
	}
	
	deinit {
//		println("deinit")
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
}