//
//  UIAlertController.swift
//  My Privacy
//
//  Created by StuFF mc on 11.01.19.
//  Copyright © 2019 Pomcast.biz. All rights reserved.
//
import UIKit

extension UIAlertController {
    
    convenience init(title: String, message: String, text: String, action: String, handler: @escaping ()->()) {
        self.init(title: title, message: message, preferredStyle: .alert)
        self.addTextField { $0.text = text }
        self.addAction(UIAlertAction(title: action, style: .default, handler: { (_) in
            handler()
        }))
    }
    
    convenience init(title: String, message: String, handler: @escaping ()->()) {
        self.init(title: title, message: message, preferredStyle: .alert)
        self.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (_) in
            handler()
        }))
        self.addAction(UIAlertAction(title: "No", style: .default, handler:nil))
    }

}
