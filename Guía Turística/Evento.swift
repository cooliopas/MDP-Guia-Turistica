//
//  Evento.swift
//  GT1
//
//  Created by Pablo Pasqualino on 4/2/15.
//  Copyright (c) 2015 Pablo Pasqualino. All rights reserved.
//

import Foundation

class Evento {
	var id: Int // IdEvento
	var nombre: String // Nombre
	var categoriaId: Int // IdCategoria
	var categoriaNombre: String // DescripcionCategoria
	var subCategoriaId: Int // IdSubCategoria
	var subCategoriaNombre: String // DescripcionSubCategoria
	var cicloId: Int // IdCiclo
	var cicloNombre: String // DescripcionCiclo
	var fecha: String
	var periodos: NSArray? // Periodos
	
	var detalle: NSDictionary? // NSArray Detalle
	var info = NSAttributedString(string: "Cargando ...", attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue", size: 13.0)!])
	var observaciones = NSAttributedString(string: "Cargando ...", attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue", size: 13.0)!])
	
	init(
			id: Int,
			nombre: String,
			categoriaId: Int,
			categoriaNombre: String,
			subCategoriaId: Int,
			subCategoriaNombre: String,
			cicloId: Int,
			cicloNombre: String,
			fecha: String,
			periodos: NSArray
		) {
		self.id = id
		self.nombre = nombre
		self.categoriaId = categoriaId
		self.categoriaNombre = categoriaNombre
		self.subCategoriaId = subCategoriaId
		self.subCategoriaNombre = subCategoriaNombre
		self.cicloId = cicloId
		self.cicloNombre = cicloNombre
		self.fecha = fecha
		self.periodos = periodos
	}
	
//	deinit {
//		println("deinit \(self.nombre)")
//	}
	
	class func eventosCargaDeJSON(eventosJSON: NSArray) -> [Evento] {
		
		var eventos = [Evento]()
		
		if eventosJSON.count>0 {

			let dateFormatter1 = NSDateFormatter()
			dateFormatter1.dateFormat = "yyyyMMdd"

			let dateFormatter2 = NSDateFormatter()
			dateFormatter2.dateFormat = "dd-MM-YYYY"
			
			let dateFormatter3 = NSDateFormatter()
			dateFormatter3.dateFormat = "EEEE"
			
			for resultado in eventosJSON {
				
				let id: Int = resultado["IdEvento"] as! Int
				let nombre: String = resultado["Nombre"] as! String
				let categoriaId = resultado["IdCategoria"] as! Int
				let categoriaNombre = resultado["DescripcionCategoria"] as! String
				let subCategoriaId = resultado["IdSubCategoria"] as! Int
				let subCategoriaNombre = resultado["DescripcionSubCategoria"] as! String
				let cicloId = resultado["IdCiclo"] as? Int ?? 0
				let cicloNombre = resultado["DescripcionCiclo"] as? String ?? ""
				var fecha: String = ""
				let periodos: NSArray = resultado["Periodos"] as! NSArray

				if periodos.count > 1 {
					
					var fechaDesde = NSDate()
					var fechaHasta = NSDate()
					
					for periodo in periodos {

						let fechaDesdeTemp = dateFormatter1.dateFromString(periodo["FechaDesde"]! as! String)
						let fechaHastaTemp = dateFormatter1.dateFromString(periodo["FechaHasta"]! as! String)
						
						if fechaDesdeTemp!.isLessThanDate(fechaDesde) {
							
							fechaDesde = fechaDesdeTemp!
							
						}

						if fechaHastaTemp!.isGreaterThanDate(fechaHasta) {
							
							fechaHasta = fechaHastaTemp!
							
						}
						
					}
					
					
					if fechaDesde != fechaHasta {
						
						fecha = "Fecha: del \(dateFormatter2.stringFromDate(fechaDesde)) al \(dateFormatter2.stringFromDate(fechaHasta))"
						
					} else {
						
						fecha = "Fecha: \(dateFormatter3.stringFromDate(fechaDesde)) \(dateFormatter2.stringFromDate(fechaDesde))"
						
					}

				} else {

					let fechaDesde = dateFormatter1.dateFromString(periodos[0]["FechaDesde"]! as! String)!
					let fechaHasta = dateFormatter1.dateFromString(periodos[0]["FechaHasta"]! as! String)!
					
					if fechaDesde != fechaHasta {
					
						fecha = "Fecha: del \(dateFormatter2.stringFromDate(fechaDesde)) al \(dateFormatter2.stringFromDate(fechaHasta))"
						
					} else {
						
						fecha = "Fecha: \(dateFormatter3.stringFromDate(fechaDesde)) \(dateFormatter2.stringFromDate(fechaDesde))"
						
					}
					
				}
				
				let nuevoEvento = Evento(
					id: id,
					nombre: nombre,
					categoriaId: categoriaId,
					categoriaNombre: categoriaNombre,
					subCategoriaId: subCategoriaId,
					subCategoriaNombre: subCategoriaNombre,
					cicloId: cicloId,
					cicloNombre: cicloNombre,
					fecha: fecha,
					periodos: periodos
				)
				
				eventos.append(nuevoEvento)
				
			}
			
		}
		
		return eventos
		
	}
	
	class func armaObservaciones(evento: Evento) {

//		println(evento.detalle!)
		
		if let detalle = evento.detalle, let observaciones = detalle["Observaciones"] as? String {
			
			evento.observaciones = NSAttributedString(string: observaciones, attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue", size: 13.0)!])
			
		} else {
			
			evento.observaciones = NSAttributedString(string: "Sin observaciones", attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue", size: 13.0)!])
			
		}
	
	}

	class func armaInfo(evento: Evento) {
		
		if let detalle = evento.detalle {

			let textFont = [NSFontAttributeName:UIFont(name: "HelveticaNeue", size: 13.0)!]
			let textFontBold = [NSFontAttributeName:UIFont(name: "HelveticaNeue-Bold", size: 13.0)!]
			
			var info  = NSMutableAttributedString()
			var salto = ""
			var empezo = 0
			
			if let valorEntrada = detalle["ValorEntrada"] as? String {
				
				info.appendAttributedString(NSAttributedString(string: salto + "Valor Entrada: ", attributes:textFontBold))
				info.appendAttributedString(NSAttributedString(string: "\(valorEntrada)", attributes:textFont))
				if empezo == 0 { empezo = 1; salto = "\n" }
				
			}
			
			if let lugaresArray = detalle["Lugares"] as? NSArray where lugaresArray.count > 0 {
				
				let lugares = Lugar.lugaresCargaDeJSON(lugaresArray)
			
				let lugar = lugares[0] as Lugar

				var datosLugar = "\(lugar.nombre)\n\(lugar.calleNombre) \(lugar.calleAltura)"
				
				if lugar.telefono1 != "" { datosLugar += "\n\(lugar.telefono1)" }
				if lugar.telefono2 != "" { datosLugar += "\n\(lugar.telefono2)" }
				if lugar.telefono3 != "" { datosLugar += "\n\(lugar.telefono3)" }
				
				info.appendAttributedString(NSAttributedString(string: salto + "Lugar:\n", attributes:textFontBold))
				info.appendAttributedString(NSAttributedString(string: datosLugar, attributes:textFont))
				if empezo == 0 { empezo = 1; salto = "\n" }
				
			}
			
			if empezo == 1 {
				
				evento.info = info
				
			} else {
				
				evento.info = NSAttributedString(string: "Sin detalles adicionales", attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue", size: 13.0)!])
				
			}
			
		}
		
	}
	
}