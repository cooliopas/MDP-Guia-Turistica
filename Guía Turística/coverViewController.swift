//
//  coverViewController.swift
//  GT1
//
//  Created by Pablo Pasqualino on 3/11/15.
//  Copyright (c) 2015 Pablo Pasqualino. All rights reserved.
//

import UIKit

class coverViewController: UIViewController {

	@IBOutlet weak var scrollView: UIScrollView!

	let arraySecciones: [[String:String]] = [
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

	var navigationHeight: CGFloat = 0
	var superWidth: CGFloat!
	var superHeight: CGFloat!
	var itemWidth: CGFloat!
	var itemMargin: CGFloat = 10

    override func viewDidLoad() {
        super.viewDidLoad()
		
        if navBar != nil { navigationHeight = navBar!.frame.size.height }
		superWidth = self.view.frame.width
		superHeight = self.view.frame.height - navigationHeight - UIApplication.sharedApplication().statusBarFrame.height
		itemWidth = superWidth / 3 - itemMargin * 2

		let scrollHeight = (itemWidth + itemMargin * 4 + 2) * ceil( CGFloat(Double(arraySecciones.count) / 3) )

		if scrollHeight > superHeight {

			scrollView.contentSize = CGSizeMake(superWidth, (itemWidth + itemMargin * 4 + 2) * ceil( CGFloat(Double(arraySecciones.count) / 3) ))
			scrollView.scrollEnabled = true

		}

		var ubicacionX:CGFloat = itemMargin
		var ubicacionY:CGFloat = itemMargin
		var itemIndex = 1

		for seccion in arraySecciones {

			let seccionView = UIImageView(frame: CGRectMake(ubicacionX, ubicacionY, itemWidth, itemWidth))

			let tapGestureRecognizer:UITapGestureRecognizer	= UITapGestureRecognizer(target: self, action: "tap:")
			tapGestureRecognizer.numberOfTapsRequired = 1
			seccionView.addGestureRecognizer(tapGestureRecognizer)

			seccionView.tag = itemIndex - 1
			seccionView.layer.cornerRadius = itemWidth/2
			seccionView.clipsToBounds = true
			seccionView.alpha = 0.0
			seccionView.layer.borderColor = UIColor.grayColor().CGColor
			seccionView.layer.borderWidth = 1
			seccionView.contentMode = UIViewContentMode.ScaleAspectFit
			seccionView.userInteractionEnabled = true

			seccionView.image = UIImage(named: "cover-\(itemIndex)")

			scrollView.addSubview(seccionView)

			let seccionLabel = UILabel(frame: CGRectMake(ubicacionX, ubicacionY + itemWidth + 4, itemWidth, itemMargin * 3))

			seccionLabel.tag = itemIndex - 1
			seccionLabel.textAlignment = NSTextAlignment.Center
			seccionLabel.numberOfLines = 0
			seccionLabel.text = seccion["tituloMenu"]!
			seccionLabel.font = UIFont.systemFontOfSize(12)
			seccionLabel.sizeToFit()
			seccionLabel.frame.size.width = itemWidth
			seccionLabel.alpha = 0.0
			seccionLabel.userInteractionEnabled = true

			let tapGestureRecognizerLabel:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tap:")
			tapGestureRecognizerLabel.numberOfTapsRequired = 1
			seccionLabel.addGestureRecognizer(tapGestureRecognizerLabel)

			scrollView.addSubview(seccionLabel)

			ubicacionY = CGFloat(Int(itemWidth + itemMargin * 4) * Int(itemIndex/3)) + itemMargin
			ubicacionX += itemWidth + itemMargin * 2
			if (ubicacionX >= superWidth) { ubicacionX = itemMargin }

			itemIndex++

		}

    }
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		var delay = 0.0
		
		for viewId in scrollView.subviews {

			UIView.animateWithDuration(0.5, delay: delay, options: nil, animations: { () -> Void in
				(viewId as! UIView).alpha = 1.0
			}, completion: nil)

			delay += 0.01

		}

		var tracker = GAI.sharedInstance().defaultTracker
		tracker.set(kGAIScreenName, value: self.restorationIdentifier!)

		var builder = GAIDictionaryBuilder.createScreenView()
		tracker.send(builder.build() as [NSObject : AnyObject])

	}
	
	func tap(recognizer:UITapGestureRecognizer){

		let viewActual = recognizer.view!
		let tagActual = viewActual.tag
		var nuevoVC = arraySecciones[tagActual]["id"] ?? ""

		if nuevoVC != "" && self.revealViewController().frontViewController.restorationIdentifier != nuevoVC {
		
			self.view.bringSubviewToFront(viewActual)
			
			let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
			
			self.revealViewController().setFrontViewController(appDelegate.traeVC(nuevoVC), animated: true)

		}
	}
	
}