//
//  InmobiliariasViewController.swift
//  GT1
//
//  Created by Pablo Pasqualino on 3/18/15.
//  Copyright (c) 2015 Pablo Pasqualino. All rights reserved.
//

import UIKit
import CoreLocation

class InmobiliariasViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, SWRevealViewControllerDelegate {

	@IBOutlet weak var tablaOpciones: UITableView!
	@IBOutlet weak var tablaResultados: UITableView!
	@IBOutlet weak var labelSinResultados: UILabel!

	var cellBusqueda: InmobiliariasCellFiltroTableViewCell?
	
	let opciones = ["zona","nombre"]
	
	let opcionesTitulos = [	"zona":"Zona",
							"nombre":"Nombre"]
	
	var opcionesValores = [	"zona":0,
							"nombre":""]

	var opcionesItems: [String: [[String: String]]] = [:]
	
	var inmobiliarias = [Lugar]()

	let locationManager = CLLocationManager()
	var ubicacionActual: CLLocation?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		labelSinResultados.alpha = 1
		labelSinResultados.text = "Se muestran únicamente las inmobiliarias que ofrecen alquiler turístico."

		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		opcionesItems = appDelegate.opcionesItems[self.restorationIdentifier!]!
		
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyBest

	}

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
					
		armaNavegacion()
		self.revealViewController().delegate = self

		locationManager.startUpdatingLocation()

	}
	
	func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
		
		if status == CLAuthorizationStatus.AuthorizedWhenInUse {
			locationManager.startUpdatingLocation()
		} else {
			locationManager.requestWhenInUseAuthorization()
		}
		
	}
	
	func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
		
		locationManager.stopUpdatingLocation()
		
		ubicacionActual = locations.last as? CLLocation
		
	}

	override func viewDidLayoutSubviews() {
		if tablaResultados.respondsToSelector(Selector("layoutMargins")) {
			tablaResultados.layoutMargins = UIEdgeInsetsZero;
		}
		if tablaOpciones.respondsToSelector(Selector("layoutMargins")) {
			tablaOpciones.layoutMargins = UIEdgeInsetsZero;
		}
	}
	
	@IBAction func buscar() {
		
		if !hayRed() {
			
			muestraError("No se detecta conección a Internet.\nNo es posible continuar.", volver: 0)
			
		} else {
			
			cellBusqueda!.filtroNombreTextField.endEditing(true)
		
			let idZona = (opcionesItems["zona"]![(opcionesValores["zona"]! as! Int)]["id"]! as String).toInt()!
			let filtroNombre = cellBusqueda!.filtroNombreTextField.text
			
			UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseOut, animations: {
				
				self.tablaResultados.alpha = 0
				self.labelSinResultados.alpha = 0
				
				}, completion: { finished in
			
					self.tablaResultados.scrollRectToVisible(CGRectMake(0, 0, 1, 1), animated: false)
			
			})
			
			IJProgressView.shared.showProgressView(self.view, padding: true, texto: "Por favor espere...\nLa búsqueda puede demorar aproximadamente 1 minuto.")

			restea("Inmobiliaria","Buscar",["Token":"01234567890123456789012345678901","SoloConAlquilerTuristico":"true","IdZona":idZona,"Nombre":filtroNombre]) { (request, response, JSON, error) in

				if self.revealViewController() != nil { IJProgressView.shared.hideProgressView() }
				
				if error == nil, let info = JSON as? NSDictionary where (info["Inmobiliarias"] as! NSArray).count > 0 {
					
					self.inmobiliarias = Lugar.lugaresCargaDeJSON(info["Inmobiliarias"] as! NSArray)

					if self.ubicacionActual != nil {

						for inmobiliaria in self.inmobiliarias {
							
							if inmobiliaria.latitud != 0 {
							
								inmobiliaria.distancia = self.ubicacionActual!.distanceFromLocation(CLLocation(latitude: inmobiliaria.latitud, longitude: inmobiliaria.longitud))
								
							}
							
						}
						
						self.inmobiliarias.sort(self.sorterForDistancia)
						
					}
					
					self.tablaResultados.reloadData()
					
					UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseOut, animations: {
						
						self.tablaResultados.alpha = 1
						
						}, completion: nil)

				} else {
					
					if error?.code == -1001 {
						
						self.labelSinResultados.text = "Ocurrió un error al leer los datos.\nPor favor intente nuevamente."
						
					} else {
						
						var mensajeError = ""
						
						if let info = JSON as? NSDictionary {
							
							mensajeError = "No se encontraron inmobiliarias para su búsqueda."
							
						} else {
							
							mensajeError = "Ocurrió un error."
							
						}
						
						self.labelSinResultados.text = mensajeError
						
					}
					
					UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseOut, animations: {
						
						self.labelSinResultados.alpha = 1
						
						}, completion: nil)
					
				}
				
			}
			
		}
		
	}
	
	func sorterForDistancia(this:Lugar, that:Lugar) -> Bool {
		if this.distancia == nil {
			return false
		} else if that.distancia == nil {
			return true
		} else {
			return this.distancia! < that.distancia!
		}
	}
	
	//MARK: UITableViewDelegate
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		
		if tableView == tablaOpciones {
			
			if opciones[indexPath.row] != "nombre" {
		
				let inmobiliariasOpcionesVC = appDelegate.traeVC("inmobiliariasOpciones") as! InmobiliariasOpcionesViewController
				
				inmobiliariasOpcionesVC.opcion = opciones[indexPath.row]
				
				self.revealViewController().setFrontViewController(inmobiliariasOpcionesVC, animated: true)

			}
			
		} else if tableView == tablaResultados {
		
			let inmobiliariasInmobiliariaVC = appDelegate.traeVC("inmobiliariasInmobiliaria") as! InmobiliariasInmobiliariaViewController
			
			inmobiliariasInmobiliariaVC.inmobiliaria = inmobiliarias[indexPath.row]
			
			self.revealViewController().setFrontViewController(inmobiliariasInmobiliariaVC, animated: true)
			
		}
		
		tableView.deselectRowAtIndexPath(indexPath, animated: true)

	}
	
	//MARK: UITableViewDataSource
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		if tableView == tablaOpciones {
		
			return opciones.count
			
		} else if tableView == tablaResultados {

			return inmobiliarias.count
			
		}
	
		return 0
		
	}
	
	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		
		if tableView == tablaOpciones {
		
			return "Opciones de búsqueda"
			
		}
		
		return ""
		
	}
	
	func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		
		if tableView == tablaOpciones {
		
			return 30
			
		}
		
		return 0
		
	}
	
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		
		var cellHeight: CGFloat = 44
		
		if tableView == tablaResultados {
			
			cellHeight = 80
			
		}
		
		return cellHeight
		
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

		if tableView == tablaOpciones {

			let opcion = opciones[indexPath.row] as String

			if opcion != "nombre" {
				
				let cell = tableView.dequeueReusableCellWithIdentifier("opciones", forIndexPath: indexPath) as! UITableViewCell
				
				cell.textLabel?.text = opcionesTitulos[opcion]!
				
				if let items = opcionesItems[opcion],
					let valor = opcionesValores[opcion] as? Int,
					let texto = items[valor]["texto"] {
					
					cell.detailTextLabel?.text = texto
					
				} else {
					
					cell.detailTextLabel?.text = "Cargando ..."
					
				}
			
				if (cell.respondsToSelector(Selector("layoutMargins"))) {
					cell.layoutMargins = UIEdgeInsetsZero
				}
				
				cell.separatorInset = UIEdgeInsetsZero

				return cell
				
			} else {

				let cell = tableView.dequeueReusableCellWithIdentifier("filtro", forIndexPath: indexPath) as! InmobiliariasCellFiltroTableViewCell
				cellBusqueda = cell
				
				if (cell.respondsToSelector(Selector("layoutMargins"))) {
					cell.layoutMargins = UIEdgeInsetsZero
				}
				
				cell.separatorInset = UIEdgeInsetsZero

				return cell
				
			}
			
		} else if tableView == tablaResultados {
	
			let inmobiliaria = inmobiliarias[indexPath.row] as Lugar
			
			let cell = tableView.dequeueReusableCellWithIdentifier("inmobiliaria", forIndexPath: indexPath) as! InmobiliariasResultadosInmobiliariaCellTableViewCell

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
				
			cell.nombre.text = nombre.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
			cell.titular.text = titular.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
			cell.direccion.text = inmobiliaria.calleNombre + " " + inmobiliaria.calleAltura
			
			if inmobiliaria.distancia != nil {
			
				let distancia = Int(inmobiliaria.distancia! / 100)
				
				cell.distancia.text = "A \(distancia) cuadras"

			} else {

				cell.distancia.text = ""
				
			}
			
			if (cell.respondsToSelector(Selector("layoutMargins"))) {
				cell.layoutMargins = UIEdgeInsetsZero
			}
			
			cell.separatorInset = UIEdgeInsetsZero

			let backgroundView = UIView(frame: cell.frame)
			backgroundView.backgroundColor = UIColor(red: 168/255, green: 198/255, blue: 231/255, alpha: 1)
			
			cell.selectedBackgroundView = backgroundView
			
			return cell
			
		}
		
		return UITableViewCell()

	}
	
	override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
		if cellBusqueda != nil {
			cellBusqueda!.filtroNombreTextField.endEditing(true)
		}
	}
	
	override func viewDidDisappear(animated: Bool) {

		super.viewDidDisappear(animated)
		
		IJProgressView.shared.hideProgressView()
		
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}