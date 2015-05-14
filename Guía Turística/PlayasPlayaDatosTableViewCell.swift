//
//  PlayasPlayaDatosTableViewCell.swift
//  GT1
//
//  Created by Pablo Pasqualino on 4/10/15.
//  Copyright (c) 2015 Pablo Pasqualino. All rights reserved.
//

import UIKit

class PlayasPlayaDatosTableViewCell: UITableViewCell {

	@IBOutlet weak var playaNombre: UILabel!
	@IBOutlet weak var playaDireccion: UILabel!
	@IBOutlet weak var playaTelefonoLink: UIButton!
	@IBOutlet weak var playaEmailLink: UIButton!
	@IBOutlet weak var playaWebLink: UIButton!
	
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
