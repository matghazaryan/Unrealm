//
//  Passenger.swift
//  Unrealm
//
//  Created by Artur Mkrtchyan on 5/2/19.
//  Copyright © 2019 arturdev. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import Unrealm

class Driver: NSObject, Codable, Realmable {
	@objc dynamic var guid: String
	let avgRating: String
	let currentBalance: String
	let numberOfTrips: Int?
	let cityId: Int?
	let countryId: Int?
	let partnerId: Int?
	let hasVehicle: String
	var driverStatus: String = "new"
	let regStep: String
	
	enum CodingKeys: String, CodingKey {
		case guid = "guid"
		case avgRating = "avg_rating"
		case currentBalance = "current_balance"
		case numberOfTrips = "number_of_trips"
		case cityId = "city_id"
		case countryId = "country_id"
		case partnerId = "partner_id"
		case hasVehicle = "has_vehicle"
		case driverStatus = "driver_status"
		case regStep = "reg_step"
	}
	
	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.guid = try container.decode(String.self, forKey: .guid)
		self.avgRating = try container.decode(String.self, forKey: .avgRating)
		self.currentBalance = try container.decode(String.self, forKey: .currentBalance)
		self.numberOfTrips = try container.decodeIfPresent(Int.self, forKey: .numberOfTrips)
		self.cityId =  try container.decodeIfPresent(Int.self, forKey: .cityId)
		self.countryId =  try container.decodeIfPresent(Int.self, forKey: .countryId)
		self.partnerId =  try container.decodeIfPresent(Int.self, forKey: .partnerId)
		self.hasVehicle = try container.decode(String.self, forKey: .hasVehicle)
		self.driverStatus = try container.decode(String.self, forKey: .driverStatus)
		self.regStep = try container.decode(String.self, forKey: .regStep)
		super.init()
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(self.guid, forKey: .guid)
		try container.encode(self.avgRating, forKey: .avgRating)
		try container.encode(self.currentBalance, forKey: .currentBalance)
		try container.encodeIfPresent(self.numberOfTrips, forKey: .numberOfTrips)
		try container.encodeIfPresent(self.cityId, forKey: .cityId)
		try container.encodeIfPresent(self.countryId, forKey: .countryId)
		try container.encodeIfPresent(self.partnerId, forKey: .partnerId)
		try container.encode(self.hasVehicle, forKey: .hasVehicle)
		try container.encode(self.driverStatus, forKey: .driverStatus)
		try container.encode(self.regStep, forKey: .regStep)
	}
	
	required override init() {
		self.guid = ""
		self.avgRating = "0.0"
		self.currentBalance = ""
		self.numberOfTrips = 0
		self.cityId = nil
		self.countryId = nil
		self.partnerId = nil
		self.hasVehicle = "0"
		self.regStep = ""
		super.init()
	}
	
	static func primaryKey() -> String? {
		return "guid"
	}
	
	static func ignoredProperties() -> [String] {
		return []
	}
}
