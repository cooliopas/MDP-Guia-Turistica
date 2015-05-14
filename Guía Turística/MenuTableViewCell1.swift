//
//  MenuTableViewCell1.swift
//  GT1
//
//  Created by Pablo Pasqualino on 3/19/15.
//  Copyright (c) 2015 Pablo Pasqualino. All rights reserved.
//

import UIKit

class MenuTableViewCell1: UITableViewCell {

	@IBOutlet weak var icono: UIImageView!
	@IBOutlet weak var label: UILabel!
	
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
