//
//  InformacionViewController.swift
//  GT1
//
//  Created by Pablo Pasqualino on 3/18/15.
//  Copyright (c) 2015 Pablo Pasqualino. All rights reserved.
//

import UIKit

class InformacionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SWRevealViewControllerDelegate {
	
	let informacionSecciones = [
			[
				"nombre":"Farmacias",
				"sub":"Farmacias de turno y farmacias más cercanas",
				"view":"informacionFarmacias"
			],
			[
				"nombre":"Comisarias",
				"sub":"Cual es la comisaría más cercana?",
				"view":"informacionComisarias"
			],
			[
				"nombre":"Movil Policial",
				"sub":"Teléfono celular de la patrulla más cercana",
				"view":"informacionMovilPolicial"
			],
			[
				"nombre":"WiFi Público",
				"sub":"Lugares más cercanos de Wifi Público",
				"view":"informacionWiFi"
			],
			[
				"nombre":"Centros de Salud",
				"sub":"Cual es el Centro de Salud más cercano?",
				"view":"informacionCentrosSalud"
			]
	]
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
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
		return informacionSecciones.count
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		if let sub = informacionSecciones[indexPath.row]["sub"] {
			
			let cell = tableView.dequeueReusableCellWithIdentifier("informacionSubtitle", forIndexPath: indexPath) as! UITableViewCell
			
			cell.textLabel?.text = informacionSecciones[indexPath.row]["nombre"]!
			cell.detailTextLabel?.text = sub
			
			return cell
			
		} else {
			
			let cell = tableView.dequeueReusableCellWithIdentifier("informacionBasic", forIndexPath: indexPath) as! UITableViewCell
			
			cell.textLabel?.text = informacionSecciones[indexPath.row]["nombre"]!
			
			return cell
			
		}
		
	}
	
//	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//		return informacionSeccionesNombres[section]
//	}
//	
	//MARK: UITableViewDelegate
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		
		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		self.revealViewController().setFrontViewController(appDelegate.traeVC(informacionSecciones[indexPath.row]["view"]!), animated: true)
		
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		
	}
	
	//	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
	//
	//	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
}