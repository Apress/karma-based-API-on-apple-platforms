//  Created by Manuel @stuffmc Carrasco Molina on 2018-05-13
import MapKit
import Photos

class PrivacyVC: UIViewController {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBAction func givePermission() {
        PrivacyVC.openSettings()
    }
    
    class func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    
    func updateUserInterfaceAfterPermissionRequest(status: Int, authorizedMessage: String? = nil) {
        DispatchQueue.main.async {
            switch status {
            case PHAuthorizationStatus.authorized.rawValue:
                self.label.text = authorizedMessage
            case PHAuthorizationStatus.denied.rawValue:
                self.label.text = "Please provide access for us to be able to do something useful."
                self.button.isHidden = false
            default:
                self.label.text = "Something wrong happened..."
            }
        }
    }
    
    func buttonSwap(title: String, target: AnyObject, action:Selector) {
        button.setTitle(title, for: .normal)
        button.removeTarget(nil, action: nil, for: .touchUpInside)
        button.addTarget(target, action: action, for: .touchUpInside)
    }
}

class PrivacyContainerVC: UIViewController, MKMapViewDelegate {
    var privacyVC: PrivacyVC!

    override func viewDidLoad() {
        super.viewDidLoad()
        privacyVC.mapView.delegate = self
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        privacyVC = segue.destination as? PrivacyVC
    }
}
