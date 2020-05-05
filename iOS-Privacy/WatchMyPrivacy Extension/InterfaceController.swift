//
//  InterfaceController.swift
//  WatchMyPrivacy Extension
//
//  Created by StuFF mc on 08.12.18.
//  Copyright © 2018 Pomcast.biz. All rights reserved.
//

import WatchKit
import Foundation
import HealthKit

class InterfaceController: WKInterfaceController, HKWorkoutSessionDelegate {
    private let healthManager = HealthManager.shared
    private var title = "Work"
    private var session: HKWorkoutSession?
    @IBOutlet weak var label: WKInterfaceLabel!
    @IBOutlet weak var button: WKInterfaceButton!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        session = try! HKWorkoutSession(healthStore: HealthManager.shared.store, configuration: HealthManager.shared.configuration)
        session?.delegate = self
    }
    
    override func willActivate() {
        super.willActivate()
        HealthManager.shared.requestAuthorization(age: {
            self.label.setText("You are \($0) years old")
        }, height: {
            print($0)
            //            if let text = self.label.text {
            //                self.label.text = "\(text) and \($0)"
            //            }
        }, stepsCount: {
            print($0)
        })
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    @IBAction func startWorkout() {
        if title == "Work" {
            session!.startActivity(with: Date())
        } else {
            session!.stopActivity(with: Date())
        }
        title = healthManager.startWorkout(title)
        button.setTitle(title)
    }
    
    // MARK: HKWorkoutSessionDelegate
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print("workout session did fail with error: \(error)")
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didGenerate event: HKWorkoutEvent) {
//        workoutEvents.append(event)
        print("workout session didGenerate: \(event)")
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession,
                        didChangeTo toState: HKWorkoutSessionState,
                        from fromState: HKWorkoutSessionState,
                        date: Date) {
        print("workout session didChange")
        print(fromState)
        print(toState)
    }
}
