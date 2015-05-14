//
//  PuestoCarga.swift
//  GT1
//
//  Created by Pablo Pasqualino on 4/2/15.
//  Copyright (c) 2015 Pablo Pasqualino. All rights reserved.
//

import Foundation
import CoreLocation

class PuestoCarga {
	var coordenadas: CLLocationCoordinate2D
	var nombre: String
	var direccion: String
	var tipo: Int
	var distancia: Double?
	
	init(
		coordenadas: CLLocationCoordinate2D,
		nombre: String,
		direccion: String,
		tipo: Int // 0 = SUBE, 1 = UTE
		) {
			self.coordenadas = coordenadas
			self.nombre = nombre
			self.direccion = direccion
			self.tipo = tipo
	}
	
	class func puestosCargaCargaDeJSON(puestosCargaJSON: NSArray,tipo: Int) -> [PuestoCarga] {
		
		var puestosCarga = [PuestoCarga]()
		
		if puestosCargaJSON.count>0 {
			
			for resultado in puestosCargaJSON {
				
				let coordenadas: CLLocationCoordinate2D = CLLocationCoordinate2DMake(resultado["latitud"] as! CLLocationDegrees,resultado["longitud"] as! CLLocationDegrees)
				let nombre: String = resultado["nombre"] as? String ?? ""
				let direccion: String = resultado["direccion"] as? String ?? ""
				
				let nuevoPuestoCarga = PuestoCarga(
					coordenadas: coordenadas,
					nombre: nombre,
					direccion: direccion,
					tipo: tipo
				)
				
				puestosCarga.append(nuevoPuestoCarga)
				
			}
			
		}
		
		return puestosCarga
		
	}
	
}