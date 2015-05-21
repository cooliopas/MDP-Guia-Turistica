//
//  Lugar.swift
//  GT1
//
//  Created by Pablo Pasqualino on 4/2/15.
//  Copyright (c) 2015 Pablo Pasqualino. All rights reserved.
//

import Foundation

class Lugar {
	var id: Int // IdLugar
	var calleNombre: String // AlturaKM
	var calleAltura: String // CalleRuta
	var email: String // Email
	var foto: String // Fotos["UrlFoto"]
	var rubroId: Int // IdRubro
	var nombre: String // Nombre
	var subRubroId: Int // SubRubros["IdSubRubro"]
	var subRubroNombre: String // Nombre
	var telefono1: String // Telefono1
	var telefono2: String // Telefono2
	var telefono3: String // Telefono3
	var web: String // Web
	var detalle: NSDictionary? // NSArray Detalle
	var info = NSAttributedString(string: "Cargando ...", attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue", size: 13.0)!])
	var observaciones = NSAttributedString(string: "Cargando ...", attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue", size: 13.0)!])
	var latitud: Double
	var longitud: Double
	var fotoCache: UIImage?
	var distancia: Double?
	var row: Int?
	var tabla: UITableView?
	
	init(
			id: Int,
			calleNombre: String,
			calleAltura: String,
			email: String,
			foto: String,
			rubroId: Int,
			nombre: String,
			subRubroId: Int,
			subRubroNombre: String,
			telefono1: String,
			telefono2: String,
			telefono3: String,
			web: String,
			latitud: Double,
			longitud: Double
		) {
		self.id = id
		self.calleNombre = calleNombre
		self.calleAltura = calleAltura
		self.email = email
		self.foto = foto
		self.rubroId = rubroId
		self.nombre = nombre
		self.subRubroId = subRubroId
		self.subRubroNombre = subRubroNombre
		self.telefono1 = telefono1
		self.telefono2 = telefono2
		self.telefono3 = telefono3
		self.web = web
		self.latitud = latitud
		self.longitud = longitud
	}
	
//	deinit {
//		println("deinit \(self.nombre)")
//	}
	
	class func lugaresCargaDeJSON(lugaresJSON: NSArray) -> [Lugar] {
		
		var lugares = [Lugar]()
		
		if lugaresJSON.count>0 {
			
			for resultado in lugaresJSON {
				
//				println(resultado)
				
				let id: Int = resultado["IdLugar"] as! Int
				let calleNombre: String = resultado["CalleRuta"] as? String ?? ""
				var calleAltura: String = resultado["AlturaKM"] as? String ?? ""
				if calleAltura == "0" { calleAltura = "" }
				let email: String = resultado["Email"] as? String ?? ""
				let fotos = (resultado["Fotos"]! as! NSArray)
				var foto = ""
				if fotos.count > 0 { foto = fotos[0]["UrlFoto"]! as! String }
				let rubroId: Int = resultado["IdRubro"] as! Int
				let nombre: String = resultado["Nombre"] as! String
				let subRubroId = (resultado["SubRubros"]! as! NSArray)[0]["IdSubRubro"]! as! Int
				let subRubroNombre = (resultado["SubRubros"]! as! NSArray)[0]["DescripcionSubRubro"]! as! String
				let telefono1: String = resultado["Telefono1"] as? String ?? ""
				let telefono2: String = resultado["Telefono2"] as? String ?? ""
				let telefono3: String = resultado["Telefono3"] as? String ?? ""
				let web: String = resultado["Web"] as? String ?? ""
				var latitud: Double = 0
				if let latitudValor = resultado["Latitud"] as? NSString {
					latitud = latitudValor.doubleValue
				}
				var longitud: Double = 0
				if let longitudValor = resultado["Longitud"] as? NSString {
					longitud = longitudValor.doubleValue
				}
				
				let nuevoLugar = Lugar(
					id: id,
					calleNombre: calleNombre,
					calleAltura: calleAltura,
					email: email,
					foto: foto,
					rubroId: rubroId,
					nombre: nombre,
					subRubroId: subRubroId,
					subRubroNombre: subRubroNombre,
					telefono1: telefono1,
					telefono2: telefono2,
					telefono3: telefono3,
					web: web,
					latitud: latitud,
					longitud: longitud
				)

				let urlImagen = foto.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
				
				if urlImagen != "" {
					
					let imgURL = NSURL(string: urlImagen!)
					
					let request: NSURLRequest = NSURLRequest(URL: imgURL!)
					NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
						
						if error == nil {
							
							nuevoLugar.fotoCache = UIImage(data: data)
							
							if nuevoLugar.row != nil {
								
								dispatch_async(dispatch_get_main_queue(), {
									
									if let cellVisible = nuevoLugar.tabla!.cellForRowAtIndexPath(NSIndexPath(forRow: nuevoLugar.row!, inSection: 0)) as? MuseosResultadosMuseoCellTableViewCell {
										cellVisible.imagen.image = nuevoLugar.fotoCache
										cellVisible.imagen.frame.size.width = 100
										cellVisible.imagen.frame.size.height = 80
									}
								})
								
							}
							
						} else {
							
//							println("Error para bajar la imagen")
							
						}
					})
					
				}
				
				lugares.append(nuevoLugar)
				
			}
			
		}
		
		return lugares
		
	}
	
