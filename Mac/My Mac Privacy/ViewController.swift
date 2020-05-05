//
//  ViewController.swift
//  My Mac Privacy
//
//  Created by StuFF mc on 20.07.18.
//  Copyright © 2018 Manuel @stuffmc Carrasco Molina. All rights reserved.
//

import Cocoa
import CoreLocation
import Photos
import Contacts
import ContactsUI
import EventKit
import MapKit
import CoreSpotlight

extension CLPlacemark: MKAnnotation {
    public var coordinate: CLLocationCoordinate2D {
        get { return location!.coordinate }
    }
    
    func add(to mapView: MKMapView) {
        if let location = self.location {
            mapView.addAnnotation(self)
            if mapView.isHidden {
                mapView.isHidden = false
            }
            mapView.setCenter(location.coordinate, animated: true)
        }
    }
}

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

class ViewController: NSViewController, CNContactPickerDelegate {
    let picker = CNContactPicker()
    let locationManager = LocationManager()
    let store = CNContactStore()
    let calStore = EKEventStore()
    var events: [EKEvent]?
    
    let descriptors = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPostalAddressesKey] as [CNKeyDescriptor]
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeImage as String)
        attributeSet.title = "Sunset with Privacy"
        attributeSet.contentDescription = "August, 1999 Vimoutiers, France"
        attributeSet.relatedUniqueIdentifier = "Privacy101"
        let item = CSSearchableItem(uniqueIdentifier: "1", domainIdentifier: "album-1", attributeSet: attributeSet)
        CSSearchableIndex.default().indexSearchableItems([item]) { error in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                print("Item indexed!")
            }
        }
        
        let activity = NSUserActivity(activityType: "com.carrascomolina.privacy.contacts")
        activity.title = "Privacy with my Contacts"
        activity.contentAttributeSet = attributeSet
        activity.isEligibleForSearch = true
        self.userActivity = activity
        activity.becomeCurrent()
    }
    
    @IBAction func seekEvents(_ sender: Any) {
        // We're only really interested (in our case) in the Local Calendar
        let local = calStore.calendars(for: .event).filter { $0.type == .local }
        
        EKEventStore().requestAccess(to: .event) { (success, error) in
            print(success)
            print(error ?? "no error")
            
            var years = DateComponents()
            years.year = -4
            if let start = NSCalendar.current.date(byAdding: years, to: Date()) {
                let predicate = self.calStore.predicateForEvents(withStart: start, end: Date(), calendars: local)
                self.events = self.calStore.events(matching: predicate)
                guard let events = self.events else {
                    print("no events found")
                    return
                }
                print("events count: \(events.count)")
                if let last = events.last {
                    print("last event: \(last)")
                }
                if let event = events.last, event.structuredLocation?.geoLocation != nil {
                    let eventLocation = StructuredEvent(event: event)
                    self.mapView.addAnnotation(eventLocation)
                    self.mapView.setCenter(eventLocation.coordinate, animated: true)
                }
            }
        }
    }
    
    @IBAction func pickContacts(_ sender: NSButton) {
        picker.delegate = self
//        picker.displayedKeys = [CNContactNamePrefixKey, CNContactGivenNameKey, CNContactMiddleNameKey, CNContactFamilyNameKey, CNContactPreviousFamilyNameKey, CNContactNameSuffixKey, CNContactNicknameKey, CNContactOrganizationNameKey, CNContactDepartmentNameKey, CNContactJobTitleKey, CNContactPhoneticGivenNameKey, CNContactPhoneticMiddleNameKey, CNContactPhoneticFamilyNameKey, CNContactPhoneticOrganizationNameKey, CNContactBirthdayKey, CNContactNonGregorianBirthdayKey, CNContactNoteKey, CNContactImageDataKey, CNContactThumbnailImageDataKey, CNContactImageDataAvailableKey, CNContactTypeKey, CNContactPhoneNumbersKey, CNContactEmailAddressesKey, CNContactPostalAddressesKey, CNContactDatesKey, CNContactUrlAddressesKey, CNContactRelationsKey, CNContactSocialProfilesKey, CNContactInstantMessageAddressesKey]
        picker.showRelative(to: NSZeroRect, of: view, preferredEdge: .maxX)
    }
    
    @IBAction func contactsCount(_ sender: Any) {
        let predicate = CNContact.predicateForContactsInContainer(withIdentifier: store.defaultContainerIdentifier())
        contacts(with: predicate)
    }
    
    func contacts(with predicate: NSPredicate) {
        store.requestAccess(for: .contacts) { (success, error) in
            let status = CNContactStore.authorizationStatus(for: .contacts).rawValue
            print("contact auth: \(status), success: \(success)")
            if success {
                do {
                    let contacts = try self.store.unifiedContacts(matching: predicate, keysToFetch: self.descriptors)
                    print(contacts.count)
                    if contacts.count < 20 {
                        contacts.forEach {
                            if let address = $0.postalAddresses.first?.value {
                                CLGeocoder().geocodePostalAddress(address) { (placemarks, error) in
                                    placemarks?.forEach { $0.add(to: self.mapView) }
                                }
                            }
                        }
                    }
                } catch {
                    print(error)
                }
            }
        }
    }
    
    @IBAction func oneContact(_ sender: Any) {
        let predicate = CNContact.predicateForContacts(matchingName: "Carrasco")
        contacts(with: predicate)
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        print(PHPhotoLibrary.authorizationStatus().rawValue)
        PHPhotoLibrary.requestAuthorization { (status) in
            print(status.rawValue)
        }
    }
    
    
    // MARK:-
    func contactPicker(_ picker: CNContactPicker, didSelect contact: CNContact) {
        print(contact)
        if let address = contact.postalAddresses.first?.value {
            CLGeocoder().geocodePostalAddress(address) { (placemarks, error) in
                placemarks?.forEach { $0.add(to: self.mapView) }
            }
        }
    }
    

}

class LocationManager: NSObject, CLLocationManagerDelegate {
    // TODO: Move this to a global iOS & macOS Class (used by both)
    let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
        // TODO: Try this on 10.14
        // locationManager.requestLocation()
        locationManager.startUpdatingLocation()
    }
    
    // MARK:- CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateTo newLocation: CLLocation, from oldLocation: CLLocation) {
        print(newLocation)
    }

}
