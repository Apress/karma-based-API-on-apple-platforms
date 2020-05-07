//
//  SceneDelegate.swift
//  PrivacyWS
//
//  Created by StuFF mc on 06.05.20.
//  Copyright © 2020 Manuel @StuFFmc Carrasco Molina. All rights reserved.
//

import UIKit

enum Chapters: String, CaseIterable {
	case Nothing
	case Location
	case Contacts
	case Photos
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
	var window: UIWindow?
	var toolBarDelegate: ToolbarDelegate?
	
	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		#if targetEnvironment(macCatalyst)
		if let titlebar = (scene as? UIWindowScene)?.titlebar, let viewController = window?.rootViewController as? ViewController {
			let toolbar = NSToolbar()
			toolbar.centeredItemIdentifier = ToolbarDelegate.identifier
			toolBarDelegate = ToolbarDelegate(viewController: viewController)
			toolbar.delegate = toolBarDelegate
			titlebar.toolbar = toolbar
			titlebar.titleVisibility = .hidden
		}
		#endif
	}
}

#if targetEnvironment(macCatalyst)
class ToolbarDelegate: NSObject, NSToolbarDelegate {
	static let identifier = NSToolbarItem.Identifier(rawValue: "")
	var viewController: ViewController
	let selectionChange = SelectionChange()
	
	init(viewController: ViewController) {
		self.viewController = viewController
	}

	func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
		let group = NSToolbarItemGroup(itemIdentifier: ToolbarDelegate.identifier, titles: Chapters.allCases.map { $0.rawValue }, selectionMode: .selectOne, labels: nil, target: self, action: #selector(toolbarGroupSelectionChanged))
		group.selectedIndex = 0
		return group
	}
		
	@objc func toolbarGroupSelectionChanged(sender: NSToolbarItemGroup) {
		selectionChange.selectionChanged(in: viewController, to: sender.selectedIndex)
	}
		
	func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
		return [Self.identifier]
	}
		
	func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
		return self.toolbarDefaultItemIdentifiers(toolbar)
	}
}
#else
class ToolbarDelegate { } // To avoid to mark the declaration of the variable in SceneDelegate
#endif

class SelectionChange {
	@objc func selectionChanged(in viewController: ViewController, to index: Int) {
		switch Chapters.allCases[index] {
		case .Location: viewController.location()
		case .Contacts: viewController.contacts()
		case .Photos: viewController.photos()
		default: viewController.mapView.removeAnnotations(viewController.mapView.annotations)
		}
	}
}
