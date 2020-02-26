//
//  AppDelegate.swift
//  Example with Abstraction
//
//  Created by Artur Mkrtchyan on 2/26/20.
//  Copyright © 2020 arturdev. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	var window: UIWindow?

	static var shared = UIApplication.shared.delegate as! AppDelegate
	
	var storage = StorageProvider.provide(type: .realm)
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		storage.registerStorables(ToDoItem.self)
		return true
	}
}

