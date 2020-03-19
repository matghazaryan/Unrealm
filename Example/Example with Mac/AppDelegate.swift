//
//  AppDelegate.swift
//  Example with Mac
//
//  Created by Artur Mkrtchyan on 3/20/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Cocoa
import Unrealm

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

	var windowController: WindowController!

	func applicationDidFinishLaunching(_ aNotification: Notification) {

		Realm.registerRealmables(ToDoItem.self)

		windowController = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "WindowController") as? WindowController
		windowController.showWindow(self)
		windowController.window?.makeKey()
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}
}

