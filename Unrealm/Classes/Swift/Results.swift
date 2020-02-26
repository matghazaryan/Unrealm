//
//  Results.swift
//  CRuntime
//
//  Created by Artur Mkrtchyan on 5/18/19.
//

import Foundation
import Realm
import RealmSwift

#if canImport(UnrealmObjC)
import UnrealmObjC
#endif

public struct AnyResults: RandomAccessCollection {
	public typealias Element = Realmable
    public typealias Index = Int

    public subscript(position: Int) -> Element {
        let res = rlmResult[position].toRealmable() as! Element
        res.setRealm(rlmResult.realm)
        return res
    }

    public func index(after i: Int) -> Int {
        return rlmResult.index(after: i)
    }

	public var startIndex: Index {
        return rlmResult.startIndex
    }

    public var endIndex: Index {
        return rlmResult.endIndex
    }

    public var last: Element? {
        return rlmResult.last?.toRealmable() as? Element
    }

	public var count: Int {
		return rlmResult.count
	}

	internal let rlmResult: RealmSwift.Results<Object>

    internal init(rlmResult: RealmSwift.Results<Object>) {
        self.rlmResult = rlmResult
    }

    public func observe(_ block: @escaping (RealmCollectionChange<AnyResults>) -> Void) -> NotificationToken {
        return rlmResult.observe({ (change) in
            switch change {
            case .error(let error):
                block(RealmCollectionChange.error(error))
            case .initial(let collection):
                block(RealmCollectionChange.initial(AnyResults(rlmResult: collection)))
            case .update(let collection, deletions: let deletions, insertions: let insertions, modifications: let modifications):				
                block(RealmCollectionChange.update(AnyResults(rlmResult: collection), deletions: deletions, insertions: insertions, modifications: modifications))
            }
        })
    }

	public func toArray() -> Array<Realmable> {
		return rlmResult.compactMap({$0.toRealmable() as? Realmable})
	}
}

public struct Results<Element: Realmable> {
    
    internal let rlmResult: RealmSwift.Results<Object>
    internal init(rlmResult: RealmSwift.Results<Object>) {
        self.rlmResult = rlmResult
    }
}

//MARK: - Filtering
extension Results {
    public func filter(_ predicateFormat: String, _ args: Any...) -> Results<Element> {
        return Results(rlmResult: rlmResult.filter(predicateFormat, args))
    }
    
    /**
     Returns a `Results` containing all objects matching the given predicate in the collection.
     
     - parameter predicate: The predicate with which to filter the objects.
     */
    public func filter(_ predicate: NSPredicate) -> Results<Element> {
        return Results(rlmResult: rlmResult.filter(predicate))
    }
}

//MARK: - Sorting
extension Results {
    
    /**
     Returns a `Results` containing the objects represented by the results, but sorted.
     
     Objects are sorted based on the values of the given key path. For example, to sort a collection of `Student`s from
     youngest to oldest based on their `age` property, you might call
     `students.sorted(byKeyPath: "age", ascending: true)`.
     
     - warning: Collections may only be sorted by properties of boolean, `Date`, `NSDate`, single and double-precision
     floating point, integer, and string types.
     
     - parameter keyPath:   The key path to sort by.
     - parameter ascending: The direction to sort in.
     */
    public func sorted(byKeyPath keyPath: String, ascending: Bool = true) -> Results<Element> {
        return Results(rlmResult: rlmResult.sorted(byKeyPath: keyPath, ascending: ascending))
    }
    
    /**
     Returns a `Results` containing the objects represented by the results, but sorted.
     
     - warning: Collections may only be sorted by properties of boolean, `Date`, `NSDate`, single and double-precision
     floating point, integer, and string types.
     
     - see: `sorted(byKeyPath:ascending:)`
     
     - parameter sortDescriptors: A sequence of `SortDescriptor`s to sort by.
     */
    public func sorted<S: Sequence>(by sortDescriptors: S) -> Results<Element>
        where S.Iterator.Element == SortDescriptor {
            return Results(rlmResult: rlmResult.sorted(by: sortDescriptors))
    }
}

//MARK: - Aggregate operations
extension Results {
    
    /**
     Returns a `Results` containing distinct objects based on the specified key paths
     
     - parameter keyPaths:  The key paths used produce distinct results
     */
    public func distinct<S: Sequence>(by keyPaths: S) -> Results<Element>
        where S.Iterator.Element == String {
            return Results(rlmResult: rlmResult.distinct(by: keyPaths))
    }
    
    /**
     Returns the minimum (lowest) value of the given property among all the results, or `nil` if the results are empty.
     
     - warning: Only a property whose type conforms to the `MinMaxType` protocol can be specified.
     
     - parameter property: The name of a property whose minimum value is desired.
     */
    public func min<T: MinMaxType>(ofProperty property: String) -> T? {
        return rlmResult.min(ofProperty: property)
    }
    
