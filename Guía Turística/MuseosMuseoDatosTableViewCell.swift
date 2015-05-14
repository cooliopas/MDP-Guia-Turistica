//
//  MuseosMuseoDatosTableViewCell.swift
//  GT1
//
//  Created by Pablo Pasqualino on 4/10/15.
//  Copyright (c) 2015 Pablo Pasqualino. All rights reserved.
//

import UIKit

class MuseosMuseoDatosTableViewCell: UITableViewCell {

	@IBOutlet weak var museoNombre: UILabel!
	@IBOutlet weak var museoDireccion: UILabel!
	@IBOutlet weak var museoTelefonoLink: UIButton!
	@IBOutlet weak var museoEmailLink: UIButton!
	@IBOutlet weak var museoWebLink: UIButton!
	
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		
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
