//
//  PlayasViewController.swift
//  GT1
//
//  Created by Pablo Pasqualino on 3/18/15.
//  Copyright (c) 2015 Pablo Pasqualino. All rights reserved.
//

import UIKit
import CoreLocation

class PlayasViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, SWRevealViewControllerDelegate {

	@IBOutlet weak var tablaOpciones: UITableView!
	@IBOutlet weak var tablaResultados: UITableView!
	@IBOutlet weak var labelSinResultados: UILabel!
	
	var cellBusqueda: PlayasCellFiltroTableViewCell?
	
	let opciones = ["zona","nombre"]
	
	let opcionesTitulos = [	"zona":"Zona",
							"nombre":"Nombre"]
	
	var opcionesValores = [	"zona":0,
							"nombre":""]
	
	var opcionesItems: [String: [[String: String]]] = [:]
	
	var playas = [Lugar]()

	let locationManager = CLLocationManager()
	var ubicacionActual: CLLocationCoordinate2D?

	override func viewDidLoad() {
		super.viewDidLoad()
		
		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		self.opcionesItems = appDelegate.opcionesItems[self.restorationIdentifier!]!
		
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		armaNavegacion()
		self.revealViewController().delegate = self

		locationManager.delegate = self
		
		locationManager.desiredAccuracy = kCLLocationAccuracyBest

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
		
		ubicacionActual = (locations.last as! CLLocation).coordinate
		
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
		
		cellBusqueda!.filtroNombreTextField.endEditing(true)
		
		let idZona = (opcionesItems["zona"]![(opcionesValores["zona"]! as! Int)]["id"]! as String).toInt()!
		let filtroNombre = cellBusqueda!.filtroNombreTextField.text

		UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseOut, animations: {
			
			self.tablaResultados.alpha = 0
			self.labelSinResultados.alpha = 0
			
			}, completion: { finished in
				
				self.tablaResultados.scrollRectToVisible(CGRectMake(0, 0, 1, 1), animated: false)
				
		})
		
		IJProgressView.shared.showProgressView(self.view, padding: true)

		restea("Playa","Buscar",["Token":"01234567890123456789012345678901","IdZona":idZona,"Nombre":filtroNombre]) { (request, response, JSON, error) in
			
			if self.revealViewController() != nil { IJProgressView.shared.hideProgressView() }
			
			if error == nil, let info = JSON as? NSDictionary where (info["Playas"] as! NSArray).count > 0 {
				
				self.playas = Lugar.lugaresCargaDeJSON(info["Playas"] as! NSArray)

				if self.ubicacionActual != nil {
					
					for playa in self.playas {
						
						if playa.latitud != 0 {
							
							playa.distancia = directMetersFromCoordinate(self.ubicacionActual!, CLLocationCoordinate2DMake(playa.latitud, playa.longitud))
							
						}
						
					}
					
					self.playas.sort(self.sorterForDistancia)
					
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
						
						if (info["Estado"] as? String) == "ERROR" {
							
							mensajeError = "Es necesario elegir una zona o filtrar por nombre."
							
						} else {
							
							mensajeError = "No se encontraron playas o balnearios para su búsqueda."
							
						}
						
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
				
				let playasOpcionesVC = appDelegate.traeVC("playasOpciones") as! PlayasOpcionesViewController
				
				playasOpcionesVC.opcion = opciones[indexPath.row]
				
				self.revealViewController().setFrontViewController(playasOpcionesVC, animated: true)
				
			}
			
		} else if tableView == tablaResultados {
			
			let playasPlayaVC = appDelegate.traeVC("playasPlaya") as! PlayasPlayaViewController
			
			playasPlayaVC.playa = playas[indexPath.row]
			
			self.revealViewController().setFrontViewController(playasPlayaVC, animated: true)
			
		}

		tableView.deselectRowAtIndexPath(indexPath, animated: true)

	}
	
	//MARK: UITableViewDataSource
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		if tableView == tablaOpciones {
			
			return opciones.count
			
		} else if tableView == tablaResultados {
			
			return playas.count
			
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
		
		var cellHeight: CGFloat = 30
		
		if tableView == tablaResultados {
			
			cellHeight = 86
			
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
				
				let cell = tableView.dequeueReusableCellWithIdentifier("filtro", forIndexPath: indexPath) as! PlayasCellFiltroTableViewCell
				self.cellBusqueda = cell
				
				if (cell.respondsToSelector(Selector("layoutMargins"))) {
					cell.layoutMargins = UIEdgeInsetsZero
				}
				
				cell.separatorInset = UIEdgeInsetsZero
				
				return cell
				
			}
			
		} else if tableView == tablaResultados {
			
			let playa = playas[indexPath.row] as Lugar
			
			let cell = tableView.dequeueReusableCellWithIdentifier("playa", forIndexPath: indexPath) as! PlayasResultadosPlayaCellTableViewCell
			
			cell.nombre.text = playa.nombre
			cell.direccion.text = playa.calleNombre + " " + playa.calleAltura
			cell.telefono.text = playa.telefono1 ?? playa.telefono2 ?? playa.telefono3 ?? ""
			
			if playa.distancia != nil {
				
				let distancia = Int(playa.distancia! / 100)
				
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