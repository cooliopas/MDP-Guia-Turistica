//
//  MediosDeAccesoLinkViewController.swift
//  GT1
//
//  Created by Pablo Pasqualino on 3/25/15.
//  Copyright (c) 2015 Pablo Pasqualino. All rights reserved.
//

import UIKit

class MediosDeAccesoLinkViewController: UIViewController, UIWebViewDelegate, UIAlertViewDelegate, SWRevealViewControllerDelegate {

	@IBOutlet weak var webView: UIWebView!
	
	var link: String?

    override func viewDidLoad() {
        super.viewDidLoad()
		
        webView.delegate = self
		
		if link != nil {
			webView.loadRequest(NSURLRequest(URL: NSURL(string: link!)!))
		}
		
    }

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		armaNavegacion()
		self.revealViewController().delegate = self
		
	}
	
	deinit {
		println("deinit")
	}
	
	override func viewDidDisappear(animated: Bool) {
		
		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		appDelegate.arrayVC.removeValueForKey("mediosDeAccesoLink")
		
		self.removeFromParentViewController()
		
	}
	
	func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
		
		if error.code != -999 {
		
			UIApplication.sharedApplication().networkActivityIndicatorVisible = false

			let alertView = UIAlertView(title: "Error", message: error.localizedDescription, delegate: self, cancelButtonTitle: "OK", otherButtonTitles: "")
			alertView.alertViewStyle = .Default
			alertView.show()

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

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}

}