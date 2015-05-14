//
//  HotelesYAlojamientoCellFiltroTableViewCell.swift
//  GT1
//
//  Created by Pablo Pasqualino on 4/1/15.
//  Copyright (c) 2015 Pablo Pasqualino. All rights reserved.
//

import UIKit

class HotelesYAlojamientoCellFiltroTableViewCell: UITableViewCell {
	
	@IBOutlet weak var filtroNombreTextField: UITextField!
	@IBAction func filtroNombreTextFieldAction(sender: UITextField) {
		
		sender.resignFirstResponder()

		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		let hotelesYAlojamientoVC = appDelegate.traeVC("hotelesYAlojamiento") as! HotelesYAlojamientoViewController
		
		hotelesYAlojamientoVC.buscar()
		
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
