//
//  Created by Manuel @StuFFmc Carrasco Molina on 27.11.18.
//  Copyright © 2018 Pomcast.biz. All rights reserved.
//
import HealthKit
import CoreLocation
import MapKit

class HealthKitVC: PrivacyContainerVC, CLLocationManagerDelegate {
    private let healthManager = HealthManager.shared
    private let store = HealthManager.shared.store
    @IBOutlet weak var showMedicationButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showMedicationButton.isEnabled = store.supportsHealthRecords()
        
        HealthManager.shared.locationManagerCompletion = {
          self.privacyVC.mapView.locate(with: $0)
        }
        HealthManager.shared.requestAuthorization(age: {
          self.privacyVC.label.isHidden = false
          self.privacyVC.label.text = "You are \($0) years old"
        }, height: {
          if let text = self.privacyVC.label.text {
            self.privacyVC.label.text = "\(text) and \($0)"
          }
        }, stepsCount: {
            if let text = self.privacyVC.label.text {
                let sum = $0.doubleValue(for: HKUnit.count())
                self.privacyVC.label.text = "\(text) with \(Int(sum)) steps"
            }
        })
    }
    
    @IBAction func showMedication(_ sender: Any) {
        guard let medication = HKObjectType.clinicalType(forIdentifier: .medicationRecord) else {
            return
        }
        store.getRequestStatusForAuthorization(toShare: [], read: [medication]) { (status, error) in
            print(status.rawValue)
        }

        store.requestAuthorization(toShare: nil, read: [medication]) { (success, error) in
            print(success)
            print(error ?? "no error")
            
            let query = HKSampleQuery(sampleType: medication,
                                      predicate: nil,
                                      limit: HKObjectQueryNoLimit,
                                      sortDescriptors: []) { (query, samples, error) in
                                        
                                        guard let sample = samples?.first as? HKClinicalRecord else {
                                            print("no items")
                                            return
                                        }
                                        print(String(data: sample.fhirResource!.data, encoding: .utf8)!)
                                        DispatchQueue.main.async {
                                            self.privacyVC.label.text = sample.displayName
                                        }
            }
            self.store.execute(query)
        }
    }
    
    @IBAction func startWorkout(_ button: UIBarButtonItem) {
        button.title = healthManager.startWorkout(button.title ?? "")
    }
}

extension MKMapView {
    func locate(with location: CLLocation) {
      isHidden = false
      addAnnotation(WorkoutPin(location: location))
      setCenter(location.coordinate, animated: true)
    }
  }
