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
		
		if contenido != nil {
			webView.loadHTMLString(contenido!, baseURL: nil)
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
		
		super.viewDidDisappear(animated)
		
		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		appDelegate.arrayVC.removeValueForKey("transporteEstacionarInfoWeb")
		
		IJProgressView.shared.hideProgressView()

		self.removeFromParentViewController()
		
	}
	
	func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
		
		if self.revealViewController() != nil { IJProgressView.shared.hideProgressView() }
		
		let alertView = UIAlertView(title: "Error", message: error.localizedDescription, delegate: self, cancelButtonTitle: "OK", otherButtonTitles: "")
		alertView.alertViewStyle = .Default
		alertView.show()
		
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

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}

}