//
//  Created by Manuel @StuFFmc Carrasco Molina on 25.05.18.
//  Copyright © 2018 Pomcast.biz. All rights reserved.
//
import CoreSpotlight
import MobileCoreServices

class SiriVC: PrivacyContainerVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeImage as String)
        attributeSet.title = "Sunset with Privacy"
        attributeSet.contentDescription = "August, 1999 Vimoutiers, France"
        let item = CSSearchableItem(uniqueIdentifier: "1", domainIdentifier: "album-1", attributeSet: attributeSet)
        CSSearchableIndex.default().indexSearchableItems([item]) { error in
            self.privacyVC.updateUserInterfaceAfterPermissionRequest(status: 3, authorizedMessage: error != nil ? error!.localizedDescription : "Item index")
        }
    }
        
}
