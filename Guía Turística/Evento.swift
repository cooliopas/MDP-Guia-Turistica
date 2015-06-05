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
	
    var categoriasNombresLindos: [Int : String]
    
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
            
        categoriasNombresLindos = [
            5: "Acontecimientos Deportivos",
            1: "Ballet y Danzas",
            16: "Cena, Show, Peña, Baile",
            2: "Charlas y Conferencias",
            3: "Cine",
            14: "Circos",
            4: "Concursos",
            13: "Congresos y Otros Acontecimientos Programados",
            18: "Desfiles",
            6: "Espectáculos Integrales",
            7: "Exposiciones, Muestras y Ferias",
            19: "Festivales",
            8: "Fiestas",
            9: "Homenajes",
            10: "Infantiles",
            11: "Música",
            17: "Talleres",
            12: "Teatros"
        ]
            
	}
	
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
    
    class func datos(idSeccion: String, evento: Evento, view: UIView) {
        
        let nombre = evento.nombre.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        let eventoCategoria = evento.categoriasNombresLindos[evento.categoriaId]!
        let eventoSubCategoria = evento.subCategoriaNombre != "" ? evento.subCategoriaNombre : ""
        let eventoFecha = evento.fecha
        
        let campo1 = nombre
        let campo2 = eventoCategoria
        let campo3 = eventoSubCategoria
        let campo4 = eventoFecha
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 40))
        label.font = UIFont.boldSystemFontOfSize(15)
        label.textColor = UIColor(red: 116/255, green: 154/255, blue: 201/255, alpha: 1)
        label.numberOfLines = 2
        label.text = campo1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        label.frame.size = label.sizeThatFits(CGSize(width: view.frame.size.width, height: 80))
        view.addSubview(label)
        
        let label2 = UILabel(frame: CGRect(x: 0, y: label.frame.size.height - 4, width: view.frame.size.width, height: 20))
        label2.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
        label2.numberOfLines = 1
        label2.text = campo2
        label2.adjustsFontSizeToFitWidth = true
        label2.minimumScaleFactor = 0.5
        view.addSubview(label2)
        
        let label3 = UILabel(frame: CGRect(x: 0, y: label2.frame.origin.y + label2.frame.size.height - 6, width: view.frame.size.width, height: 20))
        label3.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
        label3.numberOfLines = 1
        label3.text = campo3
        label3.adjustsFontSizeToFitWidth = true
        label3.minimumScaleFactor = 0.5
        
        if campo2 != campo3 && campo3 != "" {
        
            view.addSubview(label3)

        }
            
        let label4 = UILabel(frame: CGRect(x: 0, y: label3.frame.origin.y + label3.frame.size.height + (label.frame.size.height > 25 ? -6 : 9), width: view.frame.size.width, height: 20))
        label4.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
        label4.numberOfLines = 1
        label4.text = campo4
        label4.adjustsFontSizeToFitWidth = true
        label4.minimumScaleFactor = 0.5
        view.addSubview(label4)

    }
    
    class func datosDetalle(idSeccion: String, evento: Evento, view: UIView) {
        
        var arrayDatos: [[String: NSObject]] = []
        
        let nombre = evento.nombre.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        let eventoCategoria = evento.categoriasNombresLindos[evento.categoriaId]!
        let eventoSubCategoria = evento.subCategoriaNombre != "" ? evento.subCategoriaNombre : ""
        let eventoFecha = evento.fecha
        
        arrayDatos.append(["texto": nombre, "font": UIFont.boldSystemFontOfSize(18), "color": UIColor(red: 116/255, green: 154/255, blue: 201/255, alpha: 1), "lineas": 2, "paddingTop": 0])
        arrayDatos.append(["texto": eventoCategoria, "font": UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline), "color": UIColor.blackColor(), "lineas": 1, "paddingTop": 0])
        
        if eventoCategoria != eventoSubCategoria && eventoSubCategoria != "" {
        
            arrayDatos.append(["texto": eventoSubCategoria, "font": UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline), "color": UIColor.blackColor(), "lineas": 1, "paddingTop": 0])
            
        }
        
        arrayDatos.append(["texto": eventoFecha, "font": UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline), "color": UIColor.blackColor(), "lineas": 1, "paddingTop": 10])
        
        var yActual: CGFloat = 0
        
        for dato in arrayDatos {
            
            if dato["texto"]! != "" {
                
                let label = UILabel(frame: CGRect(x: 0, y: yActual + (dato["paddingTop"]! as! CGFloat), width: view.frame.size.width, height: (dato["lineas"]! as! Int) > 1 ? 40 : 20))
                label.font = dato["font"]! as! UIFont
                label.textColor = dato["color"]! as! UIColor
                label.numberOfLines = dato["lineas"]! as! Int
                label.text = dato["texto"]! as? String
                label.adjustsFontSizeToFitWidth = true
                label.minimumScaleFactor = 0.7
                if (dato["lineas"]! as! Int) > 1 { label.frame.size = label.sizeThatFits(CGSize(width: view.frame.size.width, height: 80)) }
                view.addSubview(label)
                
                yActual += label.frame.size.height + (dato["paddingTop"]! as! CGFloat)
                
            }
            
        }
        
        view.frame.size.height = yActual + 8
        
    }
    
    class func buscar(opcionesItems: [String: [[String: String]]],opcionesValores: [String: NSObject], completionHandler: ([Evento], String?) -> ()) {
        
        var resteaParametros: [String : NSObject] = ["Token":"01234567890123456789012345678901"]
        var resteaApi = "Evento"
        var resteaServicio = "Buscar"
        var resteaNombreArrayResultados = "Eventos"
        var resteaErrorSinFiltros = "Ocurrió un error."
        var resteaErrorSinResultados = "No se encontraron eventos para su búsqueda."
        
        var idCategoria = 0
        var filtroNombre = ""
        
        if let opcionesCategoria = opcionesItems["categoria"] {
            if let opcionesCategoriaValor = opcionesValores["categoria"] as? Int {
                if let opcionesCategoriaId = opcionesCategoria[opcionesCategoriaValor]["id"] {
                    idCategoria = opcionesCategoriaId.toInt()!
                }
            }
        }
        
        filtroNombre = opcionesValores["nombre"]! as! String

        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let fechaDesde = dateFormatter.stringFromDate(NSDate())
        let fechaHasta = dateFormatter.stringFromDate(NSDate().dateByAddingTimeInterval(90 * 24 * 60 * 60))
        
        resteaParametros["IdCategoria"] = idCategoria
        resteaParametros["Nombre"] = filtroNombre
        resteaParametros["FechaDesde"] = fechaDesde
        resteaParametros["FechaHasta"] = fechaHasta

        restea(resteaApi,resteaServicio,resteaParametros) { (request, response, JSON, error) in
            
            var eventos: [Evento] = []
            var mensajeError: String?
            
            if error == nil, let info = JSON as? NSDictionary where (info[resteaNombreArrayResultados] as! NSArray).count > 0 {
                
                eventos = Evento.eventosCargaDeJSON(info[resteaNombreArrayResultados] as! NSArray)
                
            } else {
                
                if error?.code == -1001 {
                    
                    mensajeError = "Ocurrió un error al leer los datos.\nPor favor intente nuevamente."
                    
                } else {
                    
                    if let info = JSON as? NSDictionary {
                        
                        if (info["Estado"] as? String) == "ERROR" {
                            
                            mensajeError = resteaErrorSinFiltros
                            
                        } else {
                            
                            mensajeError = resteaErrorSinResultados
                            
                        }
                        
                    } else {
                        
                        mensajeError = "Ocurrió un error."
                        
                    }
                    
                }
                
            }
            
            completionHandler(eventos,mensajeError)
            
        }
        
    }
	
}