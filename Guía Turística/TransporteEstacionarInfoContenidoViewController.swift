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

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		armaNavegacion()
		self.revealViewController().delegate = self
		
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
