//
//  MuseosCellFiltroTableViewCell.swift
//  GT1
//
//  Created by Pablo Pasqualino on 4/1/15.
//  Copyright (c) 2015 Pablo Pasqualino. All rights reserved.
//

import UIKit

class MuseosCellFiltroTableViewCell: UITableViewCell {
	
	@IBOutlet weak var filtroNombreTextField: UITextField!
	@IBAction func filtroNombreTextFieldAction(sender: UITextField) {
		
		sender.resignFirstResponder()

		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		let museosVC = appDelegate.traeVC("museos") as! MuseosViewController
		
		museosVC.buscar()
		
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
