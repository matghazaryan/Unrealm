import XCTest

@testable import Unrealm
import Realm
import RealmSwift

class Tests: XCTestCase {
    
    lazy var realm: Realm = {
        return try! Realm(configuration: Tests.configRealm())
    }()
    
    private static func configRealm() -> Realm.Configuration {
		let realmableTypes: [RealmableBase.Type] = [Dog.self,
													User.self,
													Person.self,
													SubPerson.self,
													Location.self,
													Passenger.self,
													Driver.self,
													ParentStruct.self,
													ParentStruct.ChildStruct.self]
		Realm.registerRealmables(realmableTypes,
								 enums: [MyEnum.self])

		var objectTypes = realmableTypes.compactMap({$0.objectType()})
		objectTypes.append(RLMTestClass.self)
        let config = Realm.Configuration(fileURL: URL(fileURLWithPath: RLMRealmPathForFile("unrealm_tests.realm")),
                                                      schemaVersion: 1,
                                                      migrationBlock: nil,
                                                      deleteRealmIfMigrationNeeded: true,
													  objectTypes: objectTypes)

        return config
    }
    
    override func setUp() {
        super.setUp()
        print()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

	func testNested() {
		let child = ParentStruct.ChildStruct(id: UUID().uuidString, name: "Child", childEnum: .case2)
		let parent = ParentStruct(id: UUID().uuidString, name: "Parent", child: child)
		try! self.realm.write {
			self.realm.add(parent, update: .all)
		}

		let savedParent = self.realm.object(ofType: ParentStruct.self, forPrimaryKey: parent.id)
		XCTAssertEqual(parent.id, savedParent?.id)
		XCTAssertEqual(parent.name, savedParent?.name)
		XCTAssertEqual(parent.child.id, savedParent?.child.id)
		XCTAssertEqual(parent.child.name, savedParent?.child.name)
		XCTAssertEqual(parent.child.childEnum, savedParent?.child.childEnum)
	}

	func testPassenger() {
		let url = Bundle(for: type(of: self)).url(forResource: "passenger", withExtension: "json")!
		let jsonData = try! Data(contentsOf: url)
		let passenger = try! JSONDecoder().decode(Passenger.self, from: jsonData)
		try! self.realm.write {
			self.realm.add(passenger, update: .all)
		}

		let savedP = self.realm.objects(Passenger.self).last
		XCTAssertEqual(passenger.firstName, savedP?.firstName)
		XCTAssertEqual(passenger.driver, nil)
	}

	func testPassengerWithDriver() {
		let url = Bundle(for: type(of: self)).url(forResource: "passengerWithDriver", withExtension: "json")!
		let jsonData = try! Data(contentsOf: url)
		let passenger = try! JSONDecoder().decode(Passenger.self, from: jsonData)
		try! self.realm.write {
			self.realm.add(passenger, update: .all)
		}

		let savedP = self.realm.objects(Passenger.self).last
		XCTAssertEqual(passenger.firstName, savedP?.firstName)
		XCTAssertEqual(passenger.driver?.numberOfTrips, savedP?.driver?.numberOfTrips)
	}
    
    func test_with_class_inheritance() {
        let p = SubPerson()
        p.name = "Name"
        p.surname = "SurName"
        try! self.realm.write {
            self.realm.add(p)
        }
        
        let savedP = self.realm.objects(SubPerson.self).last
		XCTAssertEqual(p.surname, savedP?.surname)
		XCTAssertEqual(p.name, savedP?.name)
    }
    
    func test_with_swift_class_type() {
        let dog = Dog(name: "Puppy", surname: "Steward")
        try! self.realm.write {
            self.realm.add(dog)
        }
        
		let savedDog = self.realm.object(ofType: Dog.self, forPrimaryKey: dog.id)
        XCTAssertNotNil(savedDog)
        XCTAssertEqual(dog.id, savedDog?.id)
        XCTAssertEqual(dog.name, savedDog?.name)
        XCTAssertEqual(dog.surname, savedDog?.surname)
    }
    
    func test_with_swift_struct_type() {
        let loc = Location(lat: 1.1, lng: 2.4)
        try! self.realm.write {
            self.realm.add(loc)
        }
        
        let savedLoc = self.realm.objects(Location.self).last
        XCTAssertNotNil(savedLoc)
        XCTAssertEqual(loc.lat, savedLoc?.lat)
        XCTAssertEqual(loc.lng, savedLoc?.lng)
    }
    
    func test_with_nested_swift_structs_type() {
        let loc1 = Location(lat: 1.3, lng: 2.4)
        let loc2 = Location(lat: 6.1, lng: 1.5)
        let loc3 = Location(lat: 9.2, lng: 1.6)
        
        let user = User(id: UUID().uuidString,
                        a: "Some a",
                        b: "Some b",
                        ignorable: "Some ignorable",
                        list: [loc1, loc2],
                        loc: loc3,
                        locOptional: Location(lat: 5.5, lng: 6.6),
                        enumVal: .case2,
                        dic: ["x" : 1, "y" : "y"],
						dicInt: [1 : 1, 2 : 2, 3 : 3],
						intOptional: 3,
						floatOptional: 3.4,
						doubleOptional: 1.3,
						boolOptional: true,
						arrayOptional: nil,
						arrayOfEnums: [],
						arrayOfEnumsOptional: nil)

        try! self.realm.write {
            self.realm.add(user)
        }
        
		let savedUser = self.realm.object(ofType: User.self, forPrimaryKey: user.id)
        XCTAssertNotNil(savedUser)
       
        XCTAssertEqual(user.id, savedUser!.id)
        XCTAssertEqual(user.a, savedUser!.a)
        XCTAssertEqual(user.b, savedUser!.b)
        XCTAssertEqual(savedUser!.ignorable, "ignorableInitialValue")
        XCTAssertEqual(user.loc.lat, savedUser!.loc.lat)
        XCTAssertEqual(user.loc.lng, savedUser!.loc.lng)
        XCTAssertEqual(user.locOptional?.lat, savedUser!.locOptional?.lat)
        XCTAssertEqual(user.locOptional?.lng, savedUser!.locOptional?.lng)
        XCTAssertEqual(user.enumVal, savedUser!.enumVal)
        XCTAssertEqual(NSDictionary(dictionary: user.dic), NSDictionary(dictionary: savedUser!.dic))
		XCTAssertEqual(NSDictionary(dictionary: user.dicInt), NSDictionary(dictionary: savedUser!.dicInt))
        XCTAssertEqual(user.intOptional, savedUser!.intOptional)
		XCTAssertEqual(user.arrayOptional, savedUser!.arrayOptional)
		XCTAssertEqual(user.arrayOfEnums, savedUser!.arrayOfEnums)
		XCTAssertEqual(user.arrayOfEnumsOptional, savedUser!.arrayOfEnumsOptional)

        XCTAssertEqual(user.list.count, savedUser!.list.count)
        for i in 0..<user.list.count {
            XCTAssertEqual(user.list[i].lat, savedUser!.list[i].lat)
            XCTAssertEqual(user.list[i].lng, savedUser!.list[i].lng)
        }
    }

	func testWithNilValues() {
		let loc3 = Location(lat: 9.2, lng: 1.6)
		let user = User(id: UUID().uuidString,
						a: "Some a",
						b: nil,
						ignorable: nil,
						list: [],
						loc: loc3,
						locOptional: nil,
						enumVal: .case2,
						dic: ["x" : 1, "y" : "y"],
						intOptional: nil,
						floatOptional: nil,
						doubleOptional: nil,
						boolOptional: nil)

		try! self.realm.write {
			self.realm.add(user)
		}

		let savedUser = self.realm.object(ofType: User.self, forPrimaryKey: user.id)
		XCTAssertNotNil(savedUser)

		XCTAssertEqual(user.id, savedUser!.id)
		XCTAssertEqual(user.a, savedUser!.a)
		XCTAssertEqual(user.b, savedUser!.b)
		XCTAssertEqual(savedUser!.ignorable, "ignorableInitialValue")
		XCTAssertEqual(user.loc.lat, savedUser!.loc.lat)
		XCTAssertEqual(user.loc.lng, savedUser!.loc.lng)
		XCTAssertEqual(user.locOptional?.lat, savedUser!.locOptional?.lat)
		XCTAssertEqual(user.locOptional?.lng, savedUser!.locOptional?.lng)
		XCTAssertEqual(user.enumVal, savedUser!.enumVal)
		XCTAssertEqual(NSDictionary(dictionary: user.dic), NSDictionary(dictionary: savedUser!.dic))
		XCTAssertEqual(user.intOptional, savedUser!.intOptional)

		XCTAssertEqual(user.list.count, savedUser!.list.count)
		for i in 0..<user.list.count {
			XCTAssertEqual(user.list[i].lat, savedUser!.list[i].lat)
			XCTAssertEqual(user.list[i].lng, savedUser!.list[i].lng)
		}
	}

	func testWithChildRealmable() {
		let user = User(id: UUID().uuidString,
						a: "Some a",
						b: "Some b",
						ignorable: "Some ignorable",
						list: [],
						loc: Location(lat: 9.2, lng: 1.6),
						locOptional: Location(lat: 5.5, lng: 6.6),
						enumVal: .case2,
						dic: ["x" : 1, "y" : "y"],
						intOptional: 3,
						floatOptional: 3.4,
						doubleOptional: 1.3,
						boolOptional: true)

		try! self.realm.write {
			self.realm.add(user)
		}

		let savedUser = self.realm.object(ofType: User.self, forPrimaryKey: user.id)
		XCTAssertNotNil(savedUser)
		XCTAssertEqual(user.id, savedUser!.id)
		XCTAssertEqual(user.a, savedUser!.a)
		XCTAssertEqual(user.b, savedUser!.b)
		XCTAssertEqual(savedUser!.ignorable, "ignorableInitialValue")
		XCTAssertEqual(user.loc.lat, savedUser!.loc.lat)
		XCTAssertEqual(user.loc.lng, savedUser!.loc.lng)
		XCTAssertEqual(user.locOptional?.lat, savedUser!.locOptional?.lat)
		XCTAssertEqual(user.locOptional?.lng, savedUser!.locOptional?.lng)
		XCTAssertEqual(user.enumVal, savedUser!.enumVal)
		XCTAssertEqual(NSDictionary(dictionary: user.dic), NSDictionary(dictionary: savedUser!.dic))
		XCTAssertEqual(user.intOptional, savedUser!.intOptional)

		XCTAssertEqual(user.list.count, savedUser!.list.count)
		for i in 0..<user.list.count {
			XCTAssertEqual(user.list[i].lat, savedUser!.list[i].lat)
			XCTAssertEqual(user.list[i].lng, savedUser!.list[i].lng)
		}
	}

	func testOldRealm() {
		let obj = RLMTestClass()
		obj.name = "Some Name"
		try! self.realm.write {
			self.realm.add(obj)
		}

		let savedObj = self.realm.object(ofType: RLMTestClass.self, forPrimaryKey: obj.id)
		XCTAssertNotNil(savedObj)
		XCTAssertEqual(obj.id, savedObj!.id)
		XCTAssertEqual(obj.name, savedObj!.name)

	}
}
