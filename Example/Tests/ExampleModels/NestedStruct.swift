//
//  NestedStruct.swift
//  Unrealm_Example
//
//  Created by Artur Mkrtchyan on 3/20/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import Unrealm

struct ParentStruct: Realmable {
	struct ChildStruct: Realmable {
		enum ChildEnum: Int, RealmableEnum {
			case case1
			case case2
			case case3
		}

		var id: String = ""
		var name: String = ""
		var childEnum: ChildEnum = .case1
		static func primaryKey() -> String? {
			return "id"
		}
	}

	var id: String = ""
	var name: String = ""
	var child: ChildStruct = ChildStruct()

	static func primaryKey() -> String? {
		return "id"
	}
}
