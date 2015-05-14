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
	
	class func farmaciasCargaDeJSON(farmaciasJSON: NSArray,tipo: Int) -> [Farmacia] {
		
		var farmacia = [Farmacia]()
		
		if farmaciasJSON.count>0 {
			
			for resultado in farmaciasJSON {
				
				let coordenadas: CLLocationCoordinate2D = CLLocationCoordinate2DMake(resultado["latitud"] as! CLLocationDegrees,resultado["longitud"] as! CLLocationDegrees)
				let nombre: String = resultado["nombre"] as? String ?? ""
				let direccion: String = resultado["direccion"] as? String ?? ""
				let direccionDeTurno: String = resultado["direccionDeTurno"] as? String ?? ""
				
				let nuevaFarmacia = Farmacia(
					coordenadas: coordenadas,
					nombre: nombre,
					direccion: direccion,
					direccionDeTurno: direccionDeTurno,
					tipo: tipo
				)
				
				farmacia.append(nuevaFarmacia)
				
			}
			
		}
		
		return farmacia
		
	}
	
}