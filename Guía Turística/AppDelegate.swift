//
//  AppDelegate.swift
//  Guía Turística
//
//  Created by Pablo Pasqualino on 5/7/15.
//  Copyright (c) 2015 Pablo Pasqualino. All rights reserved.
//

import UIKit
import SwiftyJSON

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	var arrayVC: [String:UIViewController] = [:]
	var opcionesItems: [String: [String : [[String: String]]]] = [:]
	
	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		// Override point for customization after application launch.

		let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
		
		let reveal: SWRevealViewController = SWRevealViewController(rearViewController: traeVC("menu"), frontViewController: traeVC("cover"))
		
		reveal.toggleAnimationType = SWRevealToggleAnimationType.Spring
		
		window?.rootViewController = reveal
		window?.makeKeyAndVisible()
		
		// carga opcionesItems para las secciones correspondientes (vCs)
		
		let fileManager = NSFileManager.defaultManager()
		
		let libraryPath = fileManager.URLsForDirectory(.LibraryDirectory, inDomains: .UserDomainMask).first as! NSURL

		let timestampAhora = NSDate().timeIntervalSince1970

		// los VC que tienen opcionesItems
		// algunos, como hotelesYAlojamiento, tienen más de un tipo de opcion
		let vCs = ["congresosYEventos": ["categoria"],
			"gastronomia": ["tipo"],
			"hotelesYAlojamiento": ["categoria","zona"],
			"inmobiliarias": ["zona"],
			"playas": ["zona"],
			"recreacion": ["categoria"]]
		
		for (idVC,opciones) in vCs {

			opcionesItems[idVC] = [:]
			
			for opcion in opciones {
				
				var cacheDesdeInicial = 0
				let archivoCache = libraryPath.URLByAppendingPathComponent("Caches/\(idVC)-\(opcion)-OpcionesItems.json")

				// me fijo si existe el archivo de cache
				if !fileManager.fileExistsAtPath(archivoCache.path!) {
					
					// si no existe, uso el que esta en Varios.bundle y lo cacheo
					if let archivoInicial = NSBundle.mainBundle().pathForResource("Varios.bundle/\(idVC)-\(opcion)-OpcionesItemsInicial", ofType: "json") {
						
						let jsonInicial = String(contentsOfFile: archivoInicial, encoding: NSUTF8StringEncoding, error: nil)
						
						jsonInicial!.writeToURL(archivoCache, atomically: true, encoding: NSUTF8StringEncoding, error: nil)
						
						cacheDesdeInicial = 1
						
					}

				}

				// leo el archivo de cache
				let jsonCache = NSData(contentsOfFile: archivoCache.path!)
				
				let data = NSJSONSerialization.JSONObjectWithData(jsonCache!, options: nil, error: nil)! as! NSArray

				opcionesItems[idVC]![opcion] = (data as! [[String : String]])
				
				let attributes = fileManager.attributesOfItemAtPath(archivoCache.path!, error: nil)! as NSDictionary
				
				let timestamp = attributes.fileModificationDate()!.timeIntervalSince1970
				
				// si el cache tiene más de un día, o es el que estaba en Varios.bundle, lo refresco desde la API
				if timestampAhora - timestamp >= 86400 || cacheDesdeInicial == 1 {
					
					leeOpciones(idVC,opcion: opcion)
					
				}

			}
			
		}
	
		return true
	}

	func leeOpciones(idVC: String,opcion: String) {
		
		var api = ""
		var opcionNombre = ""
		var opcionItemDescripcion = ""
		var opcionItemId = ""
		var opcionesItems: [String: [[String: String]]] = [:]
		var opcionCero = ""
		var nombresLindos: [Int : String] = [:]
		var usarNombresLindos = 0
		var idsAUsar: [Int] = []
		
		switch idVC {
			case "congresosYEventos":
				api = "Evento"
				opcionNombre = "Categorias"
				opcionItemDescripcion = "DescripcionCategoria"
				opcionItemId = "IdCategoria"
				opcionCero = "Todas las categorías"
				// los nombres de las categorías los sacamos de aca, porque en la API vienen todos en mayusculas y queda horrible
				nombresLindos = [
					5: "Acontecimientos Deportivos",
					1: "Ballet y Danzas",
					16: "Cena, Show, Peña, Baile",
					2: "Charlas y Conferencias",
					3: "Cine",
					14: "Circos",
					4: "Concursos",
					13: "Congresos y Otros Acontecimientos Programados",
					18: "Desfiles",
					6: "Espectáculos Integrales",
					7: "Exposiciones, Muestras y Ferias",
					19: "Festivales",
					8: "Fiestas",
					9: "Homenajes",
					10: "Infantiles",
					11: "Música",
					17: "Talleres",
					12: "Teatros"
				]
				usarNombresLindos = 1
			case "gastronomia":
				api = "Gastronomia"
				opcionNombre = "TiposComercio"
				opcionItemDescripcion = "DescripcionTipoComercio"
				opcionItemId = "IdTipoComercio"
				opcionCero = "Todos los tipos"
			case "hotelesYAlojamiento":
				api = "Hotel"
				if opcion == "categoria" {
					opcionNombre = "Categorias"
					opcionItemDescripcion = "DescripcionCategoria"
					opcionItemId = "IdCategoria"
					opcionCero = "Todas las categorías"
				} else {
					opcionNombre = "Zonas"
					opcionItemDescripcion = "DescripcionZona"
					opcionItemId = "IdZona"
					opcionCero = "Todas las zonas"
				}
			case "inmobiliarias":
				api = "Inmobiliaria"
				opcionNombre = "ZonasOperacion"
				opcionItemDescripcion = "DescripcionZonaOperacion"
				opcionItemId = "IdZonaOperacion"
				opcionCero = "Todas las zonas"
			case "playas":
				api = "Playa"
				opcionNombre = "Zonas"
				opcionItemDescripcion = "DescripcionZona"
				opcionItemId = "IdZona"
				opcionCero = "Todas las zonas"
				idsAUsar = [2507,2512,2513,2890,2511,2887,2514,2510,5536,2516,2518,2891]
			case "recreacion":
				api = "Recreacion"
				opcionNombre = "Categorias"
				opcionItemDescripcion = "DescripcionCategoria"
				opcionItemId = "IdCategoria"
				opcionCero = "Todas las categorías"
			default:
				break
		}
		
		restea(api,opcionNombre,["Token":"01234567890123456789012345678901"]) { (request, response, JSON, error) in
			
			if error == nil, let info = JSON as? NSDictionary {
			
				opcionesItems[opcion] = [["texto":opcionCero,"id":"0"]]
				
				for (tipo) in info[opcionNombre] as! NSArray {
					
					let id = tipo[opcionItemId] as! Int
					
					if idsAUsar.count == 0 || contains(idsAUsar,id) {
					
						var texto = ""
						
						if usarNombresLindos == 1 && nombresLindos[id] != nil {
							
							texto = nombresLindos[id]!
							
						} else {
						
							texto = tipo[opcionItemDescripcion] as! String
							
						}
						
						opcionesItems[opcion]!.append(["texto":texto,"id":String(id)])

					}
						
				}

				self.opcionesItems[idVC]![opcion] = opcionesItems[opcion]!
				
				let data = NSJSONSerialization.dataWithJSONObject(opcionesItems[opcion]!, options: nil, error: nil)
				let string = NSString(data: data!, encoding: NSUTF8StringEncoding)
				
				let fileManager = NSFileManager.defaultManager()
				let libraryPath = fileManager.URLsForDirectory(.LibraryDirectory, inDomains: .UserDomainMask).first as! NSURL

				let archivoCache = libraryPath.URLByAppendingPathComponent("Caches/\(idVC)-\(opcion)-OpcionesItems.json")
				
				string!.writeToURL(archivoCache, atomically: true, encoding: NSUTF8StringEncoding, error: nil)

				if self.arrayVC[idVC] != nil {
					
					switch self.arrayVC[idVC] {
						case is CongresosYEventosViewController:
							let vc = self.arrayVC[idVC] as! CongresosYEventosViewController
							vc.opcionesItems[opcion] = opcionesItems[opcion]!
							vc.tablaOpciones.reloadData()
						case is GastronomiaViewController:
							let vc = self.arrayVC[idVC] as! GastronomiaViewController
							vc.opcionesItems[opcion] = opcionesItems[opcion]!
							vc.tablaOpciones.reloadData()
						case is HotelesYAlojamientoViewController:
							let vc = self.arrayVC[idVC] as! HotelesYAlojamientoViewController
							vc.opcionesItems[opcion] = opcionesItems[opcion]!
							vc.tablaOpciones.reloadData()
						case is InmobiliariasViewController:
							let vc = self.arrayVC[idVC] as! InmobiliariasViewController
							vc.opcionesItems[opcion] = opcionesItems[opcion]!
							vc.tablaOpciones.reloadData()
						case is PlayasViewController:
							let vc = self.arrayVC[idVC] as! PlayasViewController
							vc.opcionesItems[opcion] = opcionesItems[opcion]!
							vc.tablaOpciones.reloadData()
						case is RecreacionViewController:
							let vc = self.arrayVC[idVC] as! RecreacionViewController
							vc.opcionesItems[opcion] = opcionesItems[opcion]!
							vc.tablaOpciones.reloadData()
						default:
							break
					}
					
				}
				
			}
				
		}
		
	}
	
	func traeVC(nombreVC: String) -> UIViewController {
		
		if let vc = arrayVC[nombreVC] {
			return vc
		} else {
			let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
			arrayVC[nombreVC] = mainStoryboard.instantiateViewControllerWithIdentifier(nombreVC) as? UIViewController
			return arrayVC[nombreVC]!
		}
		
	}

	func applicationWillResignActive(application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(application: UIApplication) {
		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	func applicationWillTerminate(application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}


}

