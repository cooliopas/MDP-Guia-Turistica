//
//  MediosDeAccesoViewController.swift
//  GT1
//
//  Created by Pablo Pasqualino on 3/16/15.
//  Copyright (c) 2015 Pablo Pasqualino. All rights reserved.
//

import UIKit

class MediosDeAccesoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SWRevealViewControllerDelegate {

	@IBOutlet weak var labelTexto: UILabel!

	let accesos = [
		[	"texto": "Acceso en avión",
			"subtexto": "Sitio web Aeropuertos Argentina 2000",
			"tipo": "link",
			"link": "http://www.aa2000.com.ar/"],
		[	"texto": "Acceso en tren",
			"subtexto": "Horarios y tarifas Trenes Argentinos",
			"tipo": "link",
			"link": "http://www.sofse.gob.ar/servicios/pdf/horarios-bsas-mdp.pdf"],
		[	"texto": "Acceso en ómnibus",
			"subtexto": "Información Terminal Mar del Plata",
			"tipo": "link",
			"link": "http://www.nuevaterminalmardel.com.ar/"],
		[	"texto": "Venta pasajes ómnibus",
			"subtexto": "Sitio web Plataforma10.com",
			"tipo": "link",
			"link": "http://www.plataforma10.com/ar"],
		[	"texto": "Acceso en auto",
			"subtexto": "Mapa e instrucciones paso a paso para llegar",
			"tipo": "mapa",
			"link": ""]
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
		return accesos.count
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("cellAcceso", forIndexPath: indexPath) as! UITableViewCell

		cell.textLabel?.text = accesos[indexPath.row]["texto"]!
		if accesos[indexPath.row]["subtexto"] != nil {
			cell.detailTextLabel?.text = accesos[indexPath.row]["subtexto"]!
		}
		
		return cell
	}
	
	//MARK: UITableViewDelegate
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		
		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		
		if accesos[indexPath.row]["tipo"] == "link" {
			
			let mediosDeAccesoLinkVC = appDelegate.traeVC("mediosDeAccesoLink") as! MediosDeAccesoLinkViewController
			mediosDeAccesoLinkVC.link = accesos[indexPath.row]["link"]
			
			self.revealViewController().setFrontViewController(mediosDeAccesoLinkVC, animated: true)
			
		} else {
		
			self.revealViewController().setFrontViewController(appDelegate.traeVC("mediosDeAccesoMapa"), animated: true)
			
		}
		
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
