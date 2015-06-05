//
//  ModeloBusquedaCellFiltroTableViewCell.swift
//  GT1
//
//  Created by Pablo Pasqualino on 4/1/15.
//  Copyright (c) 2015 Pablo Pasqualino. All rights reserved.
//

import UIKit

class ModeloBusquedaCellFiltroTableViewCell: UITableViewCell {
	
    var viewPrincial: ModeloBusquedaViewController!
    
	@IBOutlet weak var filtroNombreTextField: UITextField!
    
	@IBAction func filtroNombreTextFieldAction(sender: UITextField) {
		
		sender.resignFirstResponder()

		viewPrincial.buscar()
		
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

}
