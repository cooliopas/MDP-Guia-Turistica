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
		[	"titulo": "Acceso en avión",
			"subtitulo": "Sitio web Aeropuertos Argentina 2000",
			"tipo": "link",
			"link": "http://www.aa2000.com.ar/"],
		[	"titulo": "Acceso en tren",
			"subtitulo": "Horarios y tarifas Trenes Argentinos",
			"tipo": "link",
			"link": "http://www.sofse.gob.ar/servicios/pdf/horarios-bsas-mdp.pdf"],
		[	"titulo": "Acceso en ómnibus",
			"subtitulo": "Información Terminal Mar del Plata",
			"tipo": "link",
			"link": "http://www.nuevaterminalmardel.com.ar/"],
		[	"titulo": "Venta pasajes ómnibus",
			"subtitulo": "Sitio web Plataforma10.com",
			"tipo": "link",
			"link": "http://www.plataforma10.com/ar"],
		[	"titulo": "Acceso en auto",
			"subtitulo": "Mapa e instrucciones paso a paso para llegar",
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

		cell.textLabel?.text = accesos[indexPath.row]["titulo"]!
		if accesos[indexPath.row]["subtitulo"] != nil {
			cell.detailTextLabel?.text = accesos[indexPath.row]["subtitulo"]!
		}
		
		return cell
	}
	
	//MARK: UITableViewDelegate
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		
		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		
		if accesos[indexPath.row]["tipo"] == "link" {
			
			let mediosDeAccesoLinkVC = appDelegate.traeVC("mediosDeAccesoLink") as! MediosDeAccesoLinkViewController
			mediosDeAccesoLinkVC.link = accesos[indexPath.row]["link"]
			mediosDeAccesoLinkVC.titulo = accesos[indexPath.row]["titulo"]
			
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
