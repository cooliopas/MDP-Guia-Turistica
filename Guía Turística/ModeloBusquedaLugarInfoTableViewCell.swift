//
//  ModeloBusquedaLugarInfoTableViewCell.swift
//  GT1
//
//  Created by Pablo Pasqualino on 4/10/15.
//  Copyright (c) 2015 Pablo Pasqualino. All rights reserved.
//

import UIKit

class ModeloBusquedaLugarInfoTableViewCell: UITableViewCell {
	
	@IBOutlet weak var texto: UILabel!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		// Initialization code
		
		separatorInset = UIEdgeInsetsZero
		
	}
	
	override var layoutMargins: UIEdgeInsets {
		get { return UIEdgeInsetsZero }
		set(newVal) {}
	}
	
}
