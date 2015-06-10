//
//  TransporteEstacionarInfoWebViewController.swift
//  GT1
//
//  Created by Pablo Pasqualino on 3/25/15.
//  Copyright (c) 2015 Pablo Pasqualino. All rights reserved.
//

import UIKit

class TransporteEstacionarInfoWebViewController: UIViewController, UIWebViewDelegate, UIAlertViewDelegate, SWRevealViewControllerDelegate {

	@IBOutlet weak var webView: UIWebView!
	
	var contenido: String?

    override func viewDidLoad() {
        super.viewDidLoad()
		
        webView.delegate = self
		
		if hayRed() {
	
			if contenido != nil {
				webView.loadHTMLString(contenido!, baseURL: nil)
			}
			
		}
		
    }

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		armaNavegacion()
		self.revealViewController().delegate = self

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
		appDelegate.arrayVC.removeValueForKey("transporteEstacionarInfoWeb")
		
		self.removeFromParentViewController()
		
	}
	
	func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
		
		if self.revealViewController() != nil { IJProgressView.shared.hideProgressView() }
		
		if error.code != -999 {
			
			UIApplication.sharedApplication().networkActivityIndicatorVisible = false
			
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
		
		IJProgressView.shared.showProgressView(self.view, padding: true)
		
	}
	
	func webViewDidFinishLoad(webView: UIWebView) {
				
		if self.revealViewController() != nil { IJProgressView.shared.hideProgressView() }
		
	}

}