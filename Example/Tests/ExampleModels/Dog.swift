//
//  Dog.swift
//  Unrealm_Example
//
//  Created by Artur Mkrtchyan on 5/20/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import Unrealm

class Dog: Realmable {
	var id: String = UUID().uuidString
	var name: String = ""
	var surname: String = ""

	required init() {

	}

	convenience init(name: String, surname: String) {
		self.init()
		self.name = name
		self.surname = surname
	}

	static func == (lhs: Dog, rhs: Dog) -> Bool {
		return lhs.name == rhs.name
	}

	static func primaryKey() -> String? {
		return "id"
	}
}
