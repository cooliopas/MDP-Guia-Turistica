//
//  TransporteViewController.swift
//  GT1
//
//  Created by Pablo Pasqualino on 3/18/15.
//  Copyright (c) 2015 Pablo Pasqualino. All rights reserved.
//

import UIKit

class TransporteViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SWRevealViewControllerDelegate {

	let transporteSecciones = [
		[
			[
				"nombre":"Recorridos",
				"sub":"Recorridos ida y vuelta de todas las lineas",
				"view":"transporteColeRecorridos"
			],
			[
				"nombre":"Tarjetas de colectivo",
				"sub":"Encontra los puntos de venta más cercanos",
				"view":"transporteColeTarjetaMapa"
			],
			[
				"nombre":"¿Que colectivo tomo?",
				"sub":"¿Que linea? ¿En que calle? MYBUS.com.ar",
				"view":"transporteColeMyBus"
			]
		],
		[
			[
				"nombre":"Instrucciones y ayuda",
				"sub":"¿Cómo funciona? ¿Donde compro tarjetas?",
				"view":"transporteEstacionarInfo"
			],
			[
				"nombre":"Zona de estacionamiento medido",
				"sub":"¿Estoy en una zona medida? Mapa de la zona",
				"view":"transporteEstacionarZona"
			],
			[
				"nombre":"Puntos de venta",
				"sub":"Encontra los puntos de venta más cercanos",
				"view":"transporteEstacionarTarjetaMapa"
			],
			[
				"nombre":"Estacionar",
				"sub":"Controla tu estacionamiento online",
				"view":"transporteEstacionarOnline"
			]
		]
	]
	
	let transporteSeccionesNombres = [
		"Colectivos",
		"Estacionamiento Medido"
	]

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		armaNavegacion()
		self.revealViewController().delegate = self
		
	}
	
	//MARK: UITableViewDataSource
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 2
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return transporteSecciones[section].count
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		if let sub = transporteSecciones[indexPath.section][indexPath.row]["sub"] {
		
			let cell = tableView.dequeueReusableCellWithIdentifier("transporteSubtitle", forIndexPath: indexPath) as! UITableViewCell
			
			cell.textLabel?.text = transporteSecciones[indexPath.section][indexPath.row]["nombre"]!
			cell.detailTextLabel?.text = sub
			
			return cell
			
		} else {
			
			let cell = tableView.dequeueReusableCellWithIdentifier("transporteBasic", forIndexPath: indexPath) as! UITableViewCell
			
			cell.textLabel?.text = transporteSecciones[indexPath.section][indexPath.row]["nombre"]!
			
			return cell
			
		}
		
	}
	
	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return transporteSeccionesNombres[section]
	}
	
	//MARK: UITableViewDelegate
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
	
		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		self.revealViewController().setFrontViewController(appDelegate.traeVC(transporteSecciones[indexPath.section][indexPath.row]["view"]!), animated: true)
	
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		
	}
		
}