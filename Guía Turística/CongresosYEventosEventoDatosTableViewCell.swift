//
//  CongresosYEventosEventoDatosTableViewCell.swift
//  GT1
//
//  Created by Pablo Pasqualino on 4/10/15.
//  Copyright (c) 2015 Pablo Pasqualino. All rights reserved.
//

import UIKit

class CongresosYEventosEventoDatosTableViewCell: UITableViewCell {

	@IBOutlet weak var eventoNombre: UILabel!
	@IBOutlet weak var eventoCategoria: UILabel!
	@IBOutlet weak var eventoSubCategoria: UILabel!
	@IBOutlet weak var eventoFecha: UILabel!
	
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
