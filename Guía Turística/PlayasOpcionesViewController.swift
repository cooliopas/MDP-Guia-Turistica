//
//  PlayasOpcionesViewController.swift
//  GT1
//
//  Created by Pablo Pasqualino on 3/31/15.
//  Copyright (c) 2015 Pablo Pasqualino. All rights reserved.
//

import UIKit

class PlayasOpcionesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SWRevealViewControllerDelegate {

	@IBOutlet weak var tablaItems: UITableView!
	
	var opcion: String?
	var playasVC: PlayasViewController!
	
    override func viewDidLoad() {
        super.viewDidLoad()

		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		playasVC = appDelegate.traeVC("playas") as! PlayasViewController
		
    }
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
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
		return playasVC.opcionesItems[opcion!]!.count
	}
	
	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return playasVC.opcionesTitulos[opcion!]!
	}
	
	func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 30
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("items", forIndexPath: indexPath) as! UITableViewCell

		cell.textLabel?.text = playasVC.opcionesItems[opcion!]![indexPath.row]["texto"]!
		
		if playasVC.opcionesValores[opcion!]! == indexPath.row {
			
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
		
		playasVC.opcionesValores[opcion!] = indexPath.row
		playasVC.tablaOpciones.reloadData()
		self.revealViewController().setFrontViewController(playasVC, animated: true)
		
	}
	
	override func viewDidDisappear(animated: Bool) {
		
		super.viewDidDisappear(animated)
		
		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		appDelegate.arrayVC.removeValueForKey("playasOpciones")
		
		self.removeFromParentViewController()
		
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
}
