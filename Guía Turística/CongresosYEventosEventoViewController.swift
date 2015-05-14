//
//  CongresosYEventosEventoViewController.swift
//  GT1
//
//  Created by Pablo Pasqualino on 4/4/15.
//  Copyright (c) 2015 Pablo Pasqualino. All rights reserved.
//

import UIKit

class CongresosYEventosEventoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SWRevealViewControllerDelegate {
	
	@IBOutlet weak var tabla: UITableView!
	
	var evento: Evento!
	
	// los nombres de las categorías los sacamos de aca, porque en la API vienen todos en mayusculas y queda horrible
	let categoriasNombresLindos = [
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

	override func viewDidLoad() {
		super.viewDidLoad()
		
		restea("Evento","Detalle",["Token":"01234567890123456789012345678901","IdEvento":evento.id]) { (request, response, JSON, error) in
			
			if error == nil, let info = JSON as? NSDictionary, let detalle = info["Evento"] as? NSDictionary {

				self.evento.detalle = detalle
				
				Evento.armaInfo(self.evento)
				Evento.armaObservaciones(self.evento)
				
				self.tabla.reloadRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 0),NSIndexPath(forRow: 2, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
				
			}
			
		}
		
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		armaNavegacion()
		self.revealViewController().delegate = self
		
	}
	
	//MARK: UITableViewDataSource
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 3
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		var idCell = ""
		
		if indexPath.row == 0 {
			idCell = "eventoEncabezado"
		} else if indexPath.row == 1 {
			idCell = "eventoInformacion"
		} else if indexPath.row == 2 {
			idCell = "eventoObservaciones"
		}
		
		if indexPath.row == 0 {
			
			let cell = tableView.dequeueReusableCellWithIdentifier(idCell, forIndexPath: indexPath) as! CongresosYEventosEventoDatosTableViewCell
			
			cell.eventoNombre.text = evento.nombre
			cell.eventoCategoria.text = categoriasNombresLindos[evento.categoriaId]!
			cell.eventoSubCategoria.text = evento.subCategoriaNombre != "" ? evento.subCategoriaNombre : ""
			cell.eventoFecha.text = evento.fecha
			
			return cell
			
		} else if indexPath.row == 1 {
			
			let cell = tableView.dequeueReusableCellWithIdentifier(idCell, forIndexPath: indexPath) as! CongresosYEventosEventoInfoTableViewCell
			
			cell.texto.attributedText = evento.info
			
			return cell
			
		} else if indexPath.row == 2 {
			
			let cell = tableView.dequeueReusableCellWithIdentifier(idCell, forIndexPath: indexPath) as! CongresosYEventosEventoObservacionesTableViewCell
			
			cell.texto.attributedText = evento.observaciones
			
			return cell
			
		}
		
		return UITableViewCell()
	}
	//MARK: UITableViewDelegate
	
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		
		if indexPath.row == 0 {
			
			return 116
			
		} else if indexPath.row == 1 || indexPath.row == 2 {
			
			let texto: NSAttributedString!
			
			if indexPath.row == 1 {
				
				texto = self.evento.info
				
			} else {
				
				texto = self.evento.observaciones
				
			}
			
			let font = UIFont(name: "HelveticaNeue", size: 13.0)!
			
			let height = heightForView(texto, width: (self.view.frame.size.width - 16))
			
			return height + 16 + 28 // 16 de padding top y bottom + 28 por el height del view para el título
			
		}
		
		return 50
		
	}
	
	override func viewDidDisappear(animated: Bool) {
		
		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		appDelegate.arrayVC.removeValueForKey("congresosYEventosEvento")
		
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