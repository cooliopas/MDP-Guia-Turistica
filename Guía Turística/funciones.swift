//
//  funciones.swift
//  GT1
//
//  Created by Pablo Pasqualino on 4/25/15.
//  Copyright (c) 2015 Pablo Pasqualino. All rights reserved.
//

import Foundation
import CoreLocation

extension UIViewController {
	
	// desde las secciones, llamamos armaNavegacion() para:
	// poner el boton de menu
	// agregar el boton de volver (cuando esHijo == true)
	// asignar el panGestureRecognizer en UINavigationBar, para mostrar el menu lateral
	
	func armaNavegacion() {
		
		if self.revealViewController() != nil {
			
			var navegacion: UINavigationBar?
			
			for view in self.view.subviews {
				
				if view is UINavigationBar {
			
					navegacion = view as? UINavigationBar
					break
					
				}
				
			}
			
			if navegacion != nil {
			
				var esHijo = false
				
				if let identifier = self.restorationIdentifier {
				
					if !contains(["transporte","mediosDeAcceso","hotelesYAlojamiento","museos","gastronomia","inmobiliarias","congresosYEventos","paseosYLugares","playas","recreacion","informacion"],identifier) {
						
						esHijo = true
						
					}
					
				}
				
				let botonMenuImagen = UIImage(named: "hamburguer")
				
				let botonMenu = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
				botonMenu.bounds = CGRectMake(0,0,20,20)
				botonMenu.setImage(botonMenuImagen, forState: UIControlState.Normal)
				botonMenu.addTarget(self.revealViewController(), action: Selector("revealToggle:"), forControlEvents: UIControlEvents.TouchUpInside)
				
				let botonBarraMenu = UIBarButtonItem(customView: botonMenu)

				let navigationItem = UINavigationItem()
				
				if (esHijo) {
				
					let botonVolverImagen = UIImage(named: "back")
					let botonVolver = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
					botonVolver.bounds = CGRectMake(0,0,20,20)
					botonVolver.setImage(botonVolverImagen, forState: UIControlState.Normal)
					botonVolver.addTarget(self, action: Selector("volver"), forControlEvents: UIControlEvents.TouchUpInside)

					let botonBarraVolver = UIBarButtonItem(customView: botonVolver)
					
					navigationItem.leftBarButtonItems = [botonBarraMenu,botonBarraVolver]

				} else {
					
					navigationItem.leftBarButtonItem = botonBarraMenu

				}

				navigationItem.title = navegacion!.items[0].title

				navegacion!.items = [navigationItem]
		
				navegacion!.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
				
			} else {
				
				// hay un bug
				
				let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
				dispatch_after(dispatchTime, dispatch_get_main_queue(), {

					self.armaNavegacion()
				
				})
				
			}
			
		}
		
	}
	
	// de acuerdo al identifier del view actual, volvemos al correspondiente view padre
	
	func volver() {
		
		if let identifier = self.restorationIdentifier {
		
			var padre = ""
			
			switch identifier {
				case "transporteColeRecorridosMapa":
					padre = "transporteColeRecorridos"
				case "transporteEstacionarInfoContenido","transporteEstacionarInfoWeb":
					padre = "transporteEstacionarInfo"
				case "transporteColeRecorridos","transporteColeTarjetaMapa","transporteColeMyBus","transporteEstacionarInfo","transporteEstacionarZona","transporteEstacionarTarjetaMapa","transporteEstacionarOnline":
					padre = "transporte"
				case "mediosDeAccesoMapa","mediosDeAccesoLink":
					padre = "mediosDeAcceso"
				case "hotelesYAlojamientoOpciones","hotelesYAlojamientoHotel":
					padre = "hotelesYAlojamiento"
				case "gastronomiaOpciones","gastronomiaLugar":
					padre = "gastronomia"
				case "museosMuseo":
					padre = "museos"
				case "inmobiliariasOpciones","inmobiliariasInmobiliaria":
					padre = "inmobiliarias"
				case "congresosYEventosOpciones","congresosYEventosEvento":
					padre = "congresosYEventos"
				case "paseosYLugaresPDF":
					padre = "paseosYLugares"
				case "playasOpciones","playasPlaya":
					padre = "playas"
				case "recreacionOpciones","recreacionLugar":
					padre = "recreacion"
				case "informacionFarmacias","informacionComisarias","informacionMovilPolicial","informacionWiFi","informacionCentrosSalud":
					padre = "informacion"
				default:
					break
			}
			
			if padre != "" {
				
				let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

				self.revealViewController().setFrontViewController((appDelegate.traeVC(padre)), animated: true)
				
			}
			
		}
		
	}
	
	// función de SWRevealViewControllerDelegate que se ejecuta cuando abrimos o cerramos el menu lateral
	
	func revealController(revealController: SWRevealViewController!, didMoveToPosition position: FrontViewPosition) {
		
		if position == FrontViewPosition.Right {

			// armo un UIView que cubre todo el Front, para que no se pueda interactuar.
			// No puedo usar self.view.userInteractionEnabled = false, porque el NavigationBar es parte de self.view y bloquea el boton de menu para cerrarlo
			// se le asigna el tag = 555 para localizarlo luego y hacerlo desaparecer
			
			let marginCobertor = 44+UIApplication.sharedApplication().statusBarFrame.size.height
			
			let viewCobertor = UIView(frame: CGRectMake(0, marginCobertor, self.view.frame.width, self.view.frame.height - marginCobertor))
			
			viewCobertor.tag = 555
			
			self.view.addSubview(viewCobertor)
			
		} else {

			// recorro los subviews buscando el view con tag == 555, y lo elimino
			
			for view in self.view.subviews {
				
				if view.tag == 555 {
					
					view.removeFromSuperview()
					break
					
				}
				
			}
			
		}
		
	}
	
	// calculo el height que tendrá un UILabel con NSAttributedString en base al texto (text) y el ancho asignado (width)
	
	func heightForView(text:NSAttributedString, width:CGFloat) -> CGFloat{
		let label:UILabel = UILabel(frame: CGRectMake(0, 0, width, CGFloat.max))
		label.numberOfLines = 0
		label.attributedText = text
		label.lineBreakMode = NSLineBreakMode.ByWordWrapping
		label.sizeToFit()
		
		return label.frame.height
	}
	
}

// metros desde las coordenadas point1 hasta point2

func directMetersFromCoordinate(point1: CLLocationCoordinate2D, point2: CLLocationCoordinate2D) -> Double {
	
	let DEG_TO_RAD = 0.017453292519943295769236907684886
	let EARTH_RADIUS_IN_METERS = 6372797.560856
	
	let latitudeArc = (point1.latitude - point2.latitude) * DEG_TO_RAD
	let longitudeArc = (point1.longitude - point2.longitude) * DEG_TO_RAD
	
	var latitudeH = sin(latitudeArc * 0.5)
	latitudeH *= latitudeH
	
	var lontitudeH = sin(longitudeArc * 0.5)
	lontitudeH *= lontitudeH
	
	let tmp = cos(point1.latitude*DEG_TO_RAD) * cos(point2.latitude*DEG_TO_RAD)
	
	return EARTH_RADIUS_IN_METERS * 2.0 * asin(sqrt(latitudeH + tmp*lontitudeH))
	
}