//
//  TransporteEstacionarOnlineViewController.swift
//  GT1
//
//  Created by Pablo Pasqualino on 3/25/15.
//  Copyright (c) 2015 Pablo Pasqualino. All rights reserved.
//

import UIKit

class TransporteEstacionarOnlineViewController: UIViewController, UIWebViewDelegate, UIAlertViewDelegate, SWRevealViewControllerDelegate {

	@IBOutlet weak var webView: UIWebView!
	
	var link: String?

    override func viewDidLoad() {
        super.viewDidLoad()
		
		link = "http://www.mardelplata.gob.ar/node/1164"
		
        webView.delegate = self
		
		if hayRed() {
		
			if link != nil {
				webView.loadRequest(NSURLRequest(URL: NSURL(string: link!)!))
			}
			
		}
		
    }

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		armaNavegacion()
		self.revealViewController().delegate = self
	
	}
	
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if !hayRed() {
            
            muestraError("No se detecta conección a Internet.\nNo es posible continuar.", volver: 1)
            
        }
        
    }
    
	deinit {
//		println("deinit")
	}
	
	override func viewDidDisappear(animated: Bool) {
		
		super.viewDidDisappear(animated)
		
		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		appDelegate.arrayVC.removeValueForKey("transporteEstacionarOnline")
		
		self.removeFromParentViewController()
		
	}
	
	func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
		
		UIApplication.sharedApplication().networkActivityIndicatorVisible = false
		
		if error.code != -999 {
						
			var alertView = UIAlertController(title: "Ocurrió un error", message: error.localizedDescription, preferredStyle: .Alert)
			var okAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
			alertView.addAction(okAction)
			presentViewController(alertView, animated: true, completion: nil);
			
		}
		
	}
	
	func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
		return true
	}
	
	func webViewDidStartLoad(webView: UIWebView) {
		
		UIApplication.sharedApplication().networkActivityIndicatorVisible = true
		
	}
	
	func webViewDidFinishLoad(webView: UIWebView) {
				
		UIApplication.sharedApplication().networkActivityIndicatorVisible = false
		
	}

}