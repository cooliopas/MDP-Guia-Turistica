//
//  PaseosYLugaresPDFViewController.swift
//  GT1
//
//  Created by Pablo Pasqualino on 3/25/15.
//  Copyright (c) 2015 Pablo Pasqualino. All rights reserved.
//

import UIKit

class PaseosYLugaresPDFViewController: UIViewController, UIWebViewDelegate, UIAlertViewDelegate, SWRevealViewControllerDelegate {

	@IBOutlet weak var webView: UIWebView!
	
	var pdf: NSURL?

    override func viewDidLoad() {
        super.viewDidLoad()
		
        webView.delegate = self
		
		if pdf != nil {
			webView.loadRequest(NSURLRequest(URL: pdf!))
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
		appDelegate.arrayVC.removeValueForKey("paseosYLugaresPDF")
		
		self.removeFromParentViewController()
		
	}
	
	func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
		return true
	}
	
}