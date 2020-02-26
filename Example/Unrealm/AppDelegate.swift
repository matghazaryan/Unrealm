//
//  AppDelegate.swift
//  Unrealm
//
//  Created by arturdev on 05/18/2019.
//  Copyright (c) 2019 arturdev. All rights reserved.
//

import UIKit
import Unrealm

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    internal func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        Realm.registerRealmables(ToDoItem.self)
        
        return true
    }
}

