//
//  ViewController.swift
//  PrivacyWS
//
//  Created by StuFF mc on 06.05.20.
//  Copyright © 2020 Manuel @StuFFmc Carrasco Molina. All rights reserved.
//

import UIKit
import MapKit

class Annotation: NSObject, MKAnnotation {
	var coordinate = CLLocationCoordinate2D(latitude: 50.79, longitude: 6.48)
	var image: UIImage?
}

class ViewController: UIViewController, MKMapViewDelegate {
	@IBOutlet weak var mapView: MKMapView!
	var annotations = [Annotation()]
	
	override func viewDidLoad() {
		super.viewDidLoad()
		mapView.delegate = self
	}

	func location() {
		mapView.addAnnotation(annotations.first!)
	}
	
	func contacts() {
	}
	
	func photos() {
	}
	
	// MARK: MapViewDelegate
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		let annotationView = MKPinAnnotationView(annotation: annotation,
												 reuseIdentifier: "\(annotation.coordinate.latitude), \(annotation.coordinate.longitude)")
		return annotationView
	}
}
