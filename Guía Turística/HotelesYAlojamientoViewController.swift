//
//  HotelesYAlojamientoViewController.swift
//  GT1
//
//  Created by Pablo Pasqualino on 3/18/15.
//  Copyright (c) 2015 Pablo Pasqualino. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation

class HotelesYAlojamientoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SWRevealViewControllerDelegate {

	@IBOutlet weak var tablaOpciones: UITableView!
	@IBOutlet weak var tablaResultados: UITableView!
	@IBOutlet weak var labelSinResultados: UILabel!

	var cellBusqueda: HotelesYAlojamientoCellFiltroTableViewCell?
	
	let opciones = ["categoria","zona","nombre"]
	
	let opcionesTitulos = [	"categoria":"Categoria",
							"zona":"Zona",
							"nombre":"Nombre"]
	
	var opcionesValores = [	"categoria":0,
							"zona":0,
							"nombre":""]

	var opcionesItems: [String: [[String: String]]] = [:]
	
	var hoteles = [Hotel]()

	let locationManager = LocationManager.sharedInstance
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
		
		locationManager.autoUpdate = true
		locationManager.startUpdatingLocationWithCompletionHandler { [weak self] (latitude, longitude, status, verboseMessage, error) -> () in
			
			if self != nil {
				
				self!.ubicacionActual = CLLocationCoordinate2DMake(latitude, longitude)
				self!.locationManager.stopUpdatingLocation()
				
			}
			
		}
		
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
		
		let idCategoria = (opcionesItems["categoria"]![(opcionesValores["categoria"]! as! Int)]["id"]! as String).toInt()!
		let idZona = (opcionesItems["zona"]![(opcionesValores["zona"]! as! Int)]["id"]! as String).toInt()!
		let filtroNombre = cellBusqueda!.filtroNombreTextField.text
		
		UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseOut, animations: {
			
			self.tablaResultados.alpha = 0
			self.labelSinResultados.alpha = 0
			
			}, completion: { finished in
		
				self.tablaResultados.scrollRectToVisible(CGRectMake(0, 0, 1, 1), animated: false)
		
		})
		
		IJProgressView.shared.showProgressView(self.view, padding: true, texto: "Por favor espere...\nLa búsqueda puede demorar aproximadamente 1 minuto.")
		
		restea("Hotel","Buscar",["Token":"01234567890123456789012345678901","IdCategoria":idCategoria,"IdZona":idZona,"Nombre":filtroNombre]) { (request, response, JSON, error) in

			IJProgressView.shared.hideProgressView()
			
			if error == nil, let info = JSON as? NSDictionary where (info["Hoteles"] as! NSArray).count > 0 {

				self.hoteles = Hotel.hotelesCargaDeJSON(info["Hoteles"] as! NSArray)

				if self.ubicacionActual != nil {
					
					for hotel in self.hoteles {
						
						if hotel.latitud != 0 {

							hotel.distancia = directMetersFromCoordinate(self.ubicacionActual!, CLLocationCoordinate2DMake(hotel.latitud, hotel.longitud))
							
						}
						
					}
					
					self.hoteles.sort(self.sorterForDistancia)
					
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
							
							mensajeError = "Es necesario elegir una categoría, zona o filtrar por nombre."
							
						} else {
							
							mensajeError = "No se encontraron hoteles para su búsqueda."
							
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
	
	func sorterForDistancia(this:Hotel, that:Hotel) -> Bool {
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
		
				let hotelesYAlojamientoOpcionesVC = appDelegate.traeVC("hotelesYAlojamientoOpciones") as! HotelesYAlojamientoOpcionesViewController
				
				hotelesYAlojamientoOpcionesVC.opcion = opciones[indexPath.row]
				
				self.revealViewController().setFrontViewController(hotelesYAlojamientoOpcionesVC, animated: true)

			}
			
		} else if tableView == tablaResultados {
		
			let hotelesYAlojamientoHotelVC = appDelegate.traeVC("hotelesYAlojamientoHotel") as! HotelesYAlojamientoHotelViewController
			
			hotelesYAlojamientoHotelVC.hotel = hoteles[indexPath.row]
			
			self.revealViewController().setFrontViewController(hotelesYAlojamientoHotelVC, animated: true)
			
		}
		
		tableView.deselectRowAtIndexPath(indexPath, animated: true)

	}
	
	//MARK: UITableViewDataSource
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		if tableView == tablaOpciones {
		
			return opciones.count
			
		} else if tableView == tablaResultados {

			return hoteles.count
			
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

				let cell = tableView.dequeueReusableCellWithIdentifier("filtro", forIndexPath: indexPath) as! HotelesYAlojamientoCellFiltroTableViewCell
				self.cellBusqueda = cell
				
				if (cell.respondsToSelector(Selector("layoutMargins"))) {
					cell.layoutMargins = UIEdgeInsetsZero
				}
				
				cell.separatorInset = UIEdgeInsetsZero

				return cell
				
			}
			
		} else if tableView == tablaResultados {
	
			let hotel = hoteles[indexPath.row] as Hotel
			
			let cell = tableView.dequeueReusableCellWithIdentifier("hotel", forIndexPath: indexPath) as! HotelesYAlojamientoResultadosHotelCellTableViewCell

			cell.nombre.text = hotel.nombre.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
			cell.direccion.text = hotel.calleNombre + " " + hotel.calleAltura
			cell.categoriaNombre.text = nombreCategoria(hotel.subRubroId)
			
			if hotel.fotoCache != nil {
			
				cell.imagen.image = hotel.fotoCache!

			} else {
				
				cell.imagen.image = UIImage(named: "dummy-hotel")

			}

			hotel.row = indexPath.row
			hotel.tabla = tableView
			
			if hotel.distancia != nil {
			
				let distancia = Int(hotel.distancia! / 100)
				
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
	
	func nombreCategoria(categoriasId: Int) -> String {
		
		if let categorias = opcionesItems["categoria"] {

			for categoria in categorias {
				
				if (categoria["id"]! as String).toInt()! == categoriasId {

					return categoria["texto"]!
					
				}
				
			}
			
		}
		
		return ""
		
	}
	
	override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
		if cellBusqueda != nil {
			cellBusqueda!.filtroNombreTextField.endEditing(true)
		}
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
