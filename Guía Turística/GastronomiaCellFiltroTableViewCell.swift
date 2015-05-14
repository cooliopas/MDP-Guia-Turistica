//
//  GastronomiaCellFiltroTableViewCell.swift
//  GT1
//
//  Created by Pablo Pasqualino on 4/1/15.
//  Copyright (c) 2015 Pablo Pasqualino. All rights reserved.
//

import UIKit

class GastronomiaCellFiltroTableViewCell: UITableViewCell {
	
	@IBOutlet weak var filtroNombreTextField: UITextField!
	@IBAction func filtroNombreTextFieldAction(sender: UITextField) {
		
		sender.resignFirstResponder()

		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		let gastronomiaVC = appDelegate.traeVC("gastronomia") as! GastronomiaViewController
		
		gastronomiaVC.buscar()
		
	}
	
	override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
		filtroNombreTextField.endEditing(true)
	}
	
    override func awakeFromNib() {
        super.awakeFromNib()

		separatorInset = UIEdgeInsetsZero

	}

	override var layoutMargins: UIEdgeInsets {
		get { return UIEdgeInsetsZero }
		set(newVal) {}
	}

	override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
