//  Created by Manuel @stuffmc Carrasco Molina on 2018-05-26
import UIKit
import MapKit
import EventKit
import EventKitUI

class StructuredEvent: NSObject, MKAnnotation {
    var event: EKEvent
    
    init(event: EKEvent) {
        self.event = event
    }

    public var title: String? {
        return event.title
    }

    public var subtitle: String? {
        return event.structuredLocation?.title
    }
    
    public var coordinate: CLLocationCoordinate2D {
        get { return event.structuredLocation!.geoLocation!.coordinate }
    }
}

// I used this in a previous version
class AnnotatedEvent: NSObject, MKAnnotation {
    var location: CLLocation
    
    init(location: CLLocation) {
        self.location = location
    }
    
    public var coordinate: CLLocationCoordinate2D {
        get { return location.coordinate }
    }
}

class CalendarVC: PrivacyContainerVC, EKCalendarChooserDelegate {
    let store = EKEventStore()
    var events: [EKEvent]?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        store.requestAccess(to: .event) { (success, error) in
            if success {
                self.privacyVC.mapView.isHidden = false
                self.eventsMatchingPredicate()
            }
        }
    }
    
    @IBAction func listCalendars(_ sender: Any) {
        store.requestAccess(to: .event) { (success, error) in
            if success {
                DispatchQueue.main.async {
                    let chooser = EKCalendarChooser(selectionStyle: .single, displayStyle: .allCalendars, entityType: .event, eventStore: self.store)
                    chooser.delegate = self
                    self.navigationController?.pushViewController(chooser, animated: true)
//                    self.present(UINavigationController(rootViewController: chooser), animated: true) { }
                }
            }
        }
    }
    
    func calendarChooserSelectionDidChange(_ calendarChooser: EKCalendarChooser) {
        print(calendarChooser.selectedCalendars)
    }
    
    private func eventsMatchingPredicate() {
        let status = EKEventStore.authorizationStatus(for: .event).rawValue
        self.privacyVC.updateUserInterfaceAfterPermissionRequest(status: status, authorizedMessage: "Searching your calendar... Hold on...")
        
        // We're only really interested (in our case) in the Local Calendar
        let local = store.calendars(for: .event).filter { $0.type == .local }
        
        // Note you can't do this (get all the events ever in the past and the future) because "within a four year time span"
        // https://developer.apple.com/documentation/eventkit/ekeventstore/1507479-predicateforevents
//        let predicate = store.predicateForEvents(withStart: Date.distantPast, end: Date.distantFuture, calendars: cals) // Not compatible with the API.
        
        var years = DateComponents()
        years.year = -4
        if let start = NSCalendar.current.date(byAdding: years, to: Date()) {
            let predicate = store.predicateForEvents(withStart: start, end: Date(), calendars: local)
            events = store.events(matching: predicate)
            guard let events = events else {
                print("no events found")
                return
            }
            self.privacyVC.updateUserInterfaceAfterPermissionRequest(status: status, authorizedMessage: "Found \(events.count) events...")
            events.forEach {
                print($0)
                // You don't even need to do this
                // retrieveLocation(event: event)
                if $0.structuredLocation?.geoLocation != nil {
                    annotateWithEvent(event: $0)
                }
            }
        }
    }
    
    private func retrieveLocation(event: EKEvent) {
        if let location = event.location {
            CLGeocoder().geocodeAddressString(location) { (placemarks, error) in
            if let location = placemarks?.first?.location {
                self.annotate(location: location)
        } } }
    }
    
    private func annotate(location: CLLocation) {
        privacyVC.mapView.addAnnotation(AnnotatedEvent(location: location))
        privacyVC.mapView.setCenter(location.coordinate, animated: true)
    }

    private func annotateWithEvent(event: EKEvent) {
        let eventLocation = StructuredEvent(event: event)
        privacyVC.mapView.addAnnotation(eventLocation)
        privacyVC.mapView.setCenter(eventLocation.coordinate, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
		views.first?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
//        openURL(for: view)
        let eventVC = EKEventViewController()
        eventVC.event = events?.first
        eventVC.allowsEditing = true
        navigationController?.pushViewController(eventVC, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // You could also simply do that
//        openURL(for: view)
    }
    
    private func openURL(for view: MKAnnotationView) {
        if let event = view.annotation as? StructuredEvent, let url = event.event.url {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

}
