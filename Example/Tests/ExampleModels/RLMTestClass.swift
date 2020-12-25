//
//  RLMTestClass.swift
//  Unrealm_Example
//
//  Created by Artur Mkrtchyan on 1/14/20.
//  Copyright © 2020 arturdev. All rights reserved.
//

import UIKit
import RealmSwift

class RLMTestClass: Object {
	@objc dynamic var id: String = UUID().uuidString
	@objc dynamic var name: String = ""
	
	override static func primaryKey() -> String? {
		return "id"
	}
}
