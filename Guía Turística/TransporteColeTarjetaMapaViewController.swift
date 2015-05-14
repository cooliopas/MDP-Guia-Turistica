//  TransporteColeTarjetaMapaViewController.swift
//  GT1
//
//  Created by Pablo Pasqualino on 3/26/15.
//  Copyright (c) 2015 Pablo Pasqualino. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import WYPopoverController
import SwiftyJSON

class TransporteColeTarjetaMapaViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, SWRevealViewControllerDelegate {

	@IBOutlet weak var mapaView: MKMapView!
	@IBOutlet weak var segmentadorTipo: UISegmentedControl!
	@IBOutlet weak var segmentadorTodos: UISegmentedControl!

	var linea: String!
	
	let locationManager = CLLocationManager()
	
	var ubicacionActual: CLLocationCoordinate2D?

	let mapManager = MapManager()
	
	var actualizoRegion = false
	
	var popOver: WYPopoverController?
	
	var puestosCargaSUBE: [PuestoCarga] = []
	var puestosCargaUTE: [PuestoCarga] = []

    override func viewDidLoad() {
        super.viewDidLoad()

		if CLLocationManager.authorizationStatus() == .NotDetermined {
			locationManager.requestWhenInUseAuthorization()
		}

		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyBest

		mapaView.showsUserLocation = true
		mapaView.delegate = self
		
		if let file = NSBundle.mainBundle().pathForResource("Varios.bundle/puntosDeCargaUTE", ofType: "json"),
			let data = NSData(contentsOfFile: file),
			let puestosUTE = JSON(data:data).array {

			for puesto in puestosUTE {

				puestosCargaUTE.append(PuestoCarga(coordenadas: CLLocationCoordinate2DMake(puesto[0].doubleValue,puesto[1].doubleValue), nombre: "Puesto de Carga UTE", direccion: puesto[2].stringValue, tipo: 1))
				
			}
				
		}

		if let file = NSBundle.mainBundle().pathForResource("Varios.bundle/puntosDeCargaSUBE", ofType: "json"),
			let data = NSData(contentsOfFile: file),
			let puestosSUBE = JSON(data:data).array {
				
			for puesto in puestosSUBE {
				
				puestosCargaSUBE.append(PuestoCarga(coordenadas: CLLocationCoordinate2DMake(puesto[0].doubleValue,puesto[1].doubleValue), nombre: "Puesto de Carga SUBE", direccion: puesto[2].stringValue, tipo: 0))
				
			}
				
		}
		
		if !actualizoRegion {
		
			mapaView.setRegion(MKCoordinateRegionMake(CLLocationCoordinate2DMake(-37.992820,-57.583932), MKCoordinateSpanMake(0.05, 0.05)), animated: false)
			
		}

	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		armaNavegacion()
		self.revealViewController().delegate = self
		
	}
	
	@IBAction func mostrarPuestosActualiza() {
		
		mostrarPuestos(segmentadorTipo.selectedSegmentIndex,todos: segmentadorTodos.selectedSegmentIndex)
		
	}
	
	func sorterForDistancia(this:PuestoCarga, that:PuestoCarga) -> Bool {
		return this.distancia! < that.distancia!
	}
	
	func mostrarPuestos(tipo: Int,todos: Int) {
		
		for annotation in mapaView.annotations {
			
			if annotation is PuestoCargaAnnotation {
				
				mapaView.removeAnnotation(annotation as! PuestoCargaAnnotation)
				
			}
			
		}
		
		if tipo == 0 || tipo == 2 {
			
			if todos == 0 { puestosCargaSUBE.sort(sorterForDistancia) }
			
			var puestosMostrados = 0
			
			for puestoCarga in puestosCargaSUBE {

				let annotation = PuestoCargaAnnotation()
				annotation.coordinate = puestoCarga.coordenadas
				annotation.title = puestoCarga.nombre
				annotation.puestoCarga = puestoCarga
				
				mapaView.addAnnotation(annotation)
				
				puestosMostrados++
				
				if todos == 0 && puestosMostrados == 10 { break }
				
			}
			
		}
		
		if tipo == 1 || tipo == 2 {
			
			if todos == 0 { puestosCargaUTE.sort(sorterForDistancia) }
			
			var puestosMostrados = 0
			
			for puestoCarga in puestosCargaUTE {
				
				let annotation = PuestoCargaAnnotation()
				annotation.coordinate = puestoCarga.coordenadas
				annotation.title = puestoCarga.nombre
				annotation.puestoCarga = puestoCarga
				
				mapaView.addAnnotation(annotation)
				
				puestosMostrados++
				
				if todos == 0 && puestosMostrados == 10 { break }
				
			}
			
		}
		
	}
	
