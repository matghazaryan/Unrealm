import XCTest

@testable import Unrealm
import Realm
import RealmSwift

class Tests: XCTestCase {
    
    lazy var realm: Realm = {
        return try! Realm(configuration: Tests.configRealm())
    }()
    
    private static func configRealm() -> Realm.Configuration {
        let realmableTypes: [RealmableBase.Type] = [Dog.self, Location.self, User.self]
        Realm.registerRealmables(realmableTypes)
        let config = Realm.Configuration(fileURL: URL(fileURLWithPath: RLMRealmPathForFile("unrealm_tests.realm")),
                                                      schemaVersion: 1,
                                                      migrationBlock: nil,
                                                      deleteRealmIfMigrationNeeded: true,
                                                      objectTypes: realmableTypes.compactMap({$0.objectType()}))

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
    
    func test_with_swift_class_type() {
        let dog = Dog(name: "Puppy", surname: "Steward")
        try! self.realm.write {
            self.realm.add(dog)
        }
        
        let savedDog = self.realm.objects(Dog.self).last
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
                        dic: ["x" : 1, "y" : "y"])
        try! self.realm.write {
            self.realm.add(user)
        }
        
        let savedUser = self.realm.objects(User.self).last
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
        
        XCTAssertEqual(user.list.count, savedUser!.list.count)
        for i in 0..<user.list.count {
            XCTAssertEqual(user.list[i].lat, savedUser!.list[i].lat)
            XCTAssertEqual(user.list[i].lng, savedUser!.list[i].lng)
        }
    }
}
