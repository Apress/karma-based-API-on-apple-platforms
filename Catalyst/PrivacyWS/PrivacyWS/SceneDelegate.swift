//
//  SceneDelegate.swift
//  PrivacyWS
//
//  Created by StuFF mc on 06.05.20.
//  Copyright © 2020 Manuel @StuFFmc Carrasco Molina. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate, NSToolbarDelegate {
	let identifier = NSToolbarItem.Identifier(rawValue: "")
	var window: UIWindow?
	
	enum Chapters: String, CaseIterable {
		case Nothing
		case Location
		case Contacts
		case Photos
	}

	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		if let titlebar = (scene as? UIWindowScene)?.titlebar {
			let toolbar = NSToolbar()
			toolbar.centeredItemIdentifier = identifier
			toolbar.delegate = self
			titlebar.toolbar = toolbar
			titlebar.titleVisibility = .hidden
		}
	}

	func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
		let group = NSToolbarItemGroup(itemIdentifier: identifier, titles: Chapters.allCases.map { $0.rawValue }, selectionMode: .selectOne, labels: nil, target: self, action: #selector(toolbarGroupSelectionChanged))
		group.selectedIndex = 0
		return group
	}
		
	@objc func toolbarGroupSelectionChanged(sender: NSToolbarItemGroup) {
		guard let vc = window?.rootViewController as? ViewController else { return }
		switch Chapters.allCases[sender.selectedIndex] {
		case .Location: vc.location()
		case .Contacts: vc.contacts()
		case .Photos: vc.photos()
		default: vc.mapView.removeAnnotations(vc.annotations)
		}
	}
		
	func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
		return [identifier]
	}
		
	func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
		return self.toolbarDefaultItemIdentifiers(toolbar)
	}
}
