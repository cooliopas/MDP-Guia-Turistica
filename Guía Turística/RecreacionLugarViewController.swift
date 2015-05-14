//
//  RecreacionLugarViewController.swift
//  GT1
//
//  Created by Pablo Pasqualino on 4/4/15.
//  Copyright (c) 2015 Pablo Pasqualino. All rights reserved.
//

import UIKit
import MapKit
import AddressBook

class RecreacionLugarViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate, SWRevealViewControllerDelegate {
	
	@IBOutlet weak var tabla: UITableView!
	
	@IBOutlet weak var mapaCerrarBoton: UIButton!
	@IBOutlet weak var mapaComoLlegarBoton: UIButton!
	@IBOutlet weak var mapaPasoAPasoBoton: UIButton!

	var mapa: MKMapView!
	
	let locationManager = LocationManager.sharedInstance

	var lugar: Lugar!
	var cellMapa: RecreacionLugarMapaTableViewCell!

	var ubicacionActual: CLLocationCoordinate2D?
	let mapManager = MapManager()
	var mapaDestino: MKPlacemark?
	var mapaRoute: MKPolyline?
	var mapaPin: MKPointAnnotation?

	override func viewDidLoad() {
		super.viewDidLoad()
		
		restea("Recreacion","Detalle",["Token":"01234567890123456789012345678901","IdLugar":lugar.id]) { (request, response, JSON, error) in
			
			if error == nil, let info = JSON as? NSDictionary {
				
				self.lugar.detalle = info
				
				Lugar.armaInfo(self.lugar)
				Lugar.armaObservaciones(self.lugar)
				
				self.tabla.reloadRowsAtIndexPaths([NSIndexPath(forRow: 3, inSection: 0),NSIndexPath(forRow: 4, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
				
			}
			
		}
		
		mapa = MKMapView()
		
		mapa.frame = CGRectMake(0, -300, self.view.frame.size.width, 200)
		mapa.mapType = MKMapType.Standard
		self.view.addSubview(mapa)
		
		mapa.delegate = self
		
		mapaComoLlegarBoton.layer.cornerRadius = 5
		mapaPasoAPasoBoton.layer.cornerRadius = 5
		
		locationManager.autoUpdate = true
		locationManager.startUpdatingLocationWithCompletionHandler { [weak self] (latitude, longitude, status, verboseMessage, error) -> () in
			
			if self != nil {
				
				self!.ubicacionActual = CLLocationCoordinate2DMake(latitude, longitude)
				self!.locationManager.stopUpdatingLocation()
				
			}
			
		}

		if self.lugar.latitud != 0 {

			let lugarCoordinate = CLLocationCoordinate2DMake(self.lugar.latitud,self.lugar.longitud)
			let region = MKCoordinateRegionMakeWithDistance(lugarCoordinate, 800, 800)
			
			let annotation = MKPointAnnotation()
			annotation.coordinate = lugarCoordinate
			annotation.title = self.lugar.nombre
			annotation.subtitle = "\(self.lugar.calleNombre) \(self.lugar.calleAltura)"
			
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
				
				var point = snapshot.pointForCoordinate(lugarCoordinate)
				
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
	
	@IBAction func mapaCerrar() {
		
		let rectInTableView = tabla.rectForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0))
		let rectInSuperview = tabla.convertRect(rectInTableView, toView: tabla.superview)
		
		self.mapa.zoomEnabled = false
		self.mapa.rotateEnabled = false
		self.mapa.scrollEnabled = false
		
		UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseOut, animations: {
			
			self.mapaCerrarBoton.alpha = 0
			self.mapaComoLlegarBoton.alpha = 0
			self.mapaPasoAPasoBoton.alpha = 0
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
								
								let region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(self.lugar.latitud,self.lugar.longitud), 800, 800)
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
		
		let rectInTableView = tabla.rectForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0))
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
			let destination = CLLocationCoordinate2DMake(self.lugar.latitud, self.lugar.longitud)
			
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
						pointOfDestination.title = self!.lugar.nombre
						pointOfDestination.subtitle = "\(self!.lugar.calleNombre) \(self!.lugar.calleAltura)"
						
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
							String(kABPersonAddressStreetKey): "\(self!.lugar.calleNombre) \(self!.lugar.calleAltura)",
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
							
							IJProgressView.shared.hideProgressView()
							
							UIView.animateWithDuration(0.5, delay: 0, options: .CurveEaseOut, animations: {
								
								self!.mapaPasoAPasoBoton.alpha = 0.9
								self!.mapaPasoAPasoBoton.userInteractionEnabled = true
								
								}, completion: nil)
							
						}
					}
				}
			}
		}
	}
	
	@IBAction func mapaPasoAPaso() {
		
		let origen = MKMapItem.mapItemForCurrentLocation()
		
		let destino = MKMapItem(placemark: self.mapaDestino!)
		
		destino.name = lugar.nombre
		if lugar.telefono1 != "" || lugar.telefono2 != "" || lugar.telefono3 != "" {
			
			destino.phoneNumber = lugar.telefono1 ?? lugar.telefono2 ?? lugar.telefono3
			
		}
		if lugar.web != "" { destino.url = NSURL(string: lugar.web) }
		
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
			idCell = "lugarFotos"
		} else if indexPath.row == 1 {
			idCell = "lugarEncabezado"
		} else if indexPath.row == 2 {
			idCell = "lugarMapa"
		} else if indexPath.row == 3 {
			idCell = "lugarInformacion"
		} else if indexPath.row == 4 {
			idCell = "lugarObservaciones"
		}
		
		if indexPath.row == 0 {
			
			let cell = tableView.dequeueReusableCellWithIdentifier(idCell, forIndexPath: indexPath) as! RecreacionLugarFotosTableViewCell
			
			if lugar.foto != "" {
				
				if lugar.fotoCache != nil {

					cell.foto.image = lugar.fotoCache!
					cell.foto.frame.size.width = 320
					cell.foto.frame.size.height = 200
					
					UIView.animateWithDuration(1.0, delay: 0.0, options: .CurveEaseOut, animations: {
						
						cell.foto.alpha = 1
						
						}, completion: nil)
					
				} else {
					
					IJProgressView.shared.showProgressView(cell, padding: false)
					
					let urlImagen = lugar.foto.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
					
					if urlImagen != "" {
						
						let imgURL = NSURL(string: urlImagen!)
						
						let request: NSURLRequest = NSURLRequest(URL: imgURL!)
						NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
							
							if error == nil {
								
								self.lugar.fotoCache = UIImage(data: data)
								
								dispatch_async(dispatch_get_main_queue(), {
									
									if let cellVisible = self.tabla.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as? RecreacionLugarFotosTableViewCell {
										
										IJProgressView.shared.hideProgressView()
										cellVisible.foto.image = self.lugar.fotoCache
										
										UIView.animateWithDuration(1.0, delay: 0.0, options: .CurveEaseOut, animations: {
											
											cellVisible.foto.alpha = 1
											
											}, completion: nil)
										
									}
								})
								
							} else {
								
								println("Error para bajar la imagen")
								
							}
						})
						
					}
					
				}
				
			}
			
			return cell
			
		} else if indexPath.row == 1 {
			
			let cell = tableView.dequeueReusableCellWithIdentifier(idCell, forIndexPath: indexPath) as! RecreacionLugarDatosTableViewCell
			
			cell.lugarNombre.text = lugar.nombre
			cell.lugarDireccion.text = lugar.calleNombre + " " + lugar.calleAltura
			cell.lugarTelefonoLink.setTitle((lugar.telefono1 ?? lugar.telefono2 ?? lugar.telefono3 ?? "No disponible"), forState: .Normal)
			cell.lugarTelefonoLink.addTarget(self, action: "botonTel:", forControlEvents: .TouchUpInside)
			cell.lugarTelefonoLink.titleLabel!.adjustsFontSizeToFitWidth = true
			cell.lugarTelefonoLink.titleLabel!.minimumScaleFactor = 0.7
			cell.lugarEmailLink.setTitle(lugar.email, forState: .Normal)
			cell.lugarEmailLink.addTarget(self, action: "botonEmail:", forControlEvents: .TouchUpInside)
			cell.lugarEmailLink.titleLabel!.adjustsFontSizeToFitWidth = true
			cell.lugarEmailLink.titleLabel!.minimumScaleFactor = 0.7
			cell.lugarWebLink.setTitle(lugar.web, forState: .Normal)
			cell.lugarWebLink.addTarget(self, action: "botonWeb:", forControlEvents: .TouchUpInside)
			cell.lugarWebLink.titleLabel!.adjustsFontSizeToFitWidth = true
			cell.lugarWebLink.titleLabel!.minimumScaleFactor = 0.7
			
			return cell
			
		} else if indexPath.row == 2 {
			
			let cell = tableView.dequeueReusableCellWithIdentifier(idCell, forIndexPath: indexPath) as! RecreacionLugarMapaTableViewCell
			
			cellMapa = cell
			
			return cell
			
		} else if indexPath.row == 3 {
			
			let cell = tableView.dequeueReusableCellWithIdentifier(idCell, forIndexPath: indexPath) as! RecreacionLugarInfoTableViewCell
			
			cell.texto.attributedText = lugar.info
			
			return cell
			
		} else if indexPath.row == 4 {
			
			let cell = tableView.dequeueReusableCellWithIdentifier(idCell, forIndexPath: indexPath) as! RecreacionLugarObservacionesTableViewCell
			
			cell.texto.attributedText = lugar.observaciones
			
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
			
			if lugar.foto != "" {
				
				return 200
				
			} else {
				
				return 0
				
			}
			
		} else if indexPath.row == 1 {
			
			return 116
			
		} else if indexPath.row == 2 {
			
			if lugar.latitud != 0 {
				
				return 200
				
			} else {
				
				return 0
				
			}
			
		} else if indexPath.row == 3 || indexPath.row == 4 {
			
			let texto: NSAttributedString!
			
			if indexPath.row == 3 {
				
				texto = self.lugar.info
				
			} else {
				
				texto = self.lugar.observaciones
				
			}
			
			let font = UIFont(name: "HelveticaNeue", size: 13.0)!
			
			let height = heightForView(texto, width: (self.view.frame.size.width - 16))
			
			return height + 16 + 28 // 16 de padding top y bottom + 28 por el height del view para el título
			
		}
		
		return 50
		
	}
	
	override func viewDidDisappear(animated: Bool) {
		
		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		appDelegate.arrayVC.removeValueForKey("recreacionLugar")
		
		mapa.delegate = nil
		
		locationManager.stopUpdatingLocation()

		locationManager.delegate = nil

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