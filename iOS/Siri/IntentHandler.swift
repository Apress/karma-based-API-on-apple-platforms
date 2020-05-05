//
//  Created by Manuel @StuFFmc Carrasco Molina on 18.08.18.
//  Copyright © 2018 Pomcast.biz. All rights reserved.
//

import Intents
import Contacts

// As an example, this class is set up to handle Message intents.
// You will want to replace this or add other intents as appropriate.
// The intents you wish to handle must be declared in the extension's Info.plist.

// You can test your example integration by saying things to Siri like:
// "Send a message using <myApp>"
// "<myApp> John saying hello"
// "Search for messages in <myApp>"

//extension INPerson {
//    convenience init(personHandle: INPersonHandle, displayName: String, contactIdentifier: String) {
//        self.init(personHandle: personHandle, nameComponents: nil, displayName: displayName, image: nil, contactIdentifier: contactIdentifier, customIdentifier: nil)
//    }
//}

extension Array where Element == INPerson {
    mutating func appendPerson(handleValue: String, displayName: String, contactIdentifier: String) {
        let pH = INPersonHandle(value: handleValue, type: .unknown)
        let person = INPerson(personHandle: pH, nameComponents: nil, displayName: displayName,
                              image: nil, contactIdentifier: contactIdentifier, customIdentifier: nil)
        self.append(person)
    }
}

class IntentHandler: INExtension, INSendMessageIntentHandling, INSearchForMessagesIntentHandling, INSetMessageAttributeIntentHandling, MyPrivacyIntentHandling {
    
    let descriptors = [CNContactNamePrefixKey, CNContactGivenNameKey, CNContactMiddleNameKey, CNContactFamilyNameKey, CNContactPreviousFamilyNameKey, CNContactNameSuffixKey, CNContactNicknameKey, CNContactOrganizationNameKey, CNContactDepartmentNameKey, CNContactJobTitleKey, CNContactPhoneticGivenNameKey, CNContactPhoneticMiddleNameKey, CNContactPhoneticFamilyNameKey, CNContactPhoneticOrganizationNameKey, CNContactBirthdayKey, CNContactNonGregorianBirthdayKey, CNContactNoteKey, CNContactImageDataKey, CNContactThumbnailImageDataKey, CNContactImageDataAvailableKey, CNContactTypeKey, CNContactPhoneNumbersKey, CNContactEmailAddressesKey, CNContactPostalAddressesKey, CNContactDatesKey, CNContactUrlAddressesKey, CNContactRelationsKey, CNContactSocialProfilesKey, CNContactInstantMessageAddressesKey] as [CNKeyDescriptor]
    
