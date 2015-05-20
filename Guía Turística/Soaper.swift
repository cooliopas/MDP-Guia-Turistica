//
//  Soaper.swift
//  GT1
//
//  Created by Pablo Pasqualino on 3/4/15.
//  Copyright (c) 2015 Pablo Pasqualino. All rights reserved.
//

import Foundation
import SWXMLHash
import Alamofire

func soapea(servicio: String, parametros: [[String: String]], completionHandler: ([[String: String]], NSError?) -> ()) {
	
	let soapRequest = soapGeneraRequest(servicio, parametros)
	let msgLength = String(count(soapRequest))

	let apiURL = "http://gisdesa.mardelplata.gob.ar/opendata/ws.php?wsdl"
	
	let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
	configuration.timeoutIntervalForRequest = 60
	
	let manager = Alamofire.Manager(configuration: configuration)
	
	manager.request(.POST, apiURL, parameters: [:], encoding: .Custom({
	
		(convertible, params) in

		let mutableRequest = convertible.URLRequest.copy() as! NSMutableURLRequest
		mutableRequest.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
		mutableRequest.addValue(msgLength, forHTTPHeaderField: "Content-Length")
		mutableRequest.HTTPMethod = "POST"
		mutableRequest.HTTPBody = soapRequest.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)

		return (mutableRequest, nil)
	
	})).response { (request, response, data, error) in

		var respuestaFinal = [[String: String]]()
		
		if error == nil {
		
			if let respuestaXML = NSString(data: data as! NSData, encoding: NSUTF8StringEncoding) as? String {
		
				let xml = SWXMLHash.parse(respuestaXML)
		
				let respuesta = xml["SOAP-ENV:Envelope"]["SOAP-ENV:Body"]["\(servicio)Response"]["return"]
		
				var respuestaItem = [String: String]()
			
				switch respuesta {
				case .Element(let elem):
			
					if respuesta.children.count > 0 {
			
						for child in respuesta.children {
			
							if child.element!.name=="item" {
			
								respuestaItem.removeAll(keepCapacity: false)
			
								for child2 in child.children {
			
									respuestaItem[child2.element!.name] = child2.element!.text ?? ""
			
								}
			
								respuestaFinal.append(respuestaItem)
			
							} else  {
			
								if respuestaFinal.isEmpty { respuestaFinal.append([String: String]()) }
			
								respuestaFinal[0][child.element!.name] = child.element!.text ?? ""
			
							}
			
						}
			
					} else {
			
						respuestaFinal.append([String: String]())
			
						respuestaFinal[0][respuesta.element!.name] = respuesta.element!.text ?? ""
						
					}
				default: break
				}
				
			}
		
		}
		
		completionHandler(respuestaFinal,error)
		
	}
	
}

func soapGeneraRequest(servicio: String,parametros: [[String: String]]) -> String {
	
	// generamos el XML para el Soap Request
	// parametros es un Array de Dictionary, para asegurarnos que los elementos se mantengan en el orden que corresponde
	
	var parametrosRequest = ""
	var valor = ""
	var nombre = ""
	let token = "wwfe345gQ3ed5T67g4Dase45F6fer"
	
	for (parametro) in parametros {
		
		valor = Array(parametro.values)[0]
		nombre = Array(parametro.keys)[0]
		
		parametrosRequest += "<\(nombre) xsi:type=\"xsd:string\">\(valor)</\(nombre)>\n"
	}
	
	var soapRequest = ""
	
	soapRequest += "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
	soapRequest += "<SOAP-ENV:Envelope xmlns:SOAP-ENV=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:ns1=\"\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:SOAP-ENC=\"http://schemas.xmlsoap.org/soap/encoding/\" SOAP-ENV:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">\n"
	soapRequest += "<SOAP-ENV:Body>\n"
	soapRequest += "<ns1:\(servicio)>\n"
	soapRequest += parametrosRequest
	soapRequest += "<token xsi:type=\"xsd:string\">\(token)</token>\n"
	soapRequest += "</ns1:\(servicio)>\n"
	soapRequest += "</SOAP-ENV:Body>\n"
	soapRequest += "</SOAP-ENV:Envelope>"
	
	return soapRequest
	
}

func restea(api: String, servicio: String, parametros: [String:AnyObject], completionHandler: (NSURLRequest, NSHTTPURLResponse?, AnyObject?, NSError?) -> ()) {
	
	var apiURL: URLStringConvertible?
	
	switch api {
		case "ArriboOmnibus":
			apiURL = "http://appsb.mardelplata.gob.ar/Consultas/wsArriboOmnibus/RESTServiceArriboOmnibus.svc/arriboOmnibus/\(servicio)"
		case "Hotel","Inmobiliaria","Evento","Recreacion","Playa","Museo","Gastronomia":
			apiURL = "http://turismomardelplata.gov.ar/WS/TurismoWS.svc/\(api)/\(servicio)"
		default: break
	}
	
	if apiURL != nil {
	
		let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
		configuration.timeoutIntervalForRequest = 60
		let manager = Alamofire.Manager(configuration: configuration)

		manager.request(.POST, apiURL!, parameters: parametros, encoding: .JSON).responseJSON { (request, response, JSON, error) in

			completionHandler(request, response, JSON, error)

		}

	}
		
}