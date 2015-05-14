//
//  TransporteEstacionarInfoViewController.swift
//  GT1
//
//  Created by Pablo Pasqualino on 3/18/15.
//  Copyright (c) 2015 Pablo Pasqualino. All rights reserved.
//

import UIKit

class TransporteEstacionarInfoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SWRevealViewControllerDelegate {
	
	let transporteSecciones = [
		[
			"nombre":"Puntos de venta",
			"sub":"",
			"contenido":"<strong>Puntos de venta</strong><br /><br /><ol><li>Estacioná tu vehículo.</li><li>Buscá el kiosco o punto de venta más cercano.</li><li>Pasá la tarjeta prepaga (banda magnética) por el posnet.&nbsp;</li><li>Seleccioná del menú la opción: “Estacionar”</li><li>Ingresá el número de patente</li><li>Ingresá el tiempo, en horas, que vas a estacionar.</li><li>Se imprimirá un ticket con los siguientes datos: patente, tiempo de estacionamiento adquirido, y el saldo de la tarjeta</li></ol><br /><strong>Notas:</strong><br /><br />El tiempo de estacionamiento adquirido es fijo.<br />No es necesario dejar el ticket en el vehículo, ya que los inspectores controlan por sistema."
		],
		[
			"nombre":"Por SMS",
			"sub":"",
			"contenido":"<strong>Estacionamiento por SMS</strong><br /><br /><ol><li>Registrate en el sistema. Enviá por única vez &nbsp;un SMS con la letra R al 54223. Recibirás un mensaje con un link donde encontrarás el detalle de las condiciones.</li><li>Cargá la tarjeta en tu celular, enviando un SMS al 54223 con la letra T, espacio, N° de PIN.&nbsp;(Raspadita Tarjeta)</li><li>Para estacionar: enviá un SMS al 54223 con el mensaje E, espacio y tu patente (ej: E AAA111)</li><li>Para finalizar: enviá un SMS al 54223 con el mensaje F, espacio y tu patente (ej: F AAA111). Recibirás un SMS confirmando la finalización con el nuevo saldo.</li></ol><br /><strong>Notas:</strong><br /><br />A partir de la segunda hora de estacionamiento, el tiempo fraccionará cada 15 minutos.<br /><br />El precio de cada SMS enviado al 54223 y/o la llamada realizada al 432-3000, será a cargo del usuario con el costo que cada empresa determine según el plan adquirido.<br /><br />Cinco minutos antes de finalizar la primera hora de estacionamiento, el sistema enviará automáticamente un SMS informando la situación y te indicará que comenzará la renovación automática.<br /><br />Luego de 4 horas de estacionamiento medido, el sistema te informará automáticamente a través de un SMS que aún está activo el servicio y que si deseás cancelarlo deberás enviar un SMS con el mensaje F, espacio y tu patente (ej: F AAA111).<br /><br />Para CONSULTAR EL SALDO enviá un SMS con la letra S al 54223<br /><br />Para RECUPERAR LA CONTRASEÑA enviá un SMS con la letra C al 54223. Te devolverá en un mensaje de texto la nueva contraseña."
		],
		[
			"nombre":"Por teléfono",
			"sub":"",
			"contenido":"<strong>Por teléfono</strong><br /><br /><ol><li>Registrate en el sistema. Enviá por única vez &nbsp;un SMS con la letra R al 54223. Recibirás un mensaje con un link donde encontrarás el detalle de las condiciones.</li><li>Al estacionar, llamá al 223 432 3000 y seguí las instrucciones.</li><li>Para finalizar, volvé a llamar al 223 432 3000 y seguí las instrucciones.</li></ol>"
		],
		[
			"nombre":"Pago anticipado",
			"sub":"",
			"contenido":"<strong>Pago anticipado</strong><br /><br />Cada noche podés anticipar el inicio de tu estacionamiento para el día siguiente. Para eso sólo tenés que enviar tu mensaje de texto, o hacer tu llamada, o indicarlo vía internet, una vez terminado el horario de estacionamiento medido.<br /><br />Así se activará tu crédito para el otro día a partir de las 8 hs."
		],
		[
			"nombre":"Horarios",
			"sub":"",
			"contenido":"<strong>Horarios</strong><br /><br /><strong>Temporada estival:</strong><br />Desde el 16 de diciembre al 15 de marzo.<br />Lunes a sábados de 8:00 a 23:00<br /><br /><strong>Temporada invernal:</strong><br />Desde el 16 de marzo al 15 de diciembre.<br />Lunes a sábados de 8:00 a 20:00<br /><br /><strong>Domingos, feriados y asueto</strong><br />Libre estacionamiento"
		],
		[
			"nombre":"Preguntas frecuentes",
			"sub":"",
			"contenido":"<strong>Preguntas frecuentes</strong><br /><br /><ol><li><strong>P - ¿Quién paga el costo del mensaje?</strong><br />R - El Precio de cada Mensaje de texto enviado al número 54223 será a cargo del consumidor.</p></li><li><strong>P- ¿Cuánto cuesta el envío del mensaje?</strong><br />R- El Precio de cada Mensaje de texto enviado al número 54223 será a cargo del consumidor con el costo que cada empresa determine.</p></li><li><strong>P - ¿Quién paga la respuesta del mensaje?</strong><br />R- La respuesta la paga el municipio</p></li><li><strong>P - ¿Qué pasa si envié el mensaje para el estacionamiento e igualmente me labran un acta de infracción?</strong><br />R - Para el caso de que el conductor reciba un acta de infracción habiendo iniciado el estacionamiento, es importante que conserve su registro de envío de SMS para realizar eventuales reclamos. Para ello debe configurar su celular para guardar el historial de envío.</p></li><li><strong>P - ¿Cómo efectuar un reclamo?</strong><br />R- Todo reclamo debe ser dirigido a la MGP a través del 432-3000, <a href=\"mailto:estacionamientomedido@mardelplata.gov.ar\">estacionamientomedido@mardelplata.gov.ar</a> o por nota a la Dirección de Transporte y Tránsito. Es importante que conserve su registro de envío de SMS. Para ello debe configurar su celular para guardar el historial de envió.</p></li><li><strong>P -  ¿Qué pasa si olvido mandar el mensaje de fin de estacionamiento?</strong><br />R - Cada cuatro horas se le manda un mensaje recordatorio indicando que está activado el estacionamiento medido.</p></li><li><strong>P -  ¿A qué hora finaliza el estacionamiento medido?</strong><br />R – A las 20:00 en temporada invernal y a las 23:00 en temporada estival.</p></li><li><strong>P -  ¿Qué pasa si inicié el estacionamiento y me dan las 20 o 23 horas según temporada y no mande el fin de estacionamiento?</strong><br />R – A las 20:00 o 23:000 (según temporada) cuando concluye el estacionamiento medido el sistema corta automáticamente y después de ese horario no hace falta enviar el SMS con la letra F, espacio, Patente</p></li><li><strong>P -  ¿Qué pasa si me quedo sin crédito?</strong><br />R – El monto mínimo para iniciar el estacionamiento es de $4 (1 hora). Tiene que recargar u optar por la Compra Puntual.</p></li><li><strong>P -  Qué pasa si tengo poca batería en el celular?</strong><br />R – Puede optar por la compra puntal sin celular</p></li><li><strong>P -  ¿Cuál es la zona de estacionamiento medido?</strong><br />R – La zona de estacionamiento medido comprende el espacio de estacionamiento que se sitúa en el micro y macro centro delimitado por las calles Buenos Aires,  España, 25 de Mayo y Avenida Colón, inclusive.</p></li><li><strong>P -  ¿Deben pagar estacionamiento los vecinos que vivan o trabajen en la zona de Estacionamiento Medido?</strong><br />R – Si, como históricamente se hace, ya que es espacio público.</p></li><li><strong>P -  ¿Qué hace el que no tiene celular.</strong><br />R – En ese caso opte por compra sin celular en los comercios adheridos.</p></li><li><strong>P -  ¿Qué pasa si alguien falsea la información de FIN?</strong><br />R – Es imposible falsear la información, los inspectores verifican por el sistema informático por cuánto tiempo se compró el espacio. Y si corresponde se labrará la infracción.</p></li><li><strong>P -  ¿Los sábados rige el estacionamiento medido?</strong><br />R – Si, el día sábado rige.</p></li><li><strong>P - No anda la página Web! No puedo estacionar por Web!</strong><br />R: Primero debe solicitar clave, enviando R por única vez vía SMS al 54223. Luego accede a la página Web: <a href=\"http://www.mardelplata.gob.ar/estacionar\">http://www.mardelplata.gob.ar/estacionar</a>.  Si no puede acceder a esa página, no anda su navegador a Internet, consulte con su empresa de celular y opte por estacionamiento Puntual en los puntos de venta habilitados.</p></li><li><strong>P -  ¿En Web que pongo? ¿Qué hago? ¿Como estaciono?</strong><br />R: Primero, pone usuario y contraseña, y presiona INGRESAR. Luego vera su saldo y estará disponible la opción de ESTACIONAR. Deberá ingresar la PATENTE y presionar “Estacionar”, y vera la patente estacionada que inicio en la sección Estacionamientos Activos. Para finalizar presione “Terminar” en la sección Estacionamiento Activos.</p></li><li><strong>P -  ¿Como se si estacioné bien? ¿Y si corte bien?</strong><br />R: Cuando presiona ESTACIONAR, en unos segundos vera a la derecha de la pantalla en Estacionamientos Activos la patente que ingresó para estacionar. Cuando presiona TERMINAR, la patente se borrará una vez que alcance el horario especificado. </p></li></ol>"
		],
		[
			"nombre":"Instructivos en video",
			"sub":"",
			"contenido":"<style>*{font-family: 'HelveticaNeue'; font-size: 14px; margin: 8px 0 8px 0; }strong{padding-left: 8px; font-weight: bold}</style><strong>Instructivos en video</strong><br /><iframe src=\"http://www.youtube.com/embed/4L19LdG0SW0\" width=\"320\" height=\"200\" frameborder=\"0\" allowfullscreen></iframe><Br /><iframe src=\"http://www.youtube.com/embed/Oam-WkIp7wE\" width=\"320\" height=\"200\" frameborder=\"0\" allowfullscreen></iframe><Br /><iframe src=\"http://www.youtube.com/embed/A-L89Ity7MA\" width=\"320\" height=\"200\" frameborder=\"0\" allowfullscreen></iframe><Br /><iframe src=\"http://www.youtube.com/embed/Bo2U-y2QvlY\" width=\"320\" height=\"200\" frameborder=\"0\" allowfullscreen></iframe><Br /><iframe src=\"http://www.youtube.com/embed/https://youtu.be/b3n1ESaIFpI\" width=\"320\" height=\"200\" frameborder=\"0\" allowfullscreen></iframe>"
		]
	]

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		armaNavegacion()
		self.revealViewController().delegate = self
		
	}

	//MARK: UITableViewDataSource
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return transporteSecciones.count
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		if let sub = transporteSecciones[indexPath.row]["sub"] {
		
			let cell = tableView.dequeueReusableCellWithIdentifier("transporteSubtitle", forIndexPath: indexPath) as! UITableViewCell
			
			cell.textLabel?.text = transporteSecciones[indexPath.row]["nombre"]!
			cell.detailTextLabel?.text = sub
			
			return cell
			
		} else {
			
			let cell = tableView.dequeueReusableCellWithIdentifier("transporteBasic", forIndexPath: indexPath) as! UITableViewCell
			
			cell.textLabel?.text = transporteSecciones[indexPath.row]["nombre"]!
			
			return cell
			
		}
		
	}
	
	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return "Estacionamiento Medido"
	}
	
	//MARK: UITableViewDelegate
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
	
		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		
		if transporteSecciones[indexPath.row]["nombre"]! == "Instructivos en video" {
		
			let transporteEstacionarInfoWebVC = appDelegate.traeVC("transporteEstacionarInfoWeb") as! TransporteEstacionarInfoWebViewController
			transporteEstacionarInfoWebVC.contenido = transporteSecciones[indexPath.row]["contenido"]!
			
			self.revealViewController().setFrontViewController(transporteEstacionarInfoWebVC, animated: true)

		} else {

			let transporteEstacionarInfoContenidoVC = appDelegate.traeVC("transporteEstacionarInfoContenido") as! TransporteEstacionarInfoContenidoViewController
			transporteEstacionarInfoContenidoVC.contenido = transporteSecciones[indexPath.row]["contenido"]!
			
			self.revealViewController().setFrontViewController(transporteEstacionarInfoContenidoVC, animated: true)
			
		}
		
		tableView.deselectRowAtIndexPath(indexPath, animated: true)

	}

	deinit {
		println("deinit")
	}

	override func viewDidDisappear(animated: Bool) {
		
//		println("disapear")
		
		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		appDelegate.arrayVC.removeValueForKey("transporteEstacionarInfo")
		
		self.removeFromParentViewController()
		
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
}
