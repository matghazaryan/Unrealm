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

class Passenger: NSObject, Codable, Realmable {
	@objc dynamic var guid: String = ""
	var msisdn: String = ""
	var fbToken: String? = nil
	var firstName: String = ""
	var lastName: String = ""
	var avatar: String? = nil
	var avgRating: String = ""
	var status: String? = nil
	var numberOfTrips: Int = 0
	var token: String? = ""
	var driver: Driver? = nil
	var lat: Double?
	var lng: Double?
	
	enum CodingKeys: String, CodingKey {
		case guid = "guid"
		case msisdn = "msisdn"
		case firstName = "first_name"
		case lastName = "last_name"
		case avatar = "avatar"
		case avgRating = "avg_rating"
		case status = "status"
		case numberOfTrips = "number_of_trips"
		case token
		case fbToken = "fb_token"
		case driver
		case l
		case lat
		case lng
	}
	
	required override init() {
		
	}
	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.guid = try container.decode(String.self, forKey: .guid)
		self.msisdn = try container.decode(String.self, forKey: .msisdn)
		self.firstName = try container.decode(String.self, forKey: .firstName)
		self.lastName = try container.decode(String.self, forKey: .lastName)
		self.avatar = try container.decodeIfPresent(String.self, forKey: .avatar)
		self.avgRating = try container.decode(String.self, forKey: .avgRating)
		self.status = try container.decodeIfPresent(String.self, forKey: .status)
		self.numberOfTrips = try container.decode(Int.self, forKey: .numberOfTrips)
		self.token = try container.decodeIfPresent(String.self, forKey: .token)
		self.fbToken = try container.decodeIfPresent(String.self, forKey: .fbToken)
		self.driver = try container.decodeIfPresent(Driver.self, forKey: .driver)
		if let l = try container.decodeIfPresent([Double].self, forKey: .l),
		   l.count == 2 {
			lat = l[0]
			lng = l[1]
		}
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encodeIfPresent(guid, forKey: .guid)
		try container.encodeIfPresent(msisdn, forKey: .msisdn)
		try container.encodeIfPresent(firstName, forKey: .firstName)
		try container.encodeIfPresent(lastName, forKey: .lastName)
		try container.encodeIfPresent(avatar, forKey: .avatar)
		try container.encodeIfPresent(avgRating, forKey: .avgRating)
		try container.encodeIfPresent(status, forKey: .status)
		try container.encodeIfPresent(numberOfTrips, forKey: .numberOfTrips)
		try container.encodeIfPresent(token, forKey: .token)
		try container.encodeIfPresent(fbToken, forKey: .fbToken)
		try container.encodeIfPresent(driver, forKey: .driver)
		if let l1 = lat, let l2 = lng {
			try container.encodeIfPresent([l1, l2], forKey: .l)
		}
	}
	
	
	init(guid: String, msisdn: String, firstName: String, lastName: String, avatar: String?, avgRating: String, status: String?, numberOfTrips: Int, driverGUID: String?) {
		self.guid = guid
		self.msisdn = msisdn
		self.firstName = firstName
		self.lastName = lastName
		self.avatar = avatar
		self.avgRating = avgRating
		self.status = status
		self.numberOfTrips = numberOfTrips
		super.init()
	}
	
	static func primaryKey() -> String? {
		return "guid"
	}
}
