//
//  MenuViewController.swift
//  GT1
//
//  Created by Pablo Pasqualino on 3/17/15.
//  Copyright (c) 2015 Pablo Pasqualino. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

	let arrayMenu: [[String:String]] = [
		["id":"mediosDeAcceso","tituloMenu":"Medios de Acceso"],
		["id":"hotelesYAlojamiento","tituloMenu":"Hoteles y Alojamiento"],
		["id":"inmobiliarias","tituloMenu":"Inmobiliarias"],
		["id":"gastronomia","tituloMenu":"Gastronomía"],
		["id":"playas","tituloMenu":"Playas y Balnearios"],
		["id":"transporte","tituloMenu":"Transporte"],
		["id":"congresosYEventos","tituloMenu":"Eventos"],
		["id":"recreacion","tituloMenu":"Recreación y Excursiones"],
		["id":"paseosYLugares","tituloMenu":"Paseos y Lugares"],
		["id":"museos","tituloMenu":"Museos"],
		["id":"informacion","tituloMenu":"Información Útil"]
	]
	
	override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		return arrayMenu.count
		
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCellWithIdentifier("menuCell1", forIndexPath: indexPath) as! MenuTableViewCell1

		cell.label.text = arrayMenu[indexPath.row]["tituloMenu"]
		
		let backgroundView = UIView(frame: cell.frame)
		backgroundView.backgroundColor = UIColor(red: 196/255, green: 217/255, blue: 242/255, alpha: 1)
		
		cell.selectedBackgroundView = backgroundView
		
		return cell
		
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

		self.revealViewController().revealToggleAnimated(true)
		
		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		let nuevoVC = appDelegate.traeVC(arrayMenu[indexPath.row]["id"]!)
		
		if self.revealViewController().frontViewController != nuevoVC {
			
			self.revealViewController().setFrontViewController(nuevoVC, animated: true)
			
		}
		
	}

}
