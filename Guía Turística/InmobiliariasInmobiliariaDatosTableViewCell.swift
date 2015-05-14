//
//  InmobiliariasInmobiliariaDatosTableViewCell.swift
//  GT1
//
//  Created by Pablo Pasqualino on 4/10/15.
//  Copyright (c) 2015 Pablo Pasqualino. All rights reserved.
//

import UIKit

class InmobiliariasInmobiliariaDatosTableViewCell: UITableViewCell {

	@IBOutlet weak var inmobiliariaNombre: UILabel!
	@IBOutlet weak var inmobiliariaTitular: UILabel!
	@IBOutlet weak var inmobiliariaDireccion: UILabel!
	@IBOutlet weak var inmobiliariaTelefonoLink: UIButton!
	@IBOutlet weak var inmobiliariaEmailLink: UIButton!
	@IBOutlet weak var inmobiliariaWebLink: UIButton!
	
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
