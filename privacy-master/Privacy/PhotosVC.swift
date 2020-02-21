//  Created by Manuel @stuffmc Carrasco Molina on 2018-05-12

import UIKit
import Photos
import MapKit
import Contacts
import ContactsUI

class Image: NSObject, MKAnnotation {
    var asset: PHAsset
    var dateFormatter: DateFormatter

    init(asset: PHAsset, dateFormatter: DateFormatter) {
        self.asset = asset
        self.dateFormatter = dateFormatter
        super.init()
    }
    
    var coordinate: CLLocationCoordinate2D {
        get { return asset.location!.coordinate }
    }
    
    var title: String? {
        get { return dateFormatter.string(from: asset.creationDate!)}
    }
}

class PhotosVC: PrivacyContainerVC, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let dateFormatter = DateFormatter()
    let size = 80
    
    private var images = [String: UIImage]()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        privacyVC.label.isHidden = true
    }
    
    @IBAction func pick(_ sender: Any) {
        #if targetEnvironment(simulator)
            self.pickFrom(.photoLibrary)
        #else
            let alert = UIAlertController(title: "Which source?", message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (_) in self.pickFrom(.camera) }))
            alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (_) in self.pickFrom(.photoLibrary) }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alert, animated: true)
        #endif
    }
    
    @IBAction func add(_ sender: Any) {
        UIImageWriteToSavedPhotosAlbum(#imageLiteral(resourceName: "icon-photos"), nil, nil, nil)
//        PHPhotoLibrary.requestAuthorization { (status) in
//            print(status.rawValue)
        
//            PHPhotoLibrary.shared().performChanges({
//                PHAssetCreationRequest.creationRequestForAsset(from: #imageLiteral(resourceName: "icon-photos"))
//            }, completionHandler: { (success, error) in
//                print(success)
//                print(error ?? "no error")
//            })
//        }
    }
    
    private func pickFrom(_ source: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.sourceType = source
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true) {}
    }
    

    @IBAction func allow(_ sender: Any) {
        privacyVC.label.isHidden = false
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                self.privacyVC.updateUserInterfaceAfterPermissionRequest(status: status.rawValue, authorizedMessage: "We found \(self.stealLocationUserData().count) assets")
            }
        }
    }
    
    func stealLocationUserData() -> [PHAsset] {
        var assets = [PHAsset]()
        let photos = PHAsset.fetchAssets(with: .image, options: nil)
        var locations = [Image]()
        photos.enumerateObjects { (asset, _, _) in
            if asset.location != nil {
                locations.append(Image(asset: asset, dateFormatter: self.dateFormatter))
            }
            assets.append(asset)
        }
        locations.forEach {
            privacyVC.mapView.addAnnotation($0)
            let identifier = $0.asset.localIdentifier
            PHImageManager.default().requestImage(for: $0.asset, targetSize: CGSize(width: size, height: size), contentMode: .aspectFill, options: nil) { (fetchedImage, _) in
                self.images[identifier] = fetchedImage
                self.privacyVC.mapView.isHidden = self.images.count < locations.count
            }
            privacyVC.mapView.setCenter($0.coordinate, animated: true)
        }
        return assets
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let image = annotation as? Image else {
            return MKAnnotationView()
        }
        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: String(describing: image.asset.creationDate!))
        let imageView = UIImageView(image: images[image.asset.localIdentifier])
        imageView.center = annotationView.center
        imageView.layer.cornerRadius = 5
        imageView.clipsToBounds = true
        annotationView.addSubview(imageView)
        annotationView.canShowCallout = true
        return annotationView
    }
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        defer {
            picker.dismiss(animated: true)
        }
        print(info)
        
        let image = info[.editedImage] ?? info[.originalImage]
        print(image ?? "no image")

        guard let url = info[.imageURL] as? URL else {
            return
        }
        print(url)

        let data = try! Data(contentsOf: url) // Obviously you shouldn't force try and you should use an API!
        print(data)

        guard let asset = info[.phAsset] as? PHAsset else {
            return
        }
        print(asset)
    }
    
    // Interestengly in this case we don't need to implement `didCancel`.
    // Beware that if you *do* implement it, you'll need to dismiss manually!
}
