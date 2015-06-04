//
//  coverViewController.swift
//  GT1
//
//  Created by Pablo Pasqualino on 3/11/15.
//  Copyright (c) 2015 Pablo Pasqualino. All rights reserved.
//

import UIKit

class coverViewController: UIViewController {
	
	var navigationHeight:CGFloat = 0
	var superWidth:CGFloat!
	var superHeight:CGFloat!
	var itemWidth:CGFloat!
	var itemHeight:CGFloat!
	
	var arrayConstraints: [[String:NSLayoutConstraint]] = [[:]]
	let cantidadItems:CGFloat = 12
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
        if navBar != nil { navigationHeight = navBar!.frame.size.height }
		superWidth = self.view.frame.width
		superHeight = self.view.frame.height - navigationHeight - UIApplication.sharedApplication().statusBarFrame.height
		itemWidth = superWidth / 3
		itemHeight = ceil(superHeight / ceil(cantidadItems / 3))
		
		for id in 1...12 {
			
			if let viewId = self.view.viewWithTag(id) {

				let tapGestureRecognizer:UITapGestureRecognizer	= UITapGestureRecognizer(target: self, action: "tap:")
				tapGestureRecognizer.numberOfTapsRequired = 1
				viewId.addGestureRecognizer(tapGestureRecognizer)

				viewId.userInteractionEnabled = false
				
				arrayConstraints.append([:])
				
				arrayConstraints[id]["width"] = NSLayoutConstraint(item: viewId, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: itemWidth)
				self.view.addConstraint(arrayConstraints[id]["width"]!);

				arrayConstraints[id]["height"] = NSLayoutConstraint(item: viewId, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: itemHeight)
				self.view.addConstraint(arrayConstraints[id]["height"]!);
				
				arrayConstraints[id]["left"] = NSLayoutConstraint(item: viewId, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: viewId.superview!, attribute: NSLayoutAttribute.LeadingMargin, multiplier: 1, constant: superWidth / 2 - superWidth / 6 - 16)
				self.view.addConstraint(arrayConstraints[id]["left"]!);
				
				arrayConstraints[id]["top"] = NSLayoutConstraint(item: viewId, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.topLayoutGuide, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: superHeight)
				self.view.addConstraint(arrayConstraints[id]["top"]!);

				self.view.sendSubviewToBack(viewId)
				
				viewId.alpha = 0.0

			}
				
		}
		
    }
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		var ubicacionX:CGFloat = -16
		var ubicacionY:CGFloat = navigationHeight
		var delay = 0.0
		
		for id in 1...12 {
			
			let viewId = self.view.viewWithTag(id as Int)! as UIView
		
			UIView.animateWithDuration(0.5, delay: delay, options: .CurveEaseOut, animations: {

				self.arrayConstraints[id]["top"]!.constant = ubicacionY
				ubicacionY = CGFloat(Int(self.itemHeight) * Int(id/3)) + self.navigationHeight
				
				self.arrayConstraints[id]["left"]!.constant = ubicacionX
				ubicacionX += self.superWidth / 3
				if (ubicacionX+16 >= self.superWidth) { ubicacionX = -16 }
				
				viewId.alpha = 1.0
				
				self.view.layoutIfNeeded()
				
				}, completion: { finished in
					
					viewId.userInteractionEnabled = true
			
				}
			)

			delay += 0.1
			
		}
		
	}
	
	func tap(recognizer:UITapGestureRecognizer){
		
		let viewActual = recognizer.view!
		let tagActual = viewActual.tag
		var label: UILabel!
		var nuevoVC = ""
		
		switch viewActual.tag {
		case 1:
			nuevoVC = "mediosDeAcceso"
		case 2:
			nuevoVC = "hotelesYAlojamiento"
		case 3:
			nuevoVC = "inmobiliarias"
		case 4:
			nuevoVC = "gastronomia"
		case 5:
			nuevoVC = "playas"
		case 6:
			nuevoVC = "transporte"
		case 7:
			nuevoVC = "congresosYEventos"
		case 8:
			nuevoVC = "recreacion"
		case 9:
			nuevoVC = "paseosYLugares"
		case 10:
			nuevoVC = "museos"
		case 11:
			nuevoVC = "informacion"
		default:
			break
		}
		
		if nuevoVC != "" && self.revealViewController().frontViewController.restorationIdentifier != nuevoVC {
		
			for view in viewActual.subviews {
				
				if view is UILabel {
					
					label = view as? UILabel
					
				}
				
			}
			
			self.view.bringSubviewToFront(viewActual)
			
			let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
			
			UIView.animateWithDuration(0.4, delay: 0.0, options: .CurveEaseOut, animations: {

				self.arrayConstraints[tagActual]["width"]!.constant = self.superWidth
				self.arrayConstraints[tagActual]["height"]!.constant = self.superHeight

				self.arrayConstraints[tagActual]["top"]!.constant = self.navigationHeight
				self.arrayConstraints[tagActual]["left"]!.constant = -16
				
				label.alpha = 0
				
				self.view.layoutIfNeeded()
				
				}, completion: { finished in
					
					self.revealViewController().setFrontViewController(appDelegate.traeVC(nuevoVC), animated: true)
					
			})

		}
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}