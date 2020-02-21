//
//  Created by Manuel @StuFFmc Carrasco Molina on 28.09.17.
//

import UIKit
import CoreSpotlight

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?
    var nc: UINavigationController?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        guard let splitViewController = window?.rootViewController as? UISplitViewController else {
            return false
        }
        splitViewController.preferredDisplayMode = .allVisible
        nc = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as? UINavigationController
        nc?.topViewController?.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
        splitViewController.delegate = self
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        switch userActivity.activityType {
        case "com.carrascomolina.privacy.contacts":
            if let nc = nc, let tvc = nc.topViewController, let vc = nc.storyboard?.instantiateViewController(withIdentifier: "ContactsVC") {
                nc.viewControllers = [tvc, vc]
            }
        case CSSearchableItemActionType:
            print("userActivity.activityType == CSSearchableItemActionType")
        default:
            print(userActivity.activityType)
            if #available(iOS 12.0, *) {
                if let intent = userActivity.interaction?.intent as? MyPrivacyIntent {
                    print(intent.person ?? "none")
                }
            }
        }
        return true
    }
    
    func applicationShouldRequestHealthAuthorization(_ application: UIApplication) {
        //alert("applicationShouldRequestHealthAuthorization")
        HealthManager.shared.store.handleAuthorizationForExtension { (success, error) in
            print(success)
            print(error ?? "no error")
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // MARK: - Split view

    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
            return true }
//        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
//        guard let topAsDetailController = secondaryAsNavController.topViewController as? PhotosVC else { return false }
//        if topAsDetailController.detailItem == nil {
//            // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
//            return true
//        }
//        return false
//    }

}

