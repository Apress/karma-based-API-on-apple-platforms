//
//  ProjectTypeDescriptionDataSource.swift
//  Portraits
//
//  Created by StuFF mc on 10.08.18.
//  Copyright © 2018 Manuel @stuffmc Carrasco Molina. All rights reserved.
//

import PhotosUI

class ProjectTypeDescriptionDataSource: NSObject {

    class var rootLevelProjectTypes: [PHProjectTypeDescription] {
        return [PHProjectTypeDescription(projectType: .undefined, title: "Portrait Type", description: "Description", image: nil)]
    }
    
    // MARK: - PHProjectTypeDescriptionDataSource
    func subtypes(for projectType: PHProjectType) -> [PHProjectTypeDescription] {
        if projectType == .undefined {
            return type(of: self).rootLevelProjectTypes
        } else {
            let projectTypes = [PHProjectTypeDescription]()
            // TODO: Fill the array with PHProjectTypeDescription instances representing you project types for the given level.
            return projectTypes
        }
    }
    
    func typeDescription(for projectType: PHProjectType) -> PHProjectTypeDescription? {
        // TODO: return the requested project type which was previously invalidated
        return nil
    }
    
    func footerText(forSubtypesOf projectType: PHProjectType) -> NSAttributedString? {
        return nil
    }
    
}
