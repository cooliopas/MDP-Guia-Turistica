//
//  MuseosViewController.swift
//  GT1
//
//  Created by Pablo Pasqualino on 3/18/15.
//  Copyright (c) 2015 Pablo Pasqualino. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation

class MuseosViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SWRevealViewControllerDelegate {

	@IBOutlet weak var tablaResultados: UITableView!
	@IBOutlet weak var labelSinResultados: UILabel!
	@IBOutlet weak var botonReintentar: UIButton!

	var cellBusqueda: MuseosCellFiltroTableViewCell?
	
	var museos = [Lugar]()

	let locationManager = LocationManager.sharedInstance
	var ubicacionActual: CLLocationCoordinate2D?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		println("load")
	}

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		println("appear")
		buscar()
		
		armaNavegacion()
		self.revealViewController().delegate = self
		
		locationManager.autoUpdate = true
		locationManager.startUpdatingLocationWithCompletionHandler { [weak self] (latitude, longitude, status, verboseMessage, error) -> () in
			
			if self != nil {
				
				self!.ubicacionActual = CLLocationCoordinate2DMake(latitude, longitude)
				self!.locationManager.stopUpdatingLocation()
				
			}
			
		}
		
	}
	
	override func viewDidLayoutSubviews() {
		if tablaResultados.respondsToSelector(Selector("layoutMargins")) {
			tablaResultados.layoutMargins = UIEdgeInsetsZero;
		}
	}
	
	@IBAction func buscar() {
		
		UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseOut, animations: {
			
			self.tablaResultados.alpha = 1
//			self.labelSinResultados.alpha = 0
//			self.botonReintentar.alpha = 0
			
			}, completion: { finished in
		
//				self.tablaResultados.scrollRectToVisible(CGRectMake(0, 0, 1, 1), animated: false)
		
		})
		
//		IJProgressView.shared.showProgressView(self.view, padding: true)
//		
//		restea("Museo","Buscar",["Token":"01234567890123456789012345678901"]) { (request, response, JSON, error) in
//
//			IJProgressView.shared.hideProgressView()
//			
//			if error == nil, let info = JSON as? NSDictionary where (info["Museos"] as! NSArray).count > 0 {
//
//				self.museos = Lugar.lugaresCargaDeJSON(info["Museos"] as! NSArray)
//
//				if self.ubicacionActual != nil {
//					
//					for museo in self.museos {
//						
//						if museo.latitud != 0 {
//
//							museo.distancia = directMetersFromCoordinate(self.ubicacionActual!, CLLocationCoordinate2DMake(museo.latitud, museo.longitud))
//							
//						}
//						
//					}
//					
//					self.museos.sort(self.sorterForDistancia)
//					
//				}
//				
//				self.tablaResultados.reloadData()
//				
//				UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseOut, animations: {
//					
//					self.tablaResultados.alpha = 1
//					
//					}, completion: nil)
//
//			} else {
//				
//				self.labelSinResultados.text = "Ocurrió un error al leer los datos.\nPor favor intente nuevamente."
//				
//				UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseOut, animations: {
//					
//					self.labelSinResultados.alpha = 1
//					self.botonReintentar.alpha = 1
//					
//					}, completion: nil)
//				
//			}
//			
//		}
		
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
		
		let museosMuseoVC = appDelegate.traeVC("museosMuseo") as! MuseosMuseoViewController
		
		museosMuseoVC.museo = museos[indexPath.row]
		
		self.revealViewController().setFrontViewController(museosMuseoVC, animated: true)
		
		tableView.deselectRowAtIndexPath(indexPath, animated: true)

	}
	
	//MARK: UITableViewDataSource
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		return museos.count
		
	}
	
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		
		var cellHeight: CGFloat = 30
		
		if tableView == tablaResultados {
			
			cellHeight = 80
			
		}
		
		return cellHeight
		
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

		let museo = museos[indexPath.row] as Lugar
		
		let cell = tableView.dequeueReusableCellWithIdentifier("museo", forIndexPath: indexPath) as! MuseosResultadosMuseoCellTableViewCell

		cell.nombre.text = museo.nombre.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
		cell.direccion.text = museo.calleNombre + " " + museo.calleAltura
		cell.categoriaNombre.text = museo.subRubroNombre

		if museo.fotoCache != nil {
		
			cell.imagen.image = museo.fotoCache!

		} else {
			
			cell.imagen.image = UIImage(named: "dummy-hotel")

		}

		museo.row = indexPath.row
		museo.tabla = tableView
		
		if museo.distancia != nil {
		
			let distancia = Int(museo.distancia! / 100)
			
			cell.distancia.text = "A \(distancia) cuadras"

		} else {

			cell.distancia.text = ""
			
		}
		
		if (cell.respondsToSelector(Selector("layoutMargins"))) {
			cell.layoutMargins = UIEdgeInsetsZero
		}
		
		cell.separatorInset = UIEdgeInsetsZero

		let backgroundView = UIView(frame: cell.frame)
		backgroundView.backgroundColor = UIColor(red: 168/255, green: 198/255, blue: 231/255, alpha: 1)
		
		cell.selectedBackgroundView = backgroundView
		
		return cell

	}
	
	override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
		if cellBusqueda != nil {
			cellBusqueda!.filtroNombreTextField.endEditing(true)
		}
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
