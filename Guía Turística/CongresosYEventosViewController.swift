//
//  CongresosYEventosViewController.swift
//  GT1
//
//  Created by Pablo Pasqualino on 3/18/15.
//  Copyright (c) 2015 Pablo Pasqualino. All rights reserved.
//

import UIKit
import Alamofire

class CongresosYEventosViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SWRevealViewControllerDelegate {

	@IBOutlet weak var tablaOpciones: UITableView!
	@IBOutlet weak var tablaResultados: UITableView!
	@IBOutlet weak var labelSinResultados: UILabel!
	
	var cellBusqueda: CongresosYEventosCellFiltroTableViewCell?
	
	let opciones = ["categoria","nombre"]
	
	let opcionesTitulos = [	"categoria": "Categoria",
							"nombre": "Nombre"]
	
	var opcionesValores = [	"categoria": 0,
							"nombre": ""]
		
	var opcionesItems: [String: [[String: String]]] = [:]
	
	var eventos = [Evento]()

	override func viewDidLoad() {
		super.viewDidLoad()
				
		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		self.opcionesItems = appDelegate.opcionesItems[self.restorationIdentifier!]!
		
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		armaNavegacion()
		self.revealViewController().delegate = self
		
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

		let filtroNombre = cellBusqueda!.filtroNombreTextField.text
		
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "yyyyMMdd"
		let fechaDesde = dateFormatter.stringFromDate(NSDate())
		let fechaHasta = dateFormatter.stringFromDate(NSDate().dateByAddingTimeInterval(90 * 24 * 60 * 60))
		
		UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseOut, animations: {
			
			self.tablaResultados.alpha = 0
			self.labelSinResultados.alpha = 0
			
			}, completion: { finished in
				
				self.tablaResultados.scrollRectToVisible(CGRectMake(0, 0, 1, 1), animated: false)
				
		})
		
		IJProgressView.shared.showProgressView(self.view, padding: true, texto: "Por favor espere...\nLa búsqueda puede demorar aproximadamente 1 minuto.")

		restea("Evento","Buscar",["Token":"01234567890123456789012345678901","IdCategoria":idCategoria,"FechaDesde":fechaDesde,"FechaHasta":fechaHasta,"Nombre":filtroNombre]) { (request, response, JSON, error) in
			
			if self.revealViewController() != nil { IJProgressView.shared.hideProgressView() }
			
			if error == nil, let info = JSON as? NSDictionary where (info["Eventos"] as! NSArray).count > 0 {
			
				self.eventos = Evento.eventosCargaDeJSON(info["Eventos"] as! NSArray)

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
							
						mensajeError = "No se encontraron eventos para su búsqueda."
						
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
	
	//MARK: UITableViewDelegate
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		
		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		
		if tableView == tablaOpciones {
			
			if opciones[indexPath.row] != "nombre" {
				
				let congresosYEventosOpcionesVC = appDelegate.traeVC("congresosYEventosOpciones") as! CongresosYEventosOpcionesViewController
				
				congresosYEventosOpcionesVC.opcion = opciones[indexPath.row]
				
				self.revealViewController().setFrontViewController(congresosYEventosOpcionesVC, animated: true)
				
			}
			
		} else if tableView == tablaResultados {
			
			let congresosYEventosEventoVC = appDelegate.traeVC("congresosYEventosEvento") as! CongresosYEventosEventoViewController
			
			congresosYEventosEventoVC.evento = eventos[indexPath.row]
			
			self.revealViewController().setFrontViewController(congresosYEventosEventoVC, animated: true)
			
		}
		
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		
	}
	
	//MARK: UITableViewDataSource
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		if tableView == tablaOpciones {
			
			return opciones.count
			
		} else if tableView == tablaResultados {
			
			return eventos.count
			
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
				
				let cell = tableView.dequeueReusableCellWithIdentifier("filtro", forIndexPath: indexPath) as! CongresosYEventosCellFiltroTableViewCell

				self.cellBusqueda = cell
				
				if cell.respondsToSelector(Selector("layoutMargins")) {
					cell.layoutMargins = UIEdgeInsetsZero
				}
				
				cell.separatorInset = UIEdgeInsetsZero
				
				return cell
				
			}
			
		} else if tableView == tablaResultados {
			
			let evento = eventos[indexPath.row] as Evento
			
			let cell = tableView.dequeueReusableCellWithIdentifier("evento", forIndexPath: indexPath) as! CongresosYEventosResultadosEventoCellTableViewCell
			
			cell.nombre.text = evento.nombre
			cell.categoriaNombre.text = nombreCategoria(evento.categoriaId)
			cell.subCategoriaNombre.text = evento.subCategoriaNombre != "" ? evento.subCategoriaNombre : ""
			cell.fecha.text = evento.fecha
			
			if cell.respondsToSelector(Selector("layoutMargins")) {
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

	override func viewDidDisappear(animated: Bool) {

		super.viewDidDisappear(animated)
		
		IJProgressView.shared.hideProgressView()

	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
}