//
//  PaseosYLugaresViewController.swift
//  GT1
//
//  Created by Pablo Pasqualino on 3/18/15.
//  Copyright (c) 2015 Pablo Pasqualino. All rights reserved.
//

import UIKit

class PaseosYLugaresViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SWRevealViewControllerDelegate {

	let paseos = [
		"MICROCENTRO - LOMA SANTA CECILIA - PUNTA IGLESIA - RAMBLA CASINO - HOTEL PROVINCIAL - PASEO HERMITAGE",
		"LA PERLA - AVENIDA CONSTITUCIÓN - PARQUE CAMET - BARRIOS RESIDENCIALES DEL NORTE",
		"LOMA STELLA MARIS – GÜEMES – BARRIOS TRADICIONALES",
		"PUERTO - AVENIDA JUAN B. JUSTO - PLAYA GRANDE - VARESE - TORREÓN DEL MONJE",
		"PUNTA MOGOTES - BOSQUE DE PERALTA RAMOS - ALFAR - PLAYAS DEL SUR",
		"RESERVA INTEGRAL LAGUNA DE LOS PADRES – SIERRA DE LOS PADRES – PAISAJES SERRANOS",
		"QUINTAS Y CANTERAS – CAMPOS ONDULADOS",
		"CIRCUITO TURISTICO ASTOR PIAZZOLLA"
	]

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		armaNavegacion()
		self.revealViewController().delegate = self

		var tracker = GAI.sharedInstance().defaultTracker
		tracker.set(kGAIScreenName, value: self.restorationIdentifier!)

		var builder = GAIDictionaryBuilder.createScreenView()
		tracker.send(builder.build() as [NSObject : AnyObject])

	}
	
	//MARK: UITableViewDataSource
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return paseos.count
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

		let cell = tableView.dequeueReusableCellWithIdentifier("paseo", forIndexPath: indexPath) as! PaseosYLugaresCellTableViewCell
		
		var nombre  = NSMutableAttributedString()
		let textFont = [NSFontAttributeName:UIFont(name: "HelveticaNeue-Bold", size: 13.0)!]
		nombre.appendAttributedString(NSAttributedString(string: "\(paseos[indexPath.row])", attributes:textFont))
			
		let heightLabel = heightForView(nombre, cell.frame.size.width) + 6;
		
		if cell.nombre == nil {
		
			cell.nombre = UILabel(frame: CGRectMake(5, 0, cell.frame.size.width - 5, heightLabel))
			cell.labelBackground = UIView(frame: CGRectMake(0, cell.frame.size.height - heightLabel, cell.frame.size.width, heightLabel))
			cell.gradLayer = CAGradientLayer()
			
			cell.nombre!.backgroundColor = UIColor.clearColor()
			cell.nombre!.textColor = UIColor.whiteColor()
			cell.nombre!.numberOfLines = 0

			cell.labelBackground!.layer.addSublayer(cell.gradLayer!)
			cell.labelBackground!.addSubview(cell.nombre!)

			cell.addSubview(cell.labelBackground!)

			cell.backgroundView = UIView()
			cell.selectedBackgroundView = UIView()
			
		}
		
		cell.nombre!.attributedText = nombre
		
		
		cell.gradLayer!.frame = cell.labelBackground!.layer.bounds
		cell.gradLayer!.colors = [UIColor.clearColor().CGColor,UIColor.clearColor().CGColor,UIColor.blackColor().CGColor]
		cell.gradLayer!.locations = [0.0, 0.03, 1.0]
		
		let imageView = UIImageView(frame: CGRectMake(0, 0, cell.frame.width, cell.frame.height))
		let image = UIImage(named: "0\(indexPath.row + 1).jpg")
		imageView.image = image
		
		cell.backgroundView! = imageView
		
		return cell
		
	}
	
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return 118
	}
	
	//MARK: UITableViewDelegate
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		
		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

		let paseosYLugaresPDFVC = appDelegate.traeVC("paseosYLugaresPDF") as! PaseosYLugaresPDFViewController
		paseosYLugaresPDFVC.pdf = NSURL(fileURLWithPath:NSBundle.mainBundle().pathForResource("PaseosPDF.bundle/0\(indexPath.row + 1)", ofType:"pdf")!)
		
		self.revealViewController().setFrontViewController(paseosYLugaresPDFVC, animated: true)
		
	}
	
}