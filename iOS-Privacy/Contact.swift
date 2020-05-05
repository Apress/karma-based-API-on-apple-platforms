//
//  Created by Manuel @StuFFmc Carrasco Molina on 20.11.18.
//  Copyright © 2018 Pomcast.biz. All rights reserved.
//

import Foundation
import Contacts

struct Contact : Codable {
    var name: String
    var identifier: String
    
    static var url: URL? {
        guard let documents = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.certgate.mc.privacy") else {
            return nil
        }
        print(documents)
        return documents.appendingPathComponent("contacts.json")
    }
    
    init(with contact: CNContact) {
        name = contact.givenName
        identifier = contact.identifier
    }
}