    /**
     Returns the maximum (highest) value of the given property among all the results, or `nil` if the results are empty.
     
     - warning: Only a property whose type conforms to the `MinMaxType` protocol can be specified.
     
     - parameter property: The name of a property whose minimum value is desired.
     */
    public func max<T: MinMaxType>(ofProperty property: String) -> T? {
        return rlmResult.max(ofProperty: property)
    }
    
    /**
     Returns the sum of the values of a given property over all the results.
     
     - warning: Only a property whose type conforms to the `AddableType` protocol can be specified.
     
     - parameter property: The name of a property whose values should be summed.
     */
    public func sum<T: AddableType>(ofProperty property: String) -> T {
        return rlmResult.sum(ofProperty: property)
    }
    
    /**
     Returns the average value of a given property over all the results, or `nil` if the results are empty.
     
     - warning: Only the name of a property whose type conforms to the `AddableType` protocol can be specified.
     
     - parameter property: The name of a property whose average value should be calculated.
     */
    public func average<T: AddableType>(ofProperty property: String) -> T? {
        return rlmResult.average(ofProperty: property)
    }
}

// MARK: - Notifications
extension Results {
    /**
     Registers a block to be called each time the collection changes.
     
     The block will be asynchronously called with the initial results, and then called again after each write
     transaction which changes either any of the objects in the collection, or which objects are in the collection.
     
     The `change` parameter that is passed to the block reports, in the form of indices within the collection, which of
     the objects were added, removed, or modified during each write transaction. See the `RealmCollectionChange`
     documentation for more information on the change information supplied and an example of how to use it to update a
     `UITableView`.
     
     At the time when the block is called, the collection will be fully evaluated and up-to-date, and as long as you do
     not perform a write transaction on the same thread or explicitly call `realm.refresh()`, accessing it will never
     perform blocking work.
     
     Notifications are delivered via the standard run loop, and so can't be delivered while the run loop is blocked by
     other activity. When notifications can't be delivered instantly, multiple notifications may be coalesced into a
     single notification. This can include the notification with the initial collection.
     
     For example, the following code performs a write transaction immediately after adding the notification block, so
     there is no opportunity for the initial notification to be delivered first. As a result, the initial notification
     will reflect the state of the Realm after the write transaction.
     
     ```swift
     let results = realm.objects(Dog.self)
     print("dogs.count: \(dogs?.count)") // => 0
     let token = dogs.observe { changes in
     switch changes {
     case .initial(let dogs):
     // Will print "dogs.count: 1"
     print("dogs.count: \(dogs.count)")
     break
     case .update:
     // Will not be hit in this example
     break
     case .error:
     break
     }
     }
     try! realm.write {
     let dog = Dog()
     dog.name = "Rex"
     person.dogs.append(dog)
     }
     // end of run loop execution context
     ```
     
     You must retain the returned token for as long as you want updates to be sent to the block. To stop receiving
     updates, call `invalidate()` on the token.
     
     - warning: This method cannot be called during a write transaction, or when the containing Realm is read-only.
     
     - parameter block: The block to be called whenever a change occurs.
     - returns: A token which must be held for as long as you want updates to be delivered.
     */
    public func observe(_ block: @escaping (RealmCollectionChange<Results<Element>>) -> Void) -> NotificationToken {
        return rlmResult.observe({ (change) in
            switch change {
            case .error(let error):
                block(RealmCollectionChange.error(error))
            case .initial(let collection):
                block(RealmCollectionChange.initial(Results(rlmResult: collection)))
            case .update(let collection, deletions: let deletions, insertions: let insertions, modifications: let modifications):
                block(RealmCollectionChange.update(Results(rlmResult: collection), deletions: deletions, insertions: insertions, modifications: modifications))
            }
        })
    }
}

//MARK: - Collection
extension Results: Collection {
    public typealias Index = Int
    
    public var startIndex: Index {
        return rlmResult.startIndex
    }
    
    public var endIndex: Index {
        return rlmResult.endIndex
    }
    
    public var last: Element? {
        return rlmResult.last?.toRealmable() as? Element
    }
    
    public subscript(position: Int) -> Element {
        let res = rlmResult[position].toRealmable(of: Element.self) as! Element
        res.setRealm(rlmResult.realm)
        return res
    }
    
    public func index(after i: Int) -> Int {
        return rlmResult.index(after: i)
    }
}

//MARK: - String Convertible
extension Results: CustomStringConvertible {
    public var description: String {
        return Array(self).map({return String(describing: $0)}).joined(separator: "\n")
    }
}

extension RealmCollectionChange {
    static func fromObjc(value: CollectionType, change: RLMCollectionChange?, error: Error?) -> RealmCollectionChange {
        if let error = error {
            return .error(error)
        }
        if let change = change {
            return .update(value,
                           deletions: forceCast(change.deletions, to: [Int].self),
                           insertions: forceCast(change.insertions, to: [Int].self),
                           modifications: forceCast(change.modifications, to: [Int].self))
        }
        return .initial(value)
    }
}

private func forceCast<A, U>(_ from: A, to type: U.Type) -> U {
    return from as! U
}
