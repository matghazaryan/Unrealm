//
//  Person.swift
//  Unrealm_Example
//
//  Created by Artur Mkrtchyan on 7/2/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import Unrealm

class Person: Decodable, Realmable {
	static func == (lhs: Person, rhs: Person) -> Bool {
		return lhs.name == rhs.name
	}
	
	var name: String = ""
	
	required init() {
		
	}
}

class SubPerson: Person {
	var surname: String = ""
}
