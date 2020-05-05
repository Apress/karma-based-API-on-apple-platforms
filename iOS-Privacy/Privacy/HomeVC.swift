//
//  Created by StuFF mc on 2019-01-11.
//  Copyright © 2019 Pomcast.biz. All rights reserved.
//
import HomeKit

class HomeVC: PrivacyContainerVC, HMHomeManagerDelegate, HMAccessoryBrowserDelegate {
    let manager = HMHomeManager()
    let browser = HMAccessoryBrowser()
    var accessory: HMAccessory?
    var home: HMHome?
    var alert: UIAlertController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if manager.homes.isEmpty {
            addHome()
        }
        privacyVC.mapView.removeFromSuperview()
        print(manager.homes)
        manager.delegate = self
        if let first = manager.homes.first, first.isPrimary {
            whatsInTheRoom(first)
        }
        browser.delegate = self
    }
    
    fileprivate func present(_ alert: UIAlertController) {
        self.alert = alert
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func addHome() {
        present(UIAlertController(title: "Name your Home", message: "I suggest `Home`, but feel free to put another name", text: "Home", action: "OK") {
            self.manager.addHome(withName: self.alert?.textFields?.first?.text ?? "<unknown home>") { (home, error) in
                print(error ?? "no errors")
                if let home = home {
                    self.whatsInTheRoom(home)
                }
            }
        })
    }
    
    internal func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        print(manager.homes)
        if let primaryHome = manager.primaryHome {
            whatsInTheRoom(primaryHome)
        } else {
            addHome()
        }
    }
    
    func accessoryBrowser(_ browser: HMAccessoryBrowser, didFindNewAccessory accessory: HMAccessory) {
        print(accessory)
        present(UIAlertController(title: accessory.name, message: "Do you want to add it to your home?") {
            self.home?.addAccessory(accessory) { (error) in
                print(error ?? "no error")
                if error == nil {
                    self.accessory = accessory
                }
            }
        })
    }
    
    @objc private func whatsInTheHome() {
        whatsInTheRoom(home!)
    }
        
    private func whatsInTheRoom(_ home: HMHome) {
        self.home = home
        privacyVC.button.isHidden = false
        guard let accessory = home.accessories.filter({
            return $0.isReachable && !$0.services.filter { $0.serviceType == HMServiceTypeLightbulb }.isEmpty
        }).first else {
            privacyVC.label.text = "Browsing Accessories"
            privacyVC.buttonSwap(title: "Tap to stop", target: self, action: #selector(stopSearchingForNewAccessories))
            browser.startSearchingForNewAccessories()
            return
        }
        self.accessory = accessory
        privacyVC.label.text = "Found \(accessory.name) @ \(accessory.room?.name ?? home.name)"
        privacyVC.buttonSwap(title: "Turn it on/off", target: self, action: #selector(turnOnOff))
        print(accessory.services)
    }
    
    @objc func stopSearchingForNewAccessories() {
        browser.stopSearchingForNewAccessories()
        privacyVC.label.text = "New accessory?"
        privacyVC.button.isHidden = false
        privacyVC.buttonSwap(title: "Tap to browse", target: self, action: #selector(whatsInTheHome))
    }
    
    @objc func turnOnOff() {
        let services = accessory?.services.filter {
            $0.serviceType == HMServiceTypeLightbulb
        }
        if let service = services?.filter({
            return $0.serviceType == HMServiceTypeLightbulb
        }).first, let power = service.characteristics.filter({
            return $0.characteristicType == HMCharacteristicTypePowerState
        }).first, let value = power.value as? Int {
            power.writeValue(value == 0 ? 1 : 0) {
                print($0 ?? "no error")
            }
        }
    }
}