	class func armaObservaciones(lugar: Lugar) {

		if let detalle = lugar.detalle, let observaciones = detalle["Observaciones"] as? String {
			
			lugar.observaciones = NSAttributedString(string: observaciones, attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue", size: 13.0)!])
			
		} else {
			
			lugar.observaciones = NSAttributedString(string: "Sin observaciones", attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue", size: 13.0)!])
			
		}
	
	}
	
	class func armaInfo(lugar: Lugar) {
		
		if let detalle = lugar.detalle {
			
//			println(detalle)
			
			let textFont: [NSObject : AnyObject] = [NSFontAttributeName:UIFont(name: "HelveticaNeue", size: 13.0)!]
			let textFontBold = [NSFontAttributeName:UIFont(name: "HelveticaNeue-Bold", size: 13.0)!]
			
			var info  = NSMutableAttributedString()
			var salto = ""
			var empezo = 0

			
			if let horarioVisita = detalle["HorarioVisita"] as? String {

				info.appendAttributedString(NSAttributedString(string: salto + "Horario de Visita: ", attributes:textFontBold))
				info.appendAttributedString(NSAttributedString(string: "\(horarioVisita)", attributes:textFont))
				if empezo == 0 { empezo = 1; salto = "\n" }
				
			}
			if let valorEntrada = detalle["ValorEntrada"] as? String {
				
				info.appendAttributedString(NSAttributedString(string: salto + "Valor Entrada: ", attributes:textFontBold))
				info.appendAttributedString(NSAttributedString(string: "\(valorEntrada)", attributes:textFont))
				if empezo == 0 { empezo = 1; salto = "\n" }
				
			}
			if let habitaciones = detalle["Habitaciones"] as? Int {
				
				info.appendAttributedString(NSAttributedString(string: salto + "Habitaciones: ", attributes:textFontBold))
				info.appendAttributedString(NSAttributedString(string: "\(habitaciones)", attributes:textFont))
				if empezo == 0 { empezo = 1; salto = "\n" }
				
			}
			if let plazas = detalle["Plazas"] as? Int {
				
				info.appendAttributedString(NSAttributedString(string: salto + "Plazas: ", attributes:textFontBold))
				info.appendAttributedString(NSAttributedString(string: "\(plazas)", attributes:textFont))
				if empezo == 0 { empezo = 1; salto = "\n" }
			
			}
			if let carpas = detalle["CantidadCarpas"] as? Int {
				
				info.appendAttributedString(NSAttributedString(string: salto + "Carpas: ", attributes:textFontBold))
				info.appendAttributedString(NSAttributedString(string: "\(carpas)", attributes:textFont))
				if empezo == 0 { empezo = 1; salto = "\n" }
				
			}
			if let sombrillas = detalle["CantidadSombrillas"] as? Int {
				
				info.appendAttributedString(NSAttributedString(string: salto + "Sombrillas: ", attributes:textFontBold))
				info.appendAttributedString(NSAttributedString(string: "\(sombrillas)", attributes:textFont))
				if empezo == 0 { empezo = 1; salto = "\n" }
				
			}
			if let servicios = detalle["ServiciosAlojamiento"] as? NSArray where servicios.count > 0 {

				info.appendAttributedString(NSAttributedString(string: salto + "Servicios:\n", attributes:textFontBold))
				
				var index = 1
				var textoTemp = ""
				
				for serviciosItem in servicios {
					
					let serviciosItemTexto = serviciosItem["DescripcionServicioAlojamiento"] as! String
					
					textoTemp += " ● \(serviciosItemTexto)"
					
					if index < servicios.count {
						
						textoTemp += "\n"
						
					}
					
					index++
					
				}
				
				info.appendAttributedString(NSAttributedString(string: "\(textoTemp)", attributes:textFont))
				if empezo == 0 { empezo = 1; salto = "\n" }
				
			}
			if let serviciosBalneario = detalle["ServiciosBalneario"] as? NSArray where serviciosBalneario.count > 0 {
				
				info.appendAttributedString(NSAttributedString(string: salto + "Servicios:\n", attributes:textFontBold))
				
				var index = 1
				var textoTemp = ""
				
				for serviciosItem in serviciosBalneario {
					
					let serviciosItemTexto = serviciosItem["DescripcionServicioBalneario"] as! String
					
					textoTemp += " ● \(serviciosItemTexto)"
					
					if index < serviciosBalneario.count {
						
						textoTemp += "\n"
						
					}
					
					index++
					
				}
				
				info.appendAttributedString(NSAttributedString(string: "\(textoTemp)", attributes:textFont))
				if empezo == 0 { empezo = 1; salto = "\n" }
				
			}
			if let climatizacion = detalle["Climatizacion"] as? NSArray where climatizacion.count > 0 {
			
				info.appendAttributedString(NSAttributedString(string: salto + "Climatización:\n", attributes:textFontBold))
				
				var index = 1
				var textoTemp = ""

				for climatizacionItem in climatizacion {
					
					let climatizacionItemTexto = climatizacionItem["DescripcionClimatizacion"] as! String
					
					textoTemp += " ● \(climatizacionItemTexto)"
					
					if index < climatizacion.count {
						
						textoTemp += "\n"
						
					}

					index++
					
				}
				
				info.appendAttributedString(NSAttributedString(string: "\(textoTemp)", attributes:textFont))
				if empezo == 0 { empezo = 1; salto = "\n" }
			
			}
			if let periodos = detalle["PeriodosFuncionamiento"] as? NSArray where periodos.count > 0 {
				
				info.appendAttributedString(NSAttributedString(string: salto + "Período de funcionamiento:\n", attributes:textFontBold))
				
				var index = 1
				var textoTemp = ""

				for periodosItem in periodos {
					
					let periodosItemTexto = periodosItem["DescripcionPeriodoFuncionamiento"] as! String
					
					textoTemp += " ● \(periodosItemTexto)"
					
					if index < periodos.count {
						
						textoTemp += "\n"
						
					}
					
					index++
					
				}
				
				info.appendAttributedString(NSAttributedString(string: "\(textoTemp)", attributes:textFont))
				if empezo == 0 { empezo = 1; salto = "\n" }
				
			}
			if let gremio = detalle["Gremios"] as? NSArray where gremio.count > 0 {
				
				if let gremioNombre = gremio[0]["DescripcionGremio"] as? String {

					info.appendAttributedString(NSAttributedString(string: salto + "Gremio: ", attributes:textFontBold))
					info.appendAttributedString(NSAttributedString(string: "\(gremioNombre)", attributes:textFont))
					if empezo == 0 { empezo = 1; salto = "\n" }
					
				}
				
			}
			if let actividadRecreativa = detalle["ActividadesRecreativas"] as? NSArray where actividadRecreativa.count > 0 {
				
				info.appendAttributedString(NSAttributedString(string: salto + "Tipo de Recreación:\n", attributes:textFontBold))
				
				var index = 1
				var textoTemp = ""
				
				for actividadItem in actividadRecreativa {
					
					let actividadItemTexto = actividadItem["DescripcionActividadRecreativa"] as! String
					
					textoTemp += " ● \(actividadItemTexto)"
					
					if index < actividadRecreativa.count {
						
						textoTemp += "\n"
						
					}
					
					index++
					
				}
				
				info.appendAttributedString(NSAttributedString(string: "\(textoTemp)", attributes:textFont))
				if empezo == 0 { empezo = 1; salto = "\n" }
				
			}
			if let tiposCocina = detalle["TiposCocina"] as? NSArray where tiposCocina.count > 0 {
				
				if let descripcionTipoCocina = tiposCocina[0]["DescripcionTipoCocina"] as? String {
				
					info.appendAttributedString(NSAttributedString(string: salto + "Tipo de cocina: ", attributes:textFontBold))
					info.appendAttributedString(NSAttributedString(string: "\(descripcionTipoCocina)", attributes:textFont))
					if empezo == 0 { empezo = 1; salto = "\n" }

				}
					
			}
			if let serviciosInstalaciones = detalle["ServiciosInstalaciones"] as? NSArray where serviciosInstalaciones.count > 0 {
				
				info.appendAttributedString(NSAttributedString(string: salto + "Servicios e instalaciones:\n", attributes:textFontBold))
				
				var index = 1
				var textoTemp = ""
				
				for servicio in serviciosInstalaciones {
					
					let servicioTexto = servicio["DescripcionServicioInstalacion"] as! String
					
					textoTemp += " ● \(servicioTexto)"
					
					if index < serviciosInstalaciones.count {
						
						textoTemp += "\n"
						
					}
					
					index++
					
				}
				
				info.appendAttributedString(NSAttributedString(string: "\(textoTemp)", attributes:textFont))
				if empezo == 0 { empezo = 1; salto = "\n" }
				
			}
			if let zona = detalle["DescripcionZona"] as? String {
				
				info.appendAttributedString(NSAttributedString(string: salto + "Zona: ", attributes:textFontBold))
				info.appendAttributedString(NSAttributedString(string: "\(zona)", attributes:textFont))
				if empezo == 0 { empezo = 1; salto = "\n" }
			
			}
			if let capacidadInvierno = detalle["CapacidadInvierno"] as? Int,
				let capacidadVerano = detalle["CapacidadVerano"] as? Int {
				
				info.appendAttributedString(NSAttributedString(string: salto + "Capacidad: ", attributes:textFontBold))

				var textoCapacidad = ""
					
				if capacidadInvierno != capacidadVerano {
					
					textoCapacidad = "\(capacidadInvierno) en Invierno / \(capacidadVerano) en Verano"
					
				} else {
					
					textoCapacidad = "\(capacidadVerano)"
					
				}
					
				info.appendAttributedString(NSAttributedString(string: textoCapacidad, attributes:textFont))
				if empezo == 0 { empezo = 1; salto = "\n" }
				
			}
			if let accesibilidad = detalle["DescripcionAccesibilidad"] as? String {
				
				info.appendAttributedString(NSAttributedString(string: salto + "Ref. Accesibilidad: ", attributes:textFontBold))
				info.appendAttributedString(NSAttributedString(string: "\(accesibilidad)", attributes:textFont))
				if empezo == 0 { empezo = 1; salto = "\n" }
				
			}
			if let accesibilidadDetalle = detalle["DetalleAccesibilidad"] as? String {
				
				info.appendAttributedString(NSAttributedString(string: salto + "Accesibilidad: ", attributes:textFontBold))
				info.appendAttributedString(NSAttributedString(string: "\(accesibilidadDetalle)", attributes:textFont))
				if empezo == 0 { empezo = 1; salto = "\n" }
				
			}
			if let transporte = detalle["Transporte"] as? String {
				
				info.appendAttributedString(NSAttributedString(string: salto + "Lineas de Colectivo: ", attributes:textFontBold))
				info.appendAttributedString(NSAttributedString(string: "\(transporte)", attributes:textFont))
				if empezo == 0 { empezo = 1; salto = "\n" }
				
			}
			if let ingresoANivel = detalle["IngresoANivel"] as? Int where ingresoANivel == 1 {
				
				info.appendAttributedString(NSAttributedString(string: salto + "Ingreso a nivel: ", attributes:textFontBold))
				info.appendAttributedString(NSAttributedString(string: "Si", attributes:textFont))
				if empezo == 0 { empezo = 1; salto = "\n" }
				
			}
			if let braile = detalle["MenuBraile"] as? Int where braile == 1 {
				
				info.appendAttributedString(NSAttributedString(string: salto + "Menú en Braille: ", attributes:textFontBold))
				info.appendAttributedString(NSAttributedString(string: "Si", attributes:textFont))
				if empezo == 0 { empezo = 1; salto = "\n" }
				
			}
			if let celiacos = detalle["MenuCeliacos"] as? Int where celiacos == 1 {
				
				info.appendAttributedString(NSAttributedString(string: salto + "Menúes para Celíacos: ", attributes:textFontBold))
				info.appendAttributedString(NSAttributedString(string: "Si", attributes:textFont))
				if empezo == 0 { empezo = 1; salto = "\n" }
				
			}
			if let rampa = detalle["RampaDeAcceso"] as? Int where rampa == 1 {
				
				info.appendAttributedString(NSAttributedString(string: salto + "Rampa de acceso: ", attributes:textFontBold))
				info.appendAttributedString(NSAttributedString(string: "Si", attributes:textFont))
				if empezo == 0 { empezo = 1; salto = "\n" }
				
			}
			if let sanitario = detalle["SanitarioAccesible"] as? Int where sanitario == 1 {
				
				info.appendAttributedString(NSAttributedString(string: salto + "Sanit. Publ. Access.: ", attributes:textFontBold))
				info.appendAttributedString(NSAttributedString(string: "Si", attributes:textFont))
				if empezo == 0 { empezo = 1; salto = "\n" }
				
			}
			if let habitacionAccesible = detalle["HabitacionAccesible"] as? Int where habitacionAccesible == 1 {
				
				info.appendAttributedString(NSAttributedString(string: salto + "Habitación accesible: ", attributes:textFontBold))
				info.appendAttributedString(NSAttributedString(string: "Si", attributes:textFont))
				if empezo == 0 { empezo = 1; salto = "\n" }
				
			}
			if let piso = detalle["Piso"] as? String {
				
				info.appendAttributedString(NSAttributedString(string: salto + "Piso: ", attributes:textFontBold))
				info.appendAttributedString(NSAttributedString(string: "\(piso)", attributes:textFont))
				if empezo == 0 { empezo = 1; salto = "\n" }
				
			}
			if let oficina = detalle["Oficina"] as? String {
				
				info.appendAttributedString(NSAttributedString(string: salto + "Oficina: ", attributes:textFontBold))
				info.appendAttributedString(NSAttributedString(string: "\(oficina)", attributes:textFont))
				if empezo == 0 { empezo = 1; salto = "\n" }
				
			}
			if let celular = detalle["Celular"] as? String {
				
				var textFontConLink = textFont
				textFontConLink[NSLinkAttributeName] = "tel://\(celular)"
				
				info.appendAttributedString(NSAttributedString(string: salto + "Celular: ", attributes:textFontBold))
				info.appendAttributedString(NSAttributedString(string: "\(celular)", attributes:textFontConLink))
				if empezo == 0 { empezo = 1; salto = "\n" }
				
			}
			if let zonasOperacion = detalle["ZonasOperacion"] as? NSArray where zonasOperacion.count > 0 {
				
				info.appendAttributedString(NSAttributedString(string: salto + "Zonas de operación:\n", attributes:textFontBold))
				
				var index = 1
				var textoTemp = ""
				
				for zonasOperacionItem in zonasOperacion {
					
					let zonasOperacionItemTexto = zonasOperacionItem["DescripcionZonaOperacion"] as! String
					
					textoTemp += " ● \(zonasOperacionItemTexto)"
					
					if index < zonasOperacion.count {
						
						textoTemp += "\n"
						
					}
					
					index++
					
				}
				
				info.appendAttributedString(NSAttributedString(string: "\(textoTemp)", attributes:textFont))
				if empezo == 0 { empezo = 1; salto = "\n" }
				
			}
			
			if empezo == 1 {
				
				lugar.info = info
				
			} else {
				
				lugar.info = NSAttributedString(string: "Sin detalles adicionales", attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue", size: 13.0)!])
				
			}
			
		}
		
	}
	
}