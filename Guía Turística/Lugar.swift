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
							
                            if let fotoCache = UIImage(data: data) {
							
                                nuevoLugar.fotoCache = fotoCache
                                
                                if nuevoLugar.row != nil {
                                    
                                    dispatch_async(dispatch_get_main_queue(), {
                                        
                                        if let cellVisible = nuevoLugar.tabla!.cellForRowAtIndexPath(NSIndexPath(forRow: nuevoLugar.row!, inSection: 0)) as? ModeloBusquedaResultadosCellTableViewCell {
                                            cellVisible.imagen.image = nuevoLugar.fotoCache
                                            cellVisible.imagen.frame.size.width = 100
                                            cellVisible.imagen.frame.size.height = 80
                                        }
                                    })
                                    
                                }
   
                            } else {
                                
                                nuevoLugar.foto = ""
                                
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
	
    class func datos(idSeccion: String, lugar: Lugar, view: UIView) {
        
        var campo1 = ""
        var campo2 = ""
        var campo3 = ""
        var campo4 = ""
        
        switch idSeccion {
            case "hotelesYAlojamiento":
                
                let nombre = lugar.nombre.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                let direccion = lugar.calleNombre + " " + lugar.calleAltura
                let categoriaNombre = lugar.subRubroNombre
                let distancia = lugar.distancia != nil ? "A \(Int(lugar.distancia! / 100)) cuadras" : ""

                campo1 = nombre
                campo2 = categoriaNombre
                campo3 = direccion
                campo4 = distancia
            
            case "inmobiliarias":

                let datosNombre = lugar.nombre.componentsSeparatedByString(" - ")
                
                var titular = datosNombre.last!
                var nombre = ""
                
                if datosNombre.count > 1 {
                    
                    for var x = 0; x < (datosNombre.count - 1); x++ {
                        
                        nombre += datosNombre[x]
                        if x < (datosNombre.count - 2) { nombre += " - " }
                        
                    }
                    
                } else {
                    
                    nombre = titular
                    titular = ""
                    
                }
                
                nombre = nombre.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                titular = titular.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                let direccion = lugar.calleNombre + " " + lugar.calleAltura
                let distancia = lugar.distancia != nil ? "A \(Int(lugar.distancia! / 100)) cuadras" : ""
                
                campo1 = nombre
                campo2 = titular
                campo3 = direccion
                campo4 = distancia

            case "gastronomia":
                
                let nombre = lugar.nombre.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                let telefono = lugar.telefono1 ?? lugar.telefono2 ?? lugar.telefono3 ?? ""
                let direccion = lugar.calleNombre + " " + lugar.calleAltura
                let distancia = lugar.distancia != nil ? "A \(Int(lugar.distancia! / 100)) cuadras" : ""
                
                campo1 = nombre
                campo2 = telefono.stringByReplacingOccurrencesOfString("/fax. ", withString: "", options: nil, range: nil)
                campo3 = direccion
                campo4 = distancia
                
            case "playas":

                let datosNombre = lugar.nombre.componentsSeparatedByString(" - ")
                var nombre = ""
                
                var nombrePlaya = datosNombre.last!
                
                if datosNombre.count > 1 {
                    
                    for var x = 0; x < (datosNombre.count - 1); x++ {
                        
                        nombre += datosNombre[x]
                        if x < (datosNombre.count - 2) { nombre += " - " }
                        
                    }
                    
                } else {
                    
                    nombre = nombrePlaya
                    nombrePlaya = ""
                    
                }
                
                nombre = nombre.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                nombrePlaya = nombrePlaya.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                let direccion = lugar.calleNombre + " " + lugar.calleAltura
                let distancia = lugar.distancia != nil ? "A \(Int(lugar.distancia! / 100)) cuadras" : ""
                
                campo1 = nombre
                campo2 = nombrePlaya
                campo3 = direccion
                campo4 = distancia
                
            case "recreacion":
                
                let nombre = lugar.nombre.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                let direccion = lugar.calleNombre + " " + lugar.calleAltura
                let telefono = lugar.telefono1 ?? lugar.telefono2 ?? lugar.telefono3 ?? ""
                let distancia = lugar.distancia != nil ? "A \(Int(lugar.distancia! / 100)) cuadras" : ""
                
                campo1 = nombre
                campo2 = telefono.stringByReplacingOccurrencesOfString("/fax. ", withString: "", options: nil, range: nil)
                campo3 = direccion
                campo4 = distancia
                
            case "museos":
                
                let nombre = lugar.nombre.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                let direccion = lugar.calleNombre + " " + lugar.calleAltura
                let categoriaNombre = lugar.subRubroNombre
                let distancia = lugar.distancia != nil ? "A \(Int(lugar.distancia! / 100)) cuadras" : ""
                
                campo1 = nombre
                campo2 = categoriaNombre
                campo3 = direccion
                campo4 = distancia
            
            default: break
        }
        
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
        
        let label3 = UILabel(frame: CGRect(x: 0, y: label2.frame.origin.y + label2.frame.size.height + (label.frame.size.height > 25 ? -6 : 9) + (campo4 == "" ? 14 : 0), width: view.frame.size.width, height: 20))
        label3.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
        label3.numberOfLines = 1
        label3.text = campo3
        label3.adjustsFontSizeToFitWidth = true
        label3.minimumScaleFactor = 0.5
        view.addSubview(label3)
        
        if campo4 != "" {
            
            let label4 = UILabel(frame: CGRect(x: 0, y: label3.frame.origin.y + label3.frame.size.height - 6, width: view.frame.size.width, height: 20))
            label4.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
            label4.numberOfLines = 1
            label4.text = campo4
            label4.adjustsFontSizeToFitWidth = true
            label4.minimumScaleFactor = 0.5
            view.addSubview(label4)
            
        }
        
    }

    class func datosDetalle(idSeccion: String, lugar: Lugar, view: UIView) {
        
        var arrayDatos: [[String: NSObject]] = []

        var nombre = lugar.nombre.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        let direccion = lugar.calleNombre + " " + lugar.calleAltura
        let distancia = lugar.distancia != nil ? "A \(Int(lugar.distancia! / 100)) cuadras" : ""
        let telefono = (lugar.telefono1 ?? lugar.telefono2 ?? lugar.telefono3 ?? "").stringByReplacingOccurrencesOfString("/fax. ", withString: "", options: nil, range: nil)
        let email = lugar.email
        let web = lugar.web

        switch idSeccion {
            case "hotelesYAlojamiento":
                
                let categoriaNombre = lugar.subRubroNombre
                
                arrayDatos = [
                                ["texto": nombre, "font": UIFont.boldSystemFontOfSize(18), "color": UIColor(red: 116/255, green: 154/255, blue: 201/255, alpha: 1), "lineas": 2, "paddingTop": 0, "boton": ""],
                                ["texto": categoriaNombre, "font": UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline), "color": UIColor.blackColor(), "lineas": 1, "paddingTop": 0, "boton": ""],
                                ["texto": direccion, "font": UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline), "color": UIColor.blackColor(), "lineas": 1, "paddingTop": 10, "boton": ""],
                                ["texto": distancia, "font": UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote), "color": UIColor.blackColor(), "lineas": 1, "paddingTop": 0, "boton": ""],
                                ["texto": telefono, "font": UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline), "color": UIColor.blackColor(), "lineas": 1, "paddingTop": 10, "boton": "botonTel:"],
                                ["texto": email, "font": UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline), "color": UIColor.blackColor(), "lineas": 1, "paddingTop": 0, "boton": "botonEmail:"],
                                ["texto": web, "font": UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline), "color": UIColor.blackColor(), "lineas": 1, "paddingTop": 0, "boton": "botonWeb:"]
                            ]
                
            case "inmobiliarias":
            
                let datosNombre = lugar.nombre.componentsSeparatedByString(" - ")
                nombre = ""
                
                var titular = datosNombre.last!
                
                if datosNombre.count > 1 {
                    
                    for var x = 0; x < (datosNombre.count - 1); x++ {
                        
                        nombre += datosNombre[x]
                        if x < (datosNombre.count - 2) { nombre += " - " }
                        
                    }
                    
                } else {
                    
                    nombre = titular
                    titular = ""
                    
                }
                
                nombre = nombre.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                titular = titular.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                
                arrayDatos = [
                                ["texto": nombre, "font": UIFont.boldSystemFontOfSize(18), "color": UIColor(red: 116/255, green: 154/255, blue: 201/255, alpha: 1), "lineas": 2, "paddingTop": 0, "boton": ""],
                                ["texto": titular, "font": UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline), "color": UIColor.blackColor(), "lineas": 1, "paddingTop": 0, "boton": ""],
                                ["texto": direccion, "font": UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline), "color": UIColor.blackColor(), "lineas": 1, "paddingTop": 10, "boton": ""],
                                ["texto": distancia, "font": UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote), "color": UIColor.blackColor(), "lineas": 1, "paddingTop": 0, "boton": ""],
                                ["texto": telefono, "font": UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline), "color": UIColor.blackColor(), "lineas": 1, "paddingTop": 10, "boton": "botonTel:"],
                                ["texto": email, "font": UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline), "color": UIColor.blackColor(), "lineas": 1, "paddingTop": 0, "boton": "botonEmail:"],
                                ["texto": web, "font": UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline), "color": UIColor.blackColor(), "lineas": 1, "paddingTop": 0, "boton": "botonWeb:"]
                            ]

            case "gastronomia":
            
                let categoriaNombre = lugar.subRubroNombre
                
                arrayDatos = [
                                ["texto": nombre, "font": UIFont.boldSystemFontOfSize(18), "color": UIColor(red: 116/255, green: 154/255, blue: 201/255, alpha: 1), "lineas": 2, "paddingTop": 0, "boton": ""],
                                ["texto": categoriaNombre, "font": UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline), "color": UIColor.blackColor(), "lineas": 1, "paddingTop": 0, "boton": ""],
                                ["texto": direccion, "font": UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline), "color": UIColor.blackColor(), "lineas": 1, "paddingTop": 10, "boton": ""],
                                ["texto": distancia, "font": UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote), "color": UIColor.blackColor(), "lineas": 1, "paddingTop": 0, "boton": ""],
                                ["texto": telefono, "font": UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline), "color": UIColor.blackColor(), "lineas": 1, "paddingTop": 10, "boton": "botonTel:"],
                                ["texto": email, "font": UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline), "color": UIColor.blackColor(), "lineas": 1, "paddingTop": 0, "boton": "botonEmail:"],
                                ["texto": web, "font": UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline), "color": UIColor.blackColor(), "lineas": 1, "paddingTop": 0, "boton": "botonWeb:"]
                            ]

            case "playas":
                
                let datosNombre = lugar.nombre.componentsSeparatedByString(" - ")
                nombre = ""
                
                var nombrePlaya = datosNombre.last!
                
                if datosNombre.count > 1 {
                    
                    for var x = 0; x < (datosNombre.count - 1); x++ {
                        
                        nombre += datosNombre[x]
                        if x < (datosNombre.count - 2) { nombre += " - " }
                        
                    }
                    
                } else {
                    
                    nombre = nombrePlaya
                    nombrePlaya = ""
                    
                }
                
                nombre = nombre.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                nombrePlaya = nombrePlaya.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                
                arrayDatos = [
                                ["texto": nombre, "font": UIFont.boldSystemFontOfSize(18), "color": UIColor(red: 116/255, green: 154/255, blue: 201/255, alpha: 1), "lineas": 2, "paddingTop": 0, "boton": ""],
                                ["texto": nombrePlaya, "font": UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline), "color": UIColor.blackColor(), "lineas": 1, "paddingTop": 0, "boton": ""],
                                ["texto": direccion, "font": UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline), "color": UIColor.blackColor(), "lineas": 1, "paddingTop": 10, "boton": ""],
                                ["texto": distancia, "font": UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote), "color": UIColor.blackColor(), "lineas": 1, "paddingTop": 0, "boton": ""],
                                ["texto": telefono, "font": UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline), "color": UIColor.blackColor(), "lineas": 1, "paddingTop": 10, "boton": "botonTel:"],
                                ["texto": email, "font": UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline), "color": UIColor.blackColor(), "lineas": 1, "paddingTop": 0, "boton": "botonEmail:"],
                                ["texto": web, "font": UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline), "color": UIColor.blackColor(), "lineas": 1, "paddingTop": 0, "boton": "botonWeb:"]
                            ]
            
            case "recreacion":
            
                let categoriaNombre = lugar.subRubroNombre
                
                arrayDatos = [
                                ["texto": nombre, "font": UIFont.boldSystemFontOfSize(18), "color": UIColor(red: 116/255, green: 154/255, blue: 201/255, alpha: 1), "lineas": 2, "paddingTop": 0, "boton": ""],
                                ["texto": categoriaNombre, "font": UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline), "color": UIColor.blackColor(), "lineas": 1, "paddingTop": 0, "boton": ""],
                                ["texto": direccion, "font": UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline), "color": UIColor.blackColor(), "lineas": 1, "paddingTop": 10, "boton": ""],
                                ["texto": distancia, "font": UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote), "color": UIColor.blackColor(), "lineas": 1, "paddingTop": 0, "boton": ""],
                                ["texto": telefono, "font": UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline), "color": UIColor.blackColor(), "lineas": 1, "paddingTop": 10, "boton": "botonTel:"],
                                ["texto": email, "font": UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline), "color": UIColor.blackColor(), "lineas": 1, "paddingTop": 0, "boton": "botonEmail:"],
                                ["texto": web, "font": UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline), "color": UIColor.blackColor(), "lineas": 1, "paddingTop": 0, "boton": "botonWeb:"]
                            ]

            case "museos":
                
                let categoriaNombre = lugar.subRubroNombre
                
                arrayDatos = [
                                ["texto": nombre, "font": UIFont.boldSystemFontOfSize(18), "color": UIColor(red: 116/255, green: 154/255, blue: 201/255, alpha: 1), "lineas": 2, "paddingTop": 0, "boton": ""],
                                ["texto": categoriaNombre, "font": UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline), "color": UIColor.blackColor(), "lineas": 1, "paddingTop": 0, "boton": ""],
                                ["texto": direccion, "font": UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline), "color": UIColor.blackColor(), "lineas": 1, "paddingTop": 10, "boton": ""],
                                ["texto": distancia, "font": UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote), "color": UIColor.blackColor(), "lineas": 1, "paddingTop": 0, "boton": ""],
                                ["texto": telefono, "font": UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline), "color": UIColor.blackColor(), "lineas": 1, "paddingTop": 10, "boton": "botonTel:"],
                                ["texto": email, "font": UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline), "color": UIColor.blackColor(), "lineas": 1, "paddingTop": 0, "boton": "botonEmail:"],
                                ["texto": web, "font": UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline), "color": UIColor.blackColor(), "lineas": 1, "paddingTop": 0, "boton": "botonWeb:"]
                            ]

            default: break
        }
        
        var yActual: CGFloat = 0
        
        for dato in arrayDatos {
            
            if dato["texto"]! != "" {
            
                if dato["boton"]! == "" {
                
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
                    
                } else {
                    
                    let boton = UIButton(frame: CGRect(x: 0, y: yActual + (dato["paddingTop"]! as! CGFloat), width: view.frame.size.width, height: 17))
                    boton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
                    boton.titleLabel!.font = dato["font"]! as! UIFont
                    boton.setTitleColor(UIColor(red: 15/255, green: 98/255, blue: 243/255, alpha: 1), forState: .Normal)
                    boton.setTitle(dato["texto"]! as? String, forState: .Normal)
                    boton.titleLabel!.adjustsFontSizeToFitWidth = true
                    boton.titleLabel!.minimumScaleFactor = 0.7
                    boton.addTarget(view.superview, action: Selector(dato["boton"]! as! String), forControlEvents: .TouchUpInside)
                    view.addSubview(boton)
                    
                    yActual += boton.frame.size.height + (dato["paddingTop"]! as! CGFloat)
                    
                }

            }
                
        }
        
        view.frame.size.height = yActual + 8

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
    
    class func buscar(idSeccion: String,opcionesItems: [String: [[String: String]]],opcionesValores: [String: NSObject], completionHandler: ([Lugar], String?) -> ()) {
        
        var resteaParametros: [String : NSObject] = ["Token":"01234567890123456789012345678901"]
        var resteaApi = ""
        var resteaServicio = ""
        var resteaNombreArrayResultados = ""
        var resteaErrorSinFiltros = ""
        var resteaErrorSinResultados = ""
        
        switch idSeccion {
            case "hotelesYAlojamiento":
                
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

                resteaParametros["IdCategoria"] = idCategoria
                resteaParametros["Nombre"] = filtroNombre
                resteaApi = "Hotel"
                resteaServicio = "Buscar"
                resteaNombreArrayResultados = "Hoteles"
                resteaErrorSinFiltros = "Es necesario elegir una categoría o filtrar por nombre."
                resteaErrorSinResultados = "No se encontraron hoteles para su búsqueda."
            case "inmobiliarias":
                
                var idZona = 0
                var filtroNombre = ""
                
                if let opcionesZona = opcionesItems["zona"] {
                    if let opcionesZonaValor = opcionesValores["zona"] as? Int {
                        if let opcionesZonaId = opcionesZona[opcionesZonaValor]["id"] {
                            idZona = opcionesZonaId.toInt()!
                        }
                    }
                }
                
                filtroNombre = opcionesValores["nombre"]! as! String
                
                resteaParametros["IdZona"] = idZona
                resteaParametros["Nombre"] = filtroNombre
                resteaParametros["SoloConAlquilerTuristico"] = "true"
                resteaApi = "Inmobiliaria"
                resteaServicio = "Buscar"
                resteaNombreArrayResultados = "Inmobiliarias"
                resteaErrorSinFiltros = "Es necesario elegir una zona o filtrar por nombre."
                resteaErrorSinResultados = "No se encontraron inmobiliarias para su búsqueda."
            case "gastronomia":
                
                var idTipoComercio = 0
                var filtroNombre = ""
                
                if let opcionesTipo = opcionesItems["tipo"] {
                    if let opcionesTipoValor = opcionesValores["tipo"] as? Int {
                        if let opcionesTipoId = opcionesTipo[opcionesTipoValor]["id"] {
                            idTipoComercio = opcionesTipoId.toInt()!
                        }
                    }
                }
                
                filtroNombre = opcionesValores["nombre"]! as! String
                
                resteaParametros["IdTipoComercio"] = idTipoComercio
                resteaParametros["Nombre"] = filtroNombre
                resteaApi = "Gastronomia"
                resteaServicio = "Buscar"
                resteaNombreArrayResultados = "Gastronomias"
                resteaErrorSinFiltros = "Es necesario elegir un tipo de comercio o filtrar por nombre."
                resteaErrorSinResultados = "No se encontraron comercios para su búsqueda."
            
            case "playas":
                
                var idZona = 0
                var filtroNombre = ""
                
                if let opcionesZona = opcionesItems["zona"] {
                    if let opcionesZonaValor = opcionesValores["zona"] as? Int {
                        if let opcionesZonaId = opcionesZona[opcionesZonaValor]["id"] {
                            idZona = opcionesZonaId.toInt()!
                        }
                    }
                }
                
                filtroNombre = opcionesValores["nombre"]! as! String
                
                resteaParametros["IdZona"] = idZona
                resteaParametros["Nombre"] = filtroNombre
                resteaApi = "Playa"
                resteaServicio = "Buscar"
                resteaNombreArrayResultados = "Playas"
                resteaErrorSinFiltros = "Es necesario elegir una zona o filtrar por nombre."
                resteaErrorSinResultados = "No se encontraron playas o balnearios para su búsqueda."
            case "recreacion":

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
                
                resteaParametros["IdCategoria"] = idCategoria
                resteaParametros["Nombre"] = filtroNombre
                resteaApi = "Recreacion"
                resteaServicio = "Buscar"
                resteaNombreArrayResultados = "Recreaciones"
                resteaErrorSinFiltros = "Es necesario elegir una categoría o filtrar por nombre."
                resteaErrorSinResultados = "No se encontraron lugares de recreación o excursiones para su búsqueda."
            case "museos":
                
                resteaApi = "Museo"
                resteaServicio = "Buscar"
                resteaNombreArrayResultados = "Museos"
                resteaErrorSinFiltros = "Ocurrió un error al leer los datos.\nPor favor intente nuevamente."
                resteaErrorSinResultados = "Ocurrió un error al leer los datos.\nPor favor intente nuevamente."
            default: break
        }

        restea(resteaApi,resteaServicio,resteaParametros) { (request, response, JSON, error) in
            
            var lugares: [Lugar] = []
            var mensajeError: String?
            
            if error == nil, let info = JSON as? NSDictionary where (info[resteaNombreArrayResultados] as! NSArray).count > 0 {
                
                lugares = Lugar.lugaresCargaDeJSON(info[resteaNombreArrayResultados] as! NSArray)
                
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
            
            completionHandler(lugares,mensajeError)
            
        }
        
    }
	
}