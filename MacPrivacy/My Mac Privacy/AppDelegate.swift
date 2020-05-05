//
//  AppDelegate.swift
//  My Mac Privacy
//
//  Created by StuFF mc on 20.07.18.
//  Copyright © 2018 Manuel @stuffmc Carrasco Molina. All rights reserved.
//

import Cocoa
import CoreSpotlight

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func application(_ application: NSApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([NSUserActivityRestoring]) -> Void) -> Bool {
        print(userActivity.activityType)
        if userActivity.activityType == CSSearchableItemActionType {
            print("CSSearchableItemActionType")
        }
        return true
    }

}

