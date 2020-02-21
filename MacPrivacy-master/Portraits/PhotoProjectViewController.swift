//
//  PhotoProjectViewController.swift
//  Portraits
//
//  Created by StuFF mc on 10.08.18.
//  Copyright © 2018 Manuel @stuffmc Carrasco Molina. All rights reserved.
//

import Cocoa
import PhotosUI

@available(OSXApplicationExtension 10.13, *)
class PhotoProjectViewController: NSViewController, PHProjectExtensionController {
    
    var projectExtensionContext: PHProjectExtensionContext? {
        get {
            return extensionContext as? PHProjectExtensionContext
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    // MARK: - PHProjectExtensionController
    
    /// macOS 10.13 API to return PHProjectTypeDescription objects
    /// This method has to be implemented to support project type selection on macOS 10.13
    var supportedProjectTypes: [PHProjectTypeDescription] {
        // You can reuse the data source needed for macOS 10.14.
        return ProjectTypeDescriptionDataSource.rootLevelProjectTypes
    }
    
    func beginProject(with extensionContext: PHProjectExtensionContext, projectInfo: PHProjectInfo, completion: @escaping (Error?) -> Void) {
        DispatchQueue.main.async {
            // do initialization here
            completion(nil)
        }
    }
    
    func resumeProject(with extensionContext: PHProjectExtensionContext, completion: @escaping (Error?) -> Void) {
        DispatchQueue.main.async {
            // do initialization here
            completion(nil)
        }
    }
    
    func finishProject(completionHandler completion: @escaping () -> Void) {
        // do any finalization here
        completion()
    }
}
