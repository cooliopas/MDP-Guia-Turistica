//
//  ModeloBusquedaLugarMapaTableViewCell.swift
//  GT1
//
//  Created by Pablo Pasqualino on 4/6/15.
//  Copyright (c) 2015 Pablo Pasqualino. All rights reserved.
//

import UIKit

class ModeloBusquedaLugarMapaTableViewCell: UITableViewCell {

	var imagenMapa: UIImageView!
	
    override func awakeFromNib() {
        super.awakeFromNib()
		
		imagenMapa = UIImageView(frame: CGRectMake(0, 0, 320, 200))
		imagenMapa.alpha = 0
		
		self.contentView.addSubview(imagenMapa)

		separatorInset = UIEdgeInsetsZero

    }

	override var layoutMargins: UIEdgeInsets {
		get { return UIEdgeInsetsZero }
		set(newVal) {}
	}

}