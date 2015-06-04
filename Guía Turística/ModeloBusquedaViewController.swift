
//
//  ModeloBusquedaViewController.swift
//  GT1
//
//  Created by Pablo Pasqualino on 3/18/15.
//  Copyright (c) 2015 Pablo Pasqualino. All rights reserved.
//

import UIKit
import CoreLocation

class ModeloBusquedaViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, SWRevealViewControllerDelegate {

	@IBOutlet weak var tablaOpciones: UITableView!
	@IBOutlet weak var tablaResultados: UITableView!
	@IBOutlet weak var labelStatus: UILabel!
    @IBOutlet weak var botonBuscar: UIButton!
    @IBOutlet weak var tablaOpcionesHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tablaResultadosTopConstraint: NSLayoutConstraint!

    var idSeccion = ""
    var titulo = ""
    var api = ""
    var statusInicial = ""
    
	var cellBusqueda: ModeloBusquedaCellFiltroTableViewCell?
	
    var opciones: [String] = []
	
    var opcionesTitulos: [String: String] = [:]
	
    var opcionesValores: [String: NSObject] = [:]

	var opcionesItems: [String: [[String: String]]] = [:]
	
    var lugares: [Lugar] = []

	let locationManager = CLLocationManager()
	var ubicacionActual: CLLocation?
	