    var authorized: Bool {
        return CNContactStore.authorizationStatus(for: .contacts) == .authorized
    }

    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        
        return self
    }
    
    // MARK: - MyPrivacyIntentHandling
    func handle(intent: MyPrivacyIntent, completion: @escaping (MyPrivacyIntentResponse) -> Void) {
        let response = MyPrivacyIntentResponse(code: .success, userActivity: nil) //uA)
        print(intent)
        completion(response)
    }
    
    // MARK: - INSendMessageIntentHandling
    
    // Implement resolution methods to provide additional information about your intent (optional).
    func resolveRecipients(for intent: INSendMessageIntent, with completion: @escaping ([INPersonResolutionResult]) -> Void) {        
        var results = [INPersonResolutionResult]()
        if let recipients = intent.recipients {

            // If no recipients were provided we'll need to prompt for a value.
            if recipients.count == 0 {
                completion([INPersonResolutionResult.needsValue()])
                return
            }
            
            let coder = JSONDecoder()
            guard let url = Contact.url else {
                return
            }
            var contacts = [Contact]()
            do {
                let data = try Data(contentsOf: url)
                contacts = try coder.decode(Array.self, from: data)
            } catch {
                print(error)
            }
                
            for recipient in recipients {
                var matchingContacts = [INPerson]()
                if let contact = contacts.filter({
                    print($0.name)
                    return $0.name.contains(recipient.spokenPhrase)
                }).first {
                    do {
                        let name = contact.name
                        let id = contact.identifier
                        if authorized {
                            let uC = try CNContactStore().unifiedContact(withIdentifier: id, keysToFetch: descriptors)
                            matchingContacts.appendPerson(handleValue: name, displayName: uC.familyName, contactIdentifier: id)
                        } else {
                            matchingContacts.appendPerson(handleValue: name, displayName: name, contactIdentifier: id)
                        }
                    } catch {
                        print(error)
                    }
                } else {
                    if let person = person(with: CNContact.predicateForContacts(matchingName: recipient.spokenPhrase),
                                            for: descriptors), authorized {
                        matchingContacts.append(person)
                    }
                }
                switch matchingContacts.count {
                case 2  ... Int.max:
                    // We need Siri's help to ask user to pick one from the matches.
                    results += [.disambiguation(with: matchingContacts)]

                case 1:
                    // We have exactly one matching contact
                    results += [.success(with: matchingContacts.first!)]

                case 0:
                    // We have no contacts matching the description provided
                    results += [.unsupported()]

                default:
                    break
                }
            }
        }
        completion(results)
    }
    
    func person(with predicate: NSPredicate, for descriptors: [CNKeyDescriptor]) -> INPerson? {
        do {
            if let contact = try CNContactStore().unifiedContacts(matching: predicate,
                                                                  keysToFetch: descriptors).first,
                let email = contact.emailAddresses.first {
                
                let handle = INPersonHandle(value: email.value as String,
                                            type: .emailAddress)
                let image = contact.imageData == nil ? nil :
                    INImage(imageData: contact.imageData!)
                return INPerson(personHandle: handle,
                                nameComponents: nil,
                                displayName: contact.familyName,
                                image: image,
                                contactIdentifier: contact.identifier
                    , customIdentifier: nil)
            }
        } catch {
            print(error)
        }
        return nil
    }
    
    func resolveContent(for intent: INSendMessageIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
        if let text = intent.content, !text.isEmpty {
            completion(.success(with: text))
        } else {
            completion(.needsValue())
        }
    }
    
    // Once resolution is completed, perform validation on the intent and provide confirmation (optional).
    
    func confirm(intent: INSendMessageIntent, completion: @escaping (INSendMessageIntentResponse) -> Void) {
        // Verify user is authenticated and your app is ready to send a message.
        
        let userActivity = NSUserActivity(activityType: NSStringFromClass(INSendMessageIntent.self))
        let response = INSendMessageIntentResponse(code: .ready, userActivity: userActivity)
        completion(response)
    }
    
    // Handle the completed intent (required).
    
    func handle(intent: INSendMessageIntent, completion: @escaping (INSendMessageIntentResponse) -> Void) {
        // Implement your application logic to send a message here.
        
        let userActivity = NSUserActivity(activityType: NSStringFromClass(INSendMessageIntent.self))
        let response = INSendMessageIntentResponse(code: .success, userActivity: userActivity)
        completion(response)
    }
    
    // Implement handlers for each intent you wish to handle.  As an example for messages, you may wish to also handle searchForMessages and setMessageAttributes.
    
    // MARK: - INSearchForMessagesIntentHandling
    
    func handle(intent: INSearchForMessagesIntent, completion: @escaping (INSearchForMessagesIntentResponse) -> Void) {
        let userActivity = NSUserActivity(activityType: NSStringFromClass(INSearchForMessagesIntent.self))
        let response = INSearchForMessagesIntentResponse(code: .success, userActivity: userActivity)
        // Initialize with found message's attributes
        response.messages = [INMessage(
            identifier: "identifier",
            content: "I am so excited about SiriKit!",
            dateSent: Date(),
            sender: INPerson(personHandle: INPersonHandle(value: "sarah@example.com", type: .emailAddress), nameComponents: nil, displayName: "Sarah", image: nil,  contactIdentifier: nil, customIdentifier: nil),
            recipients: [INPerson(personHandle: INPersonHandle(value: "+1-415-555-5555", type: .phoneNumber), nameComponents: nil, displayName: "John", image: nil,  contactIdentifier: nil, customIdentifier: nil)]
            )]
        completion(response)
    }
    
    // MARK: - INSetMessageAttributeIntentHandling
    
    func handle(intent: INSetMessageAttributeIntent, completion: @escaping (INSetMessageAttributeIntentResponse) -> Void) {
        // Implement your application logic to set the message attribute here.
        
        let userActivity = NSUserActivity(activityType: NSStringFromClass(INSetMessageAttributeIntent.self))
        let response = INSetMessageAttributeIntentResponse(code: .success, userActivity: userActivity)
        completion(response)
    }
}
