//
//  TransporteEstacionarInfoContenidoViewController.swift
//  GT1
//
//  Created by Pablo Pasqualino on 4/24/15.
//  Copyright (c) 2015 Pablo Pasqualino. All rights reserved.
//

import UIKit

class TransporteEstacionarInfoContenidoViewController: UIViewController, SWRevealViewControllerDelegate {

	@IBOutlet weak var contenidoTexto: UITextView!
	
	var contenido: String?
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		if contenido != nil {

			contenido = "<style>*{font-family: 'HelveticaNeue'; font-size: 14px;}strong{font-weight: bold}</style>".stringByAppendingString(contenido!)

			let attributedString = NSMutableAttributedString(data: contenido!.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: false)!, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil, error: nil)
			
			contenidoTexto.attributedText = attributedString
			
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
	
	deinit {
//		println("deinit")
	}
	
	override func viewDidDisappear(animated: Bool) {
		
		super.viewDidDisappear(animated)
				
		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		appDelegate.arrayVC.removeValueForKey("transporteEstacionarInfoContenido")
		
		self.removeFromParentViewController()
		
	}

}