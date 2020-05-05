//  Created by Manuel @stuffmc Carrasco Molina on 2018-05-12

import UIKit
import Photos
import MapKit
import Intents
import Contacts
import ContactsUI
import CoreSpotlight
import MobileCoreServices

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

class ContactsVC: PrivacyContainerVC, CNContactPickerDelegate {
    var contacts: [CNContact]? {
        didSet {
            addAnnotation(for: contacts!)
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            var convertedContacts = [Contact]()
            contacts?.forEach {
                convertedContacts.append(Contact(with: $0))
            }
            guard let url = Contact.url else { return }
            do {
                let data = try encoder.encode(convertedContacts)
                try data.write(to: url, options: .atomicWrite)
            } catch { print(error) }
        }
    }
    
    let contactVC = ContactVC()
    let store = CNContactStore()
    let descriptors = [CNContactNamePrefixKey, CNContactGivenNameKey, CNContactMiddleNameKey, CNContactFamilyNameKey, CNContactPreviousFamilyNameKey, CNContactNameSuffixKey, CNContactNicknameKey, CNContactOrganizationNameKey, CNContactDepartmentNameKey, CNContactJobTitleKey, CNContactPhoneticGivenNameKey, CNContactPhoneticMiddleNameKey, CNContactPhoneticFamilyNameKey, CNContactPhoneticOrganizationNameKey, CNContactBirthdayKey, CNContactNonGregorianBirthdayKey, CNContactNoteKey, CNContactImageDataKey, CNContactThumbnailImageDataKey, CNContactImageDataAvailableKey, CNContactTypeKey, CNContactPhoneNumbersKey, CNContactEmailAddressesKey, CNContactPostalAddressesKey, CNContactDatesKey, CNContactUrlAddressesKey, CNContactRelationsKey, CNContactSocialProfilesKey, CNContactInstantMessageAddressesKey] as [CNKeyDescriptor]

    override func viewDidLoad() {
        super.viewDidLoad()
        contactVC.contactsVC = self
        privacyVC.mapView.isHidden = false
        privacyVC.mapView.delegate = self
        
        let activity = NSUserActivity(activityType: "com.carrascomolina.privacy.contacts")
        activity.title = "Privacy with my Contacts"
        activity.isEligibleForSearch = true
        if #available(iOS 12.0, *) {
            activity.isEligibleForPrediction = true
            activity.suggestedInvocationPhrase = "Privacontact!"
        }
        userActivity = activity
        activity.becomeCurrent()
    }
    
    // MARK:-
    @IBAction func pick(_ sender: UIButton) {
        let picker = CNContactPickerViewController()
        picker.delegate = sender.tag == 1 ? contactVC : self
        present(picker, animated: true) { }
    }
    
    func predicate(with descriptors: [CNKeyDescriptor]) {
        let alert = UIAlertController(title: "Name Pattern?", message: nil, preferredStyle: .alert)
        alert.addTextField { $0.text = "Bell" }
        alert.addAction(UIAlertAction(title: "Search", style: .default, handler: { (_) in
            self.allow(with: CNContact.predicateForContacts(matchingName: alert.textFields?.first?.text ?? ""), for: descriptors)
        }))
        present(alert, animated: true)
    }
    
    @IBAction func good(_ sender: Any) {
        let descriptors = [CNContactGivenNameKey, CNContactFamilyNameKey] as [CNKeyDescriptor]
        predicate(with: descriptors)
    }
    
    @IBAction func bad(_ sender: Any) {
        predicate(with: descriptors)
    }
    
    @IBAction func ugly(_ sender: Any) {
        let predicate = CNContact.predicateForContactsInContainer(withIdentifier: store.defaultContainerIdentifier())
        allow(with: predicate, for: descriptors)
    }
    
    fileprivate func addAnnotation(for contacts: [CNContact]) {
        contacts.forEach { contact in
            if contact.isKeyAvailable(CNContactPostalAddressesKey) {
                if let address = contact.postalAddresses.first?.value {
                    CLGeocoder().geocodePostalAddress(address) { (placemarks, error) in
                        placemarks?.forEach { $0.add(to: self.privacyVC.mapView) }
                    }
                }
            } else {
                print("The good developer won't show you any address")
                print(contacts.first?.familyName ?? "no name")
            }
        }
    }
    
    func allow(with predicate: NSPredicate, for descriptors: [CNKeyDescriptor]) {
        privacyVC.mapView.isHidden = true
        store.requestAccess(for: .contacts) { (success, error) in
            let status = CNContactStore.authorizationStatus(for: .contacts)
            if success {
                do {
                    let fetchRequest = CNContactFetchRequest(keysToFetch: descriptors)
                    fetchRequest.predicate = predicate
                    self.contacts = try self.store.unifiedContacts(matching: predicate, keysToFetch: descriptors)
                    self.showContacts(for: status)
                } catch {
                    print(error)
                }
            } else {
                self.privacyVC.updateUserInterfaceAfterPermissionRequest(status: status.rawValue)
            }
        }
    }
    
    func showContacts(for status: CNAuthorizationStatus) {
        guard let contacts = self.contacts else {
            print("should crash here")
            return
        }
        self.privacyVC.updateUserInterfaceAfterPermissionRequest(status: status.rawValue, authorizedMessage: "You have \(contacts.count) contacts")
        self.contacts = contacts
    }

    // MARK:- CNContactPickerDelegate
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contacts: [CNContact]) {
        self.contacts = contacts
        print(contacts)
    }
    
    // MARK:- MKMapViewDelegate
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // Not very good but does it for the job
        print(contacts?.first?.familyName ?? "no name")
    }
    
}

