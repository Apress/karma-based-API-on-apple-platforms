//  Created by Manuel @stuffmc Carrasco Molina on 2018-05-18
import UIKit
import CoreLocation
import MapKit

class LocationVC: PrivacyContainerVC, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        checkStatus()
        privacyVC.label.text = "IP Tables revelead the country I am already"
        privacyVC.mapView.isHidden = false
        locationManager.delegate = self
        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: OperationQueue.main) { (_) in
            self.checkStatus()
        }
//        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main) { (_) in
////            DispatchQueue.main.as
////            perform(#selector(requestLocation), with: self, afterDelay: 5, inModes: [.default])
//            self.locationManager.startUpdatingLocation()
//            print("BG")
//        }
    }
    
    @objc func requestLocation() {
        locationManager.requestLocation()
    }
    
    // MARK:-
    func checkStatus() {
        let status = CLLocationManager.authorizationStatus()
        print(status.rawValue)
        
        if status != .restricted {
            privacyVC.button.isHidden = false
        }
        
        if status == .denied {
            // I need to "redo" this because of the following `else` that might have removed the original action.
            privacyVC.buttonSwap(title: "Give Permission", target: privacyVC, action: #selector(privacyVC.givePermission))
        } else {
            // The following is a also an example of "re-routing"
            privacyVC.buttonSwap(title: "Show me where I precisely am", target: self, action: #selector(centerToUserLocation))
        }
    }

    @objc func centerToUserLocation() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            locationManager.requestAlwaysAuthorization()
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
//        centerToUserLocationIfAuthorized()
    }
    
    func centerToUserLocationIfAuthorized() {
        if [.authorizedWhenInUse, .authorizedAlways].contains(CLLocationManager.authorizationStatus()) {
            privacyVC.mapView.showsUserLocation = true
            let userLocation = privacyVC.mapView.userLocation
            print(userLocation.coordinate)
            privacyVC.mapView.setCenter(userLocation.coordinate, animated: true)
            privacyVC.buttonSwap(title: "Now print geocode and reverse it", target: self, action: #selector(geocode))
        }
    }
    
    @objc func geocode() {
        self.locationManager.startUpdatingLocation()
        let coder = CLGeocoder()
        let location = CLLocation(latitude: 43.819825, longitude: 7.774883)
        coder.reverseGeocodeLocation(location) { (placemarks, error) in
            print(error ?? "no error")
            guard let placemark = placemarks?.first else {
                print("no placemarks")
                return
            }
            print(placemark)
            guard let postalAddress = placemark.postalAddress else {
                print("This placemark has no postalAddress")
                return
            }
            coder.geocodePostalAddress(postalAddress, completionHandler: { (placemarks, error) in
                print(error ?? "no error")
                print(placemarks ?? "no placemarks")
            })
        }
    }
    
    // MARK:- MKMapViewDelegate
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
//        _ = userLocation.location?.horizontalAccuracy == kCLLocationAccuracyBest
        centerToUserLocationIfAuthorized()
    }
    
    // MARK:- CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("didUpdateLocations: \(locations)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("status: \(status.rawValue)")
        centerToUserLocationIfAuthorized()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }

}
