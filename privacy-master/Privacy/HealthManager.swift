//
//  NFCVC.swift
//  Privacy
//
//  Created by Manuel @StuFFmc Carrasco Molina on 8.12.18.
//  Copyright © 2018 Pomcast.biz. All rights reserved.
//
import HealthKit
import CoreLocation
import MapKit

class WorkoutPin : NSObject, MKAnnotation {
    let location: CLLocation
    
    init(location: CLLocation) {
        self.location = location
    }
    
    var coordinate: CLLocationCoordinate2D {
        return location.coordinate
    }
}

class HealthManager: NSObject, CLLocationManagerDelegate {
    static let shared = HealthManager()
    
    var locationManagerCompletion: ((CLLocation)->())?
    let store = HKHealthStore()
    let distanceType = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!
    let configuration = HKWorkoutConfiguration()
    
    private let workTitle = "Work"
    private let dateOfBirth = HKObjectType.characteristicType(forIdentifier: .dateOfBirth)
    private let heightType = HKObjectType.quantityType(forIdentifier: .height)
    private let stepType = HKObjectType.quantityType(forIdentifier: .stepCount)
    private var routeBuilder: HKWorkoutRouteBuilder!
    private var locationManager: CLLocationManager!
    private var startDate: Date?
    private var totalDistance = HKQuantity(unit: HKUnit.meter(), doubleValue: 42)
    
    private override init() {
        configuration.activityType = .running
        configuration.locationType = .outdoor
    }
    
    func requestAuthorization(age: @escaping (_ year: Int)->(), height: @escaping (_ quantity: HKQuantity)->(), stepsCount: @escaping (_ sum: HKQuantity)->()) {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        
        // , let stepType = stepType
        guard let dateOfBirth = dateOfBirth, let heightType = heightType else {
            return
        }
        
        store.requestAuthorization(toShare: nil, read: [dateOfBirth, heightType, HKObjectType.activitySummaryType()]) { (success, error) in
            do {
                try self.updateDateOfBirth(completion: age)
                self.updateHeight(completion: height)
                self.updateSteps(completion: stepsCount)
            } catch {
                print(error)
            }
        }
        
        // TODO: Display workout on Maps.
        // TODO: Add a button to request Health Data! (for example Immunization)
    }
    
    func startWorkout(_ buttonTitle: String) -> String {
        if buttonTitle == workTitle {
            startDate = Date()
            store.requestAuthorization(toShare: [.workoutType()],
                                       read: [.quantityType(forIdentifier: .heartRate)!,
                                              .quantityType(forIdentifier: .activeEnergyBurned)!,
                                              .quantityType(forIdentifier: .distanceWalkingRunning)!,
                                              .quantityType(forIdentifier: .distanceCycling)!])
            { (success, error) in
                print(success)
                guard success else {
                    return print(error ?? success)
                }
                DispatchQueue.main.async {
                    self.startRouteBuilder()
                }
                if #available(iOS 12.0, *) {
                    //                let builder = HKWorkoutBuilder(healthStore: self.store,
                    //                                               configuration: self.configuration,
                    //                                               device: nil)
                    //                builder.beginCollection(withStart: Date(), completion: { (success, error) in
                    //                    <#code#>
                    //                })
                } else {
                    print("Only for iOS 12")
                }
            }
            return "Stop"
        } else {
            locationManager.stopUpdatingLocation()
            let endDate = Date()
            let metadata = [HKMetadataKeyIndoorWorkout:false]
//            let pause = HKWorkoutEvent(type: HKWorkoutEventType.Pause, date: pauseStart)
//            let resume = HKWorkoutEvent(type: HKWorkoutEventType.Resume, date: pauseEnd)
            
            let workout = HKWorkout(activityType: configuration.activityType, start: startDate!, end: endDate,
                                    workoutEvents: nil, // [pause, resume],
                                    totalEnergyBurned: HKQuantity(unit: HKUnit.largeCalorie(), doubleValue: 1),
                                    totalDistance: totalDistance,
                                    metadata: metadata)
            
            store.save(workout) { (success, error) in
                self.saveWorkout(workout, endDate: endDate)
            }
            return workTitle
        }
    }
    
    private func saveWorkout(_ workout: HKWorkout, endDate: Date) {
        let totalDistanceSample = HKQuantitySample(type: HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!,
                                                   quantity: totalDistance,
                                                   start: startDate!,
                                                   end: endDate)
        
        // Add samples to workout
        store.add([totalDistanceSample], to: workout) { (success: Bool, error: Error?) in
            if !success {
                print(error ?? "no error")
            }
        }
        
        routeBuilder.finishRoute(with: workout, metadata: nil) { (route, error) in
            print(route ?? (error ?? "no error"))
        }
    }
    
    private func startRouteBuilder() {
        if !CLLocationManager.locationServicesEnabled() { return }
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.startUpdatingLocation()
        routeBuilder = HKWorkoutRouteBuilder(healthStore: store, device: nil)        
    }
    
    func updateDateOfBirth(completion: @escaping (_ year: Int)->()) throws {
      if let bd = try store.dateOfBirthComponents().date,
        let year = NSCalendar.current.dateComponents([.year], from: bd, to: Date()).year {
          DispatchQueue.main.async {
            completion(year)
      } }
    }
    
    func updateHeight(completion: @escaping (_ quantity: HKQuantity)->()) {
      guard let height = heightType else { return }
      let query = HKSampleQuery(sampleType: height) { (query, samples, eror) in
          DispatchQueue.main.async {
            if let sample = samples?.first as? HKQuantitySample {
                  completion(sample.quantity)
          }   }
      }
      self.store.execute(query)
    }
    
    func updateSteps(completion: @escaping (_ stepsCount: HKQuantity)->()) {
        let query = HKStatisticsQuery(quantityType: stepType!, quantitySamplePredicate: nil, options: .cumulativeSum, completionHandler: { (query, result, error) in
            if let sum = result?.sumQuantity() {
                DispatchQueue.main.async {
                    completion(sum)
                }
            }
        })
        self.store.execute(query)
    }
    
    // MARK: CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locations.forEach {
            locationManagerCompletion?($0)
        }
        print(locations)
        routeBuilder.insertRouteData(locations) { (success, error) in
            print(error ?? success)
        }
    }
}

extension HKSampleQuery {
    convenience init(sampleType: HKSampleType, resultsHandler: @escaping (HKSampleQuery, [HKSample]?, Error?) -> Void) {
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate,
                                          ascending: false)
        self.init(sampleType: sampleType, predicate: nil, limit: 1,
                                  sortDescriptors: [sortDescriptor],
                                  resultsHandler: resultsHandler)
    }
}
