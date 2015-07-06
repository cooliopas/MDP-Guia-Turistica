//
//  Cajero.swift
//  GT1
//
//  Created by Pablo Pasqualino on 4/2/15.
//  Copyright (c) 2015 Pablo Pasqualino. All rights reserved.
//

import Foundation
import CoreLocation

class Cajero {
	var coordenadas: CLLocationCoordinate2D
	var banco: String
	var direccion: String
	var tipo: Int
	var distancia: Double?
	
	init(
		coordenadas: CLLocationCoordinate2D,
		banco: String,
		direccion: String,
		tipo: Int // 0 = BANELCO, 1 = LINK
		) {
			self.coordenadas = coordenadas
			self.banco = banco
			self.direccion = direccion
			self.tipo = tipo
	}
		
}