	func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
		
		if annotation is MKUserLocation {
			
			return nil
			
		} else {
			
			var identificador = ""
			var imagen: UIImage!
			var centerOffset: CGFloat = 0
			
			let puestoCargaAnnotation = annotation as! PuestoCargaAnnotation
			
			if puestoCargaAnnotation.puestoCarga!.tipo == 0 {
				
				identificador = "annotationSUBE"
				imagen = UIImage(named: "logo-sube")
				centerOffset = 15
				
			} else {
				
				identificador = "annotationUTE"
				imagen = UIImage(named: "logo-ute")
				centerOffset = -15
				
			}
			
			var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identificador)
			
			if annotationView != nil {
				
				annotationView.annotation = annotation
				
			} else {
				
				annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identificador)
				
			}
			
			annotationView.canShowCallout = false
			annotationView.image = imagen
			annotationView.centerOffset = CGPointMake(centerOffset, 0)
			
			return annotationView;
			
		}
		
	}
	
	func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
		
		if !(view.annotation is MKUserLocation) {
		
			mapView.deselectAnnotation(view.annotation, animated: true)
			
			let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
			let controller = appDelegate.traeVC("transportePop") as! TransportePopViewController

			controller.preferredContentSize = CGSizeMake(240, 70);
			
			popOver = WYPopoverController(contentViewController: controller)
			popOver?.theme = WYPopoverTheme.themeForIOS7()

			let puestoCargaAnnotation = view.annotation as! PuestoCargaAnnotation
			let puestoCarga = puestoCargaAnnotation.puestoCarga

			controller.tipoPuesto.text = puestoCarga?.nombre

			controller.direccionPuesto.text = puestoCarga!.direccion
			
			controller.botonCerrar.addTarget(self, action: Selector("cerrar"), forControlEvents: UIControlEvents.TouchUpInside)
			
			popOver!.presentPopoverFromRect(view.bounds, inView: view, permittedArrowDirections: WYPopoverArrowDirection.Any, animated: true, options: WYPopoverAnimationOptions.FadeWithScale)
			
		}
		
	}

	func cerrar() {
		
		popOver?.dismissPopoverAnimated(true)
		
	}
	
	func mapView(mapView: MKMapView!, didDeselectAnnotationView view: MKAnnotationView!) {
		for childView:AnyObject in view.subviews{
			childView.removeFromSuperview();
		}
	}
	
	func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
		
		if ubicacionActual == nil || directMetersFromCoordinate(ubicacionActual!, userLocation.coordinate) > 100 {
			
			ubicacionActual = userLocation.coordinate
		
			for puestoCarga in puestosCargaSUBE {
				
				puestoCarga.distancia = directMetersFromCoordinate(ubicacionActual!, puestoCarga.coordenadas)
				
			}
			
			for puestoCarga in puestosCargaUTE {
				
				puestoCarga.distancia = directMetersFromCoordinate(ubicacionActual!, puestoCarga.coordenadas)
				
			}
			
			mostrarPuestos(segmentadorTipo.selectedSegmentIndex,todos: segmentadorTodos.selectedSegmentIndex)
			
			println("actualizo ubicacion y puestos")

		}
		
		if !actualizoRegion {

			mapaView.setRegion(MKCoordinateRegionMake(userLocation.coordinate, MKCoordinateSpanMake(0.02, 0.02)), animated: true)
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
		appDelegate.arrayVC.removeValueForKey("transporteColeTarjetaMapa")
		
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