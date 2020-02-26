//
//  Results.swift
//  Example with Abstraction
//
//  Created by Artur Mkrtchyan on 2/26/20.
//  Copyright © 2020 arturdev. All rights reserved.
//

import Foundation

public class LocalStorageResults<E: StorableBase> {
public typealias StorageResultsCollectionChangeCallback = (StorageResultsCollectionChange<LocalStorageResults<E>>) -> Void
public typealias DidObserveCallback = (@escaping StorageResultsCollectionChangeCallback) -> StorageNotificationToken?

	public var didObserveHandler: DidObserveCallback?

	public var result: Array<StorableBase>
    public init(result: Array<StorableBase>) {
        self.result = result
    }
}

//MARK: - Collection

//extension LocalStorageResults: RangeReplaceableCollection {
//	public init() {
//		result = []
//	}
//}

extension LocalStorageResults: Collection {
    public typealias Index = Int
    
    public var startIndex: Index {
        return result.startIndex
    }
    
    public var endIndex: Index {
        return result.endIndex
    }
    
    public var last: Element? {
        return result.last as? Element
    }
    
    public subscript(position: Int) -> E {
        return result[position] as! E
    }
    
    public func index(after i: Int) -> Int {
        return result.index(after: i)
    }

	public var count: Int {
		return result.count
	}
}

//MARK: - String Convertible
extension LocalStorageResults: CustomStringConvertible {
    public var description: String {
        return Array(self).map({return String(describing: $0)}).joined(separator: "\n")
    }
}

//MARK: - Sorting
extension LocalStorageResults {
	public func sorted<Value: Comparable>(by keyPath: KeyPath<E, Value>, ascending: Bool = true) -> LocalStorageResults<E>
	{
		let r = result.map({$0 as! E})
		if ascending {
			result = r.sorted(by: { $0[keyPath: keyPath]  <  $1[keyPath: keyPath] })
		} else {
			result = r.sorted(by: { $0[keyPath: keyPath]  >  $1[keyPath: keyPath] })
		}

		return self
	}

	public func sorted(by keyPath: KeyPath<E, Bool>, ascending: Bool = true) -> LocalStorageResults<E>
	{
		let r = result.map({$0 as! E})
		if ascending {
			result = r.sorted(by: { $0[keyPath: keyPath] && !$1[keyPath: keyPath] })
		} else {
			result = r.sorted(by: { !$0[keyPath: keyPath] && $1[keyPath: keyPath] })
		}

		return self
	}
}


// MARK: - Notifications
extension LocalStorageResults {
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
	public func observe(_ block: @escaping (StorageResultsCollectionChange<LocalStorageResults<E>>) -> Void) -> StorageNotificationToken? {
		return self.didObserveHandler?({[weak self] change in
			guard let self = self else { return }
			switch change {			
			case .update(let new, deletions: _, insertions: _, modifications: _):
				self.result = Array(new)
			default: break
			}
			block(change)
		})
    }
}


public enum StorageResultsCollectionChange<CollectionType> {
    /**
     `.initial` indicates that the initial run of the query has completed (if
     applicable), and the collection can now be used without performing any
     blocking work.
     */
    case initial(CollectionType)

    /**
     `.update` indicates that a write transaction has been committed which
     either changed which objects are in the collection, and/or modified one
     or more of the objects in the collection.

     All three of the change arrays are always sorted in ascending order.

     - parameter deletions:     The indices in the previous version of the collection which were removed from this one.
     - parameter insertions:    The indices in the new collection which were added in this version.
     - parameter modifications: The indices of the objects in the new collection which were modified in this version.
     */
    case update(CollectionType, deletions: [Int], insertions: [Int], modifications: [Int])

    /**
     If an error occurs, notification blocks are called one time with a `.error`
     result and an `NSError` containing details about the error. This can only
     currently happen if opening the Realm on a background thread to calcuate
     the change set fails. The callback will never be called again after it is
     invoked with a .error value.
     */
    case error(Error)
}


public class StorageNotificationToken {

	private let underlying: Any
	public var onInvalidateHandler: (() -> Void)?

	public init(_ underlying: Any) {
		self.underlying = underlying
	}

	public func invalidate() {
		onInvalidateHandler?()
	}
}
