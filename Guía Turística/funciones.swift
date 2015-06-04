//
//  funciones.swift
//  GT1
//
//  Created by Pablo Pasqualino on 4/25/15.
//  Copyright (c) 2015 Pablo Pasqualino. All rights reserved.
//

import Foundation
import CoreLocation
import IJReachability

extension UIViewController {
	
	// desde las secciones, llamamos armaNavegacion() para:
	// poner el boton de menu
	// agregar el boton de volver (cuando !contains(vcPadres,identifier))
	// asignar el panGestureRecognizer en UINavigationBar, para mostrar el menu lateral
	
    var navBar: UINavigationBar? {
        
        for view in self.view.subviews {
            
            if view is UINavigationBar {
                
                return view as? UINavigationBar
                
            }
            
        }
        
        return nil

    }
    
	func armaNavegacion() {
        
        let vcPadres = ["transporte",
                        "mediosDeAcceso",
                        "hotelesYAlojamiento",
                        "museos",
                        "gastronomia",
                        "inmobiliarias",
                        "congresosYEventos",
                        "paseosYLugares",
                        "playas",
                        "recreacion",
                        "informacion",
                        "modeloBusqueda"]

		if self.revealViewController() != nil {
			
            if let navigationBar = navBar {
							
				let botonMenuImagen = UIImage(named: "hamburguer")
				
				let botonMenu = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
				botonMenu.bounds = CGRectMake(0,0,20,20)
				botonMenu.setImage(botonMenuImagen, forState: UIControlState.Normal)
				botonMenu.addTarget(self.revealViewController(), action: Selector("revealToggle:"), forControlEvents: UIControlEvents.TouchUpInside)
				
				let botonBarraMenu = UIBarButtonItem(customView: botonMenu)

				let navigationItem = UINavigationItem()
				
                if let identifier = self.restorationIdentifier where !contains(vcPadres,identifier) {
				
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

				navigationItem.title = navigationBar.items[0].title

				navigationBar.items = [navigationItem]
		
				navigationBar.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
				
//			} else {
//				
//				// hay un bug
//				
//				let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
//				dispatch_after(dispatchTime, dispatch_get_main_queue(), {
//
//					self.armaNavegacion()
//				
//				})
				
			}
			
		}
		
	}
	
	// de acuerdo al identifier del view actual, volvemos al correspondiente view padre
	
	func volver() {
		
		if self.revealViewController().frontViewPosition == .Left {
		
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
//					case "hotelesYAlojamientoOpciones","hotelesYAlojamientoHotel":
//						padre = "hotelesYAlojamiento"
                    case "modeloBusquedaOpciones","modeloBusquedaLugar":
                        if let vcd = self as? ModeloBusquedaOpcionesViewController {
                            padre = vcd.idSeccion
                        } else if let vcd = self as? ModeloBusquedaLugarViewController {
                            padre = vcd.idSeccion
                        }
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
			
	}
	
	// función de SWRevealViewControllerDelegate que se ejecuta cuando abrimos o cerramos el menu lateral
	
	func revealController(revealController: SWRevealViewController!, didMoveToPosition position: FrontViewPosition) {
		
		if position == FrontViewPosition.Right {

			// armo un UIView que cubre todo el Front, para que no se pueda interactuar.
			// a la vez, lo uso para asignarle el tapGestureRecognizer() y panGestureRecognizer() de RevealViewController
			// se le asigna el tag = 555 para localizarlo luego y hacerlo desaparecer
			
			let viewCobertor = UIView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
			
			viewCobertor.tag = 555

			viewCobertor.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
			viewCobertor.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
			
			self.view.addSubview(viewCobertor)
			
		} else {

			// recorro los subviews buscando el view con tag == 555, y lo elimino
			// también vuelvo a asignar panGestureRecognizer() al navigationBar
			
			for view in self.view.subviews {
				
				if view.tag == 555 {
					
					view.removeFromSuperview()
                    break
                    
				}
							
			}
            
            if let navigationBar = navBar {
                
                navigationBar.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
                
            }
			
		}
		
	}
	
	func muestraError(textoError: String,volver: Int) {
		
		var alertController = UIAlertController(title: "Hay un problema", message: textoError, preferredStyle: .Alert)
		
		var okAction = UIAlertAction(title: "Ok", style: .Default) { (_) -> Void in
			if volver == 1 { self.volver() }
		}
		
		alertController.addAction(okAction)
		
		presentViewController(alertController, animated: true, completion: nil);
		
	}
	
	func hayRed() -> Bool {
		
		return IJReachability.isConnectedToNetwork()
		
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

func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
	let label:UILabel = UILabel(frame: CGRectMake(0, 0, width, CGFloat.max))
	label.numberOfLines = 0
	label.lineBreakMode = NSLineBreakMode.ByWordWrapping
	label.font = font
	label.text = text
	label.sizeToFit()
	
	return label.frame.height
}