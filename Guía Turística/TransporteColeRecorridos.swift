//
//  TransporteColeRecorridosViewController.swift
//  GT1
//
//  Created by Pablo Pasqualino on 3/18/15.
//  Copyright (c) 2015 Pablo Pasqualino. All rights reserved.
//

import UIKit

class TransporteColeRecorridosViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SWRevealViewControllerDelegate {

	@IBOutlet weak var tablaLineas: UITableView!

	var lineas: [String] = []
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let filemgr = NSFileManager.defaultManager()
		let currentPath = filemgr.currentDirectoryPath
		
		if let filelist = filemgr.contentsOfDirectoryAtPath(NSBundle.mainBundle().bundlePath + "/Recorridos.bundle", error: nil) as? [String] {
			
			let filelistOrdenado = (filelist as NSArray).sortedArrayUsingSelector(Selector("caseInsensitiveCompare:")) as! [String]
			
			for filename in filelistOrdenado {
				
                let linea = filename.stringByReplacingOccurrencesOfString("-ida.json", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil).stringByReplacingOccurrencesOfString("-vuelta.json", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil).stringByReplacingOccurrencesOfString("-", withString: " ", options: NSStringCompareOptions.LiteralSearch, range: nil).capitalizedString
            
                if !contains(lineas,linea) {
                
                    lineas.append(linea)
                    
                }
				
			}
			
		}
		
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		armaNavegacion()
		self.revealViewController().delegate = self

		var tracker = GAI.sharedInstance().defaultTracker
		tracker.set(kGAIScreenName, value: self.restorationIdentifier!)

		var builder = GAIDictionaryBuilder.createScreenView()
		tracker.send(builder.build() as [NSObject : AnyObject])

	}
	
	override func viewDidLayoutSubviews() {
		if tablaLineas.respondsToSelector(Selector("layoutMargins")) {
			tablaLineas.layoutMargins = UIEdgeInsetsZero;
		}
	}
	
	//MARK: UITableViewDelegate
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

		if !hayRed() {
			
			muestraError("No se detecta conección a Internet.\nNo es posible continuar.", volver: 1)
			
		} else {
		
			let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

			let transporteColeRecorridosMapaVC = appDelegate.traeVC("transporteColeRecorridosMapa") as! TransporteColeRecorridosMapaViewController
			
			transporteColeRecorridosMapaVC.linea = lineas[indexPath.row]
			
			self.revealViewController().setFrontViewController(transporteColeRecorridosMapaVC, animated: true)
			
			tableView.deselectRowAtIndexPath(indexPath, animated: true)
			
		}

	}
	
	//MARK: UITableViewDataSource
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		return lineas.count
		
	}
	
	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		
		return "Mostrar recorrido de la linea:"
		
	}
	
	func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		
		return 30
		
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

		let cell = tableView.dequeueReusableCellWithIdentifier("linea", forIndexPath: indexPath) as! UITableViewCell
		
		cell.textLabel?.text = lineas[indexPath.row]
		
		if (cell.respondsToSelector(Selector("layoutMargins"))) {
			cell.layoutMargins = UIEdgeInsetsZero
		}
		
		cell.separatorInset = UIEdgeInsetsZero

		return cell

	}
	
}