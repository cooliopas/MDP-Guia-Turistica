//
//  MuseosMuseoObservacionesTableViewCell.swift
//  GT1
//
//  Created by Pablo Pasqualino on 4/10/15.
//  Copyright (c) 2015 Pablo Pasqualino. All rights reserved.
//

import UIKit

class MuseosMuseoObservacionesTableViewCell: UITableViewCell {

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

	override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
