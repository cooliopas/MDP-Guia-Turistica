//
//  ModeloBusquedaOpcionesViewController.swift
//  GT1
//
//  Created by Pablo Pasqualino on 3/31/15.
//  Copyright (c) 2015 Pablo Pasqualino. All rights reserved.
//

import UIKit

class ModeloBusquedaOpcionesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SWRevealViewControllerDelegate {

	@IBOutlet weak var tablaItems: UITableView!
	
	var opcion: String?
	var modeloBusquedaVC: ModeloBusquedaViewController!
    var idSeccion = ""
    var titulo: String = ""
	
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBar?.topItem?.title = titulo

    }
	
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        armaNavegacion()
        self.revealViewController().delegate = self
        
    }
    
	override func viewDidLayoutSubviews() {
		if (tablaItems.respondsToSelector(Selector("layoutMargins"))) {
			tablaItems.layoutMargins = UIEdgeInsetsZero;
		}
	}
	
	//MARK: UITableViewDataSource
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return modeloBusquedaVC.opcionesItems[opcion!]!.count
	}
	
	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return modeloBusquedaVC.opcionesTitulos[opcion!]!
	}
	
	func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 30
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("items", forIndexPath: indexPath) as! UITableViewCell

		cell.textLabel?.text = modeloBusquedaVC.opcionesItems[opcion!]![indexPath.row]["texto"]!
		
		if modeloBusquedaVC.opcionesValores[opcion!]! == indexPath.row {
			
			cell.accessoryType = UITableViewCellAccessoryType.Checkmark
			
		} else {
			
			cell.accessoryType = UITableViewCellAccessoryType.None
			
		}

		cell.separatorInset = UIEdgeInsetsZero
		
		if (cell.respondsToSelector(Selector("layoutMargins"))) {
			cell.layoutMargins = UIEdgeInsetsZero
		}
		
		return cell
	}
	
	//MARK: UITableViewDelegate
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

		let cell = tableView.cellForRowAtIndexPath(indexPath)
		cell!.accessoryType = UITableViewCellAccessoryType.Checkmark
		
		modeloBusquedaVC.opcionesValores[opcion!] = indexPath.row
		modeloBusquedaVC.tablaOpciones.reloadData()
		self.revealViewController().setFrontViewController(modeloBusquedaVC, animated: true)
		
	}
	
	override func viewDidDisappear(animated: Bool) {
		
		super.viewDidDisappear(animated)
		
		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		appDelegate.arrayVC.removeValueForKey("modeloBusquedaOpciones")
		
		self.removeFromParentViewController()
		
	}
	
}