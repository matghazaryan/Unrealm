//
//  RealmStorage.swift
//  RealmStorage
//
//  Created by Artur Mkrtchyan on 2/26/20.
//  Copyright © 2020 arturdev. All rights reserved.
//

import Foundation
import Unrealm
import Realm
import LocalStorage

public typealias Realmable = Unrealm.Realmable

extension Storable {
	static func all(in storage: LocalStorage = RealmStorage.default) -> LocalStorageResults<Self> {
		return storage.objects(Self.self)
	}
	
	func store(in storage: LocalStorage = RealmStorage.default) {
		storage.addOrUpdate(value: self)
	}
	
	func delete(from storage: LocalStorage = RealmStorage.default) {
		storage.delete(value: self)
	}
}

extension LocalStorage where Self == RealmStorage {

}

public class RealmStorage: LocalStorage {
	public static let `default` = RealmStorage()
	private init() {}

	fileprivate var config: Realm.Configuration = .defaultConfiguration
	fileprivate	lazy var realm: Realm = {
		return try! Realm(configuration: self.config)
	}()

		
	public func addOrUpdate<T>(value: T) where T : Storable {
		guard let value = value as? Realmable else { return }
		try! realm.write {
			realm.add(value, update: .all)
		}
	}
	
	public func addOrUpdate<T>(values: [T]) where T : Storable {
		values.forEach({self.addOrUpdate(value: $0)})
	}
	
	public func objects<T>(_ type: T.Type) -> LocalStorageResults<T> where T : Storable {
		guard let type = type as? Realmable.Type else { return LocalStorageResults(result: []) }
		let rlmResult = realm.anyObjectArray(type)
		let result: LocalStorageResults<T> = LocalStorageResults(result: Array(rlmResult).compactMap({$0 as? T}))
		result.didObserveHandler = { callback in
			let token = rlmResult.observe { (change) in
				switch change {
				case .initial(let results):
					let newValue = LocalStorageResults<T>(result: Array(results).compactMap({$0 as? T}))
					callback(.initial(newValue))
				case .update(let results, deletions: let deletions, insertions: let insertions, modifications: let modifications):
					let newValue = LocalStorageResults<T>(result: Array(results).compactMap({$0 as? T}))
					callback(.update(newValue, deletions: deletions, insertions: insertions, modifications: modifications))
				case .error(let error):
					callback(.error(error))
				}
			}
			let storageToken = StorageNotificationToken(token)
			storageToken.onInvalidateHandler = {
				token.invalidate()
			}
			return storageToken
		}
		return result
	}

	public func object<T, KeyType>(_ type: T.Type, forPrimaryKey key: KeyType) -> T? where T : Storable {
		guard let type = type as? Realmable.Type else { return nil }
		return realm.anyObject(type, forPrimaryKey: key) as? T
	}
	
	public func delete<T>(value: T) where T : Storable {
		guard let value = value as? Realmable else { return }
		try! realm.write({
			realm.delete(value)
		})
	}
	
	public func delete<T>(values: [T]) where T : Storable {
		values.forEach({self.delete(value: $0)})
	}
	
	public func registerStorables(_ storables: StorableBase.Type...) {
		let realmableTypes = storables.compactMap({$0 as? RealmableBase.Type})
		Realm.registerRealmables(realmableTypes)

		let objectTypes = realmableTypes.compactMap({$0.objectType()})
        let config = Realm.Configuration(fileURL: URL(fileURLWithPath: RLMRealmPathForFile("unrealm_example_abstr.realm")),
                                                      schemaVersion: 1,
                                                      migrationBlock: nil,
                                                      deleteRealmIfMigrationNeeded: true,
													  objectTypes: objectTypes)
		self.config = config
	}

	
}
