//
//  PuestoCargaAnnotation.swift
//  GT1
//
//  Created by Pablo Pasqualino on 4/26/15.
//  Copyright (c) 2015 Pablo Pasqualino. All rights reserved.
//

import UIKit
import MapKit

class PuestoCargaAnnotation: NSObject, MKAnnotation {
	
	var coordinate: CLLocationCoordinate2D
	var title: String
	var subtitle: String
	var tipo: Int
	var puestoCarga: PuestoCarga?
	
	override init() {
		self.coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
		self.title = ""
		self.subtitle = ""
		self.tipo = 0
	}
	
}