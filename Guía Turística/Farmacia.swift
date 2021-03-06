//
//  Farmacia.swift
//  GT1
//
//  Created by Pablo Pasqualino on 4/2/15.
//  Copyright (c) 2015 Pablo Pasqualino. All rights reserved.
//

import Foundation
import CoreLocation

class Farmacia {
	var coordenadas: CLLocationCoordinate2D
	var nombre: String
	var direccion: String
	var direccionDeTurno: String
	var tipo: Int
	var distancia: Double?
	
	init(
		coordenadas: CLLocationCoordinate2D,
		nombre: String,
		direccion: String,
		direccionDeTurno: String,
		tipo: Int // 0 = SUBE, 1 = UTE
		) {
			self.coordenadas = coordenadas
			self.nombre = nombre
			self.direccion = direccion
			self.direccionDeTurno = direccionDeTurno
			self.tipo = tipo
	}
		
}