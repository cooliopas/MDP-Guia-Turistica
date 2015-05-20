//
//  IJProgressView.swift
//  IJProgressView
//
//  Created by Isuru Nanayakkara on 1/14/15.
//  Copyright (c) 2015 Appex. All rights reserved.
//
//  Tiene modificaciones para agregar padding y un texto

import UIKit

public class IJProgressView {
    
    var containerView = UIView()
	var progressView = UIView()
	var textoView = UIView()
    var activityIndicator = UIActivityIndicatorView()
    
    public class var shared: IJProgressView {
        struct Static {
            static let instance: IJProgressView = IJProgressView()
        }
        return Static.instance
    }
    
	public func showProgressView(view: UIView,padding: Bool,texto: String?=nil) {
		
		var paddingPoints:CGFloat = 0
		
		if padding == true {
			
			paddingPoints = 64
			
		}
		
		UIApplication.sharedApplication().networkActivityIndicatorVisible = true
		
        containerView.frame = CGRectMake(0, 0+paddingPoints, view.frame.size.width, view.frame.size.height-paddingPoints)
        containerView.backgroundColor = UIColor(hex: 0xcccccc, alpha: 0.5)
		
        progressView.frame = CGRectMake(0, 0, 80, 80)
        progressView.center = CGPointMake(containerView.bounds.width / 2, containerView.bounds.height / 2)
        progressView.backgroundColor = UIColor(hex: 0x444444, alpha: 0.7)
        progressView.clipsToBounds = true
        progressView.layer.cornerRadius = 10
		
        activityIndicator.frame = CGRectMake(0, 0, 40, 40)
        activityIndicator.activityIndicatorViewStyle = .WhiteLarge
        activityIndicator.center = CGPointMake(progressView.bounds.width / 2, progressView.bounds.height / 2)
		
		progressView.addSubview(activityIndicator)
		containerView.addSubview(progressView)

		if texto != nil {

			textoView.frame = CGRectMake(0, 0, 260, 90)
			textoView.center = CGPointMake(containerView.bounds.width / 2, (containerView.bounds.height / 2) + 92)
			textoView.backgroundColor = UIColor(hex: 0xcccccc, alpha: 0.7)
			textoView.clipsToBounds = true
			textoView.layer.cornerRadius = 5

			let textoLabel = UILabel(frame: CGRectMake(10, 5, 240, 80))
			textoLabel.textColor = UIColor.blackColor()
			textoLabel.numberOfLines = 0
			textoLabel.textAlignment = .Center
			textoLabel.text = texto!
			
			textoView.addSubview(textoLabel)
			
			containerView.addSubview(textoView)
	
		}
	
        view.addSubview(containerView)
		
        activityIndicator.startAnimating()
		
    }
    
    public func hideProgressView() {
        activityIndicator.stopAnimating()
		textoView.removeFromSuperview()
		textoView = UIView()
        containerView.removeFromSuperview()
		UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
}

extension UIColor {
    
    convenience init(hex: UInt32, alpha: CGFloat) {
        let red = CGFloat((hex & 0xFF0000) >> 16)/256.0
        let green = CGFloat((hex & 0xFF00) >> 8)/256.0
        let blue = CGFloat(hex & 0xFF)/256.0
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}