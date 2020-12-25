//
//  User.swift
//  Unrealm
//
//  Created by Artur Mkrtchyan on 5/2/19.
//  Copyright © 2019 arturdev. All rights reserved.
//

import Foundation
import Unrealm

enum MyEnum: Int, RealmableEnumInt {
	case case1
	case case2
	case case3
}

struct User: Realmable {
	var id: String = UUID().uuidString
	var a: String = ""
	var b: String? = nil
	var ignorable: String? = "ignorableInitialValue"
	var list: [Location] = []
	var loc: Location = Location(lat: 0, lng: 0)
	var locOptional: Location? = nil
	var enumVal: MyEnum = .case1
	var dic: [String:Any] = [:]
	var dicInt: [Int:Int] = [:]
	var intOptional: Int? = nil
	var floatOptional: Float? = nil
	var doubleOptional: Double? = nil
	var boolOptional: Bool? = nil
	var arrayOptional: [Location]? = nil
	var arrayOfEnums: [MyEnum] = []
	var arrayOfEnumsOptional: [MyEnum]? = nil

	static func primaryKey() -> String? {
		return "id"
	}

	static func ignoredProperties() -> [String] {
		return ["ignorable"]
	}

	static func == (lhs: User, rhs: User) -> Bool {
		return lhs.id == rhs.id
	}

	static var realmClassPrefix: String {
		// As Realm already has a class named RLMUser,
		// we have to set a different prefix
		return "RLM_"
	}
}
