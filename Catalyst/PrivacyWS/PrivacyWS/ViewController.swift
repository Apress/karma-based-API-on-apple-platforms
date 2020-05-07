//
//  ViewController.swift
//  PrivacyWS
//
//  Created by StuFF mc on 06.05.20.
//  Copyright © 2020 Manuel @StuFFmc Carrasco Molina. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class Annotation: NSObject, MKAnnotation {
	var coordinate = CLLocationCoordinate2D(latitude: 50.79, longitude: 6.48)
	var image: UIImage?
}

//class SegmentedController: UISegmentedControlde

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var segmentedControl: UISegmentedControl!
	var annotations = [Annotation()]
	let locationManager = CLLocationManager()
	let selectionChange = SelectionChange()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		mapView.delegate = self
		print(mapView.userLocation.coordinate)
		#if targetEnvironment(macCatalyst)
		segmentedControl.isHidden = true
		#else
		segmentedControl.removeAllSegments()
		Chapters.allCases.reversed().forEach {
			segmentedControl.insertSegment(withTitle: $0.rawValue, at: 0, animated: false)
		}
		segmentedControl.selectedSegmentIndex = 0
		#endif
	}

	@IBAction func didUpdateSegmentedControl() {
		selectionChange.selectionChanged(in: self, to: segmentedControl.selectedSegmentIndex)
	}
	
	func location() {
//		mapView.addAnnotation(annotations.first!)
		// Exercise #1: Show the user's current location
		locationManager.delegate = self
		locationManager.requestAlwaysAuthorization()
	}
	
	func contacts() {
		// Exercise #2: Show the location of the contacts
		// Exercise #3: When tapping on the face, display the card
	}
	
	func photos() {
		// Exercice #4: Display photos located on a map
	}
	
	// MARK: MapViewDelegate
	func mapView(_ mapView: MKMapView,
				 viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		if annotation is MKUserLocation {
			return nil
		}
		let annotationView = MKPinAnnotationView(annotation: annotation,
												 reuseIdentifier: "\(annotation.coordinate.latitude), \(annotation.coordinate.longitude)")
		return annotationView
	}
	
	// MARK: LocationManagerDelegate
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print(error)
	}
	
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		if status == .authorizedAlways { // We should treat the other cases!
			locationManager.requestLocation()
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		
	}
}