	override func viewDidLoad() {
		super.viewDidLoad()

        navBar?.topItem?.title = titulo
        
        if statusInicial != "" {
            
            labelStatus.alpha = 1
            labelStatus.text = statusInicial
            
        }
        
		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if appDelegate.opcionesItems[idSeccion] != nil {
            opcionesItems = appDelegate.opcionesItems[idSeccion]!
        } else {
            tablaOpciones.hidden = true
            botonBuscar.hidden = true
            tablaResultadosTopConstraint.constant -= (botonBuscar.frame.size.height + 10)
        }
		
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyBest
		
        locationManager.startUpdatingLocation()
        
        if opciones.count == 0 {
            
            buscar()
            
        }
        
	}

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        armaNavegacion()
        self.revealViewController().delegate = self
        
    }
    
	func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
		
		if status == CLAuthorizationStatus.AuthorizedWhenInUse {
			locationManager.startUpdatingLocation()
		} else {
			locationManager.requestWhenInUseAuthorization()
		}
		
	}
	
	func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
		
		locationManager.stopUpdatingLocation()

		ubicacionActual = locations.last as? CLLocation
		
	}
	
	override func viewDidLayoutSubviews() {
		if tablaResultados.respondsToSelector(Selector("layoutMargins")) {
			tablaResultados.layoutMargins = UIEdgeInsetsZero;
		}
		if tablaOpciones.respondsToSelector(Selector("layoutMargins")) {
			tablaOpciones.layoutMargins = UIEdgeInsetsZero;
		}
	}
	
	@IBAction func buscar() {
		
		if !hayRed() {
			
			muestraError("No se detecta conección a Internet.\nNo es posible continuar.", volver: 0)
			
		} else {
		
            if opcionesValores["nombre"] != nil {
                
                opcionesValores["nombre"] = cellBusqueda!.filtroNombreTextField.text
                
            }

            cellBusqueda?.filtroNombreTextField.endEditing(true)
			
			UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseOut, animations: {
				
				self.tablaResultados.alpha = 0
				self.labelStatus.alpha = 0
				
				}, completion: { finished in
			
					self.tablaResultados.scrollRectToVisible(CGRectMake(0, 0, 1, 1), animated: false)
			
			})
			
			IJProgressView.shared.showProgressView(self.view, padding: true, texto: "Por favor espere...\nLa búsqueda puede demorar aproximadamente 1 minuto.")
			
            Lugar.buscar(idSeccion,opcionesItems: opcionesItems,opcionesValores: opcionesValores) { (lugares, error) in
             
                if self.revealViewController() != nil { IJProgressView.shared.hideProgressView() }
                
                if error == nil && lugares.count > 0 {
                    
                    self.lugares = lugares
                    
                    if self.ubicacionActual != nil {
                        
                        for lugar in self.lugares {
                            
                            if lugar.latitud != 0 {
                                
                                lugar.distancia = self.ubicacionActual!.distanceFromLocation(CLLocation(latitude: lugar.latitud, longitude: lugar.longitud))
                                
                            }
                            
                        }
                        
                        self.lugares.sort(self.sorterForDistancia)
                        
                    }
                    
                    self.tablaResultados.reloadData()
                    
                    UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseOut, animations: {
                        
                        self.tablaResultados.alpha = 1
                        
                        }, completion: nil)
                    
                } else {
                    
                    self.labelStatus.text = error
                    
                    UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseOut, animations: {
                        
                        self.labelStatus.alpha = 1
                        
                        }, completion: nil)
                    
                }
                
            }
            
		}
	}
	
	func sorterForDistancia(this:Lugar, that:Lugar) -> Bool {
		if this.distancia == nil {
			return false
		} else if that.distancia == nil {
			return true
		} else {
			return this.distancia! < that.distancia!
		}
	}
	
	//MARK: UITableViewDelegate
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		
		if tableView == tablaOpciones {
			
			if opciones[indexPath.row] != "nombre" {
		
				let modeloBusquedaOpcionesVC = appDelegate.traeVC("modeloBusquedaOpciones") as! ModeloBusquedaOpcionesViewController
				
				modeloBusquedaOpcionesVC.opcion = opciones[indexPath.row]
                modeloBusquedaOpcionesVC.modeloBusquedaVC = self
                modeloBusquedaOpcionesVC.idSeccion = idSeccion
                modeloBusquedaOpcionesVC.titulo = navBar?.topItem?.title ?? "Opciones"
				
				self.revealViewController().setFrontViewController(modeloBusquedaOpcionesVC, animated: true)

			}
			
		} else if tableView == tablaResultados {
		
			let modeloBusquedaLugarVC = appDelegate.traeVC("modeloBusquedaLugar") as! ModeloBusquedaLugarViewController
			
			modeloBusquedaLugarVC.lugar = lugares[indexPath.row]
            modeloBusquedaLugarVC.titulo = navBar?.topItem?.title ?? ""
            modeloBusquedaLugarVC.idSeccion = idSeccion
            modeloBusquedaLugarVC.api = api
            
			self.revealViewController().setFrontViewController(modeloBusquedaLugarVC, animated: true)
			
		}
		
		tableView.deselectRowAtIndexPath(indexPath, animated: true)

	}
	
	//MARK: UITableViewDataSource
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		if tableView == tablaOpciones {
		
            tablaOpcionesHeightConstraint.constant = CGFloat(opciones.count * 44 + (opciones.count > 0 ? 30 : 0))
			return opciones.count
			
		} else if tableView == tablaResultados {

			return lugares.count
			
		}
	
		return 0
		
	}
	
	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		
		if tableView == tablaOpciones {
		
			return "Opciones de búsqueda"
			
		}
		
		return ""
		
	}
	
	func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		
		if tableView == tablaOpciones {
		
			return 30
			
		}
		
		return 0
		
	}
	
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		
		var cellHeight: CGFloat = 44
		
		if tableView == tablaResultados {
			
			cellHeight = 80
			
		}
		
		return cellHeight
		
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

		if tableView == tablaOpciones {

			let opcion = opciones[indexPath.row] as String

			if opcion != "nombre" {
				
				let cell = tableView.dequeueReusableCellWithIdentifier("opciones", forIndexPath: indexPath) as! UITableViewCell
				
				cell.textLabel?.text = opcionesTitulos[opcion]!
				
				if let items = opcionesItems[opcion],
					let valor = opcionesValores[opcion] as? Int,
					let texto = items[valor]["texto"] {
					
					cell.detailTextLabel?.text = texto
					
				} else {
					
					cell.detailTextLabel?.text = "Cargando ..."
					
				}
			
				if (cell.respondsToSelector(Selector("layoutMargins"))) {
					cell.layoutMargins = UIEdgeInsetsZero
				}
				
				cell.separatorInset = UIEdgeInsetsZero

				return cell
				
			} else {

				let cell = tableView.dequeueReusableCellWithIdentifier("filtro", forIndexPath: indexPath) as! ModeloBusquedaCellFiltroTableViewCell
				cellBusqueda = cell
				
				if (cell.respondsToSelector(Selector("layoutMargins"))) {
					cell.layoutMargins = UIEdgeInsetsZero
				}
				
				cell.separatorInset = UIEdgeInsetsZero

                cell.viewPrincial = self
                
				return cell
				
			}
			
		} else if tableView == tablaResultados {
	
			let lugar = lugares[indexPath.row] as Lugar
			
			let cell = tableView.dequeueReusableCellWithIdentifier("lugar", forIndexPath: indexPath) as! ModeloBusquedaResultadosCellTableViewCell

            for view in cell.datos.subviews {
                view.removeFromSuperview()
            }
            
            Lugar.datos(idSeccion, lugar: lugar, view: cell.datos)
            
			if lugar.fotoCache != nil {
			
				cell.imagen.image = lugar.fotoCache!

			} else {
				
				cell.imagen.image = UIImage(named: "dummy-hotel")

			}

			lugar.row = indexPath.row
			lugar.tabla = tableView
			
			if (cell.respondsToSelector(Selector("layoutMargins"))) {
				cell.layoutMargins = UIEdgeInsetsZero
			}
			
			cell.separatorInset = UIEdgeInsetsZero

			let backgroundView = UIView(frame: cell.frame)
			backgroundView.backgroundColor = UIColor(red: 168/255, green: 198/255, blue: 231/255, alpha: 1)
			
			cell.selectedBackgroundView = backgroundView
			
			return cell
			
		}
		
		return UITableViewCell()

	}
	
	func nombreCategoria(categoriasId: Int) -> String {
		
		if let categorias = opcionesItems["categoria"] {

			for categoria in categorias {
				
				if (categoria["id"]! as String).toInt()! == categoriasId {

					return categoria["texto"]!
					
				}
				
			}
			
		}
		
		return ""
		
	}
	
	override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
		if cellBusqueda != nil {
			cellBusqueda!.filtroNombreTextField.endEditing(true)
		}
	}
	
	override func viewDidDisappear(animated: Bool) {

		super.viewDidDisappear(animated)
		
		IJProgressView.shared.hideProgressView()
		
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