// This seems to be my only option if I want to support single and multiple selection in a single ViewController
class ContactVC: NSObject, CNContactPickerDelegate {
    var contactsVC: ContactsVC?
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        contactsVC?.contacts = [contact]
        print(contact)
        if #available(iOS 12.0, *) {
            let intent = MyPrivacyIntent()
            guard let email = contact.emailAddresses.first?.value else {
                return
            }
            let pH = INPersonHandle(value: email as String, type: .emailAddress)
            intent.person = INPerson(personHandle: pH,
                                     nameComponents: nil,
                                     displayName: contact.familyName,
                                     image: nil,
                                     contactIdentifier: contact.identifier,
                                     customIdentifier: nil)
            INInteraction(intent: intent, response: nil).donate(completion: nil)
            
            let messageIntent = INSendMessageIntent(recipients: [intent.person!], content: nil, speakableGroupName: nil, conversationIdentifier: nil, serviceName: "PrivzApp", sender: intent.person)
            let response = INIntentResponse()
            let interaction = INInteraction(intent: messageIntent, response: response)
            interaction.direction = .outgoing
            //interaction.intentHandlingStatus = .success
            interaction.donate { (error) in
                print(error ?? "no error")
            }
            
            let uA = NSUserActivity(activityType: "com.carrascomolina.privacy.watch.relevantshortcut")
            uA.isEligibleForSearch = true
            uA.isEligibleForPrediction = true
            uA.title = "Watch my Privacy!"
            let attr = CSSearchableItemAttributeSet(itemContentType: kUTTypeItem as String)
            attr.contentDescription = "This is my subtitle..."
            let image = UIImage(named: "icon-siri")
            attr.thumbnailData = image?.pngData()
            uA.contentAttributeSet = attr
            let relShc = INRelevantShortcut(shortcut: INShortcut(userActivity: uA))
            let rP = INDateRelevanceProvider(start: Date(timeIntervalSinceNow: 30),
                                             end: Date(timeIntervalSinceNow: 60))
            // or INLocationRelevanceProvider
            relShc.relevanceProviders = [rP]
            INRelevantShortcutStore.default.setRelevantShortcuts([relShc]) { (error) in
                print(error ?? "no error")
            }
        }
    }
}
