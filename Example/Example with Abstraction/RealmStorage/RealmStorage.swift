//
//  RealmStorage.swift
//  RealmStorage
//
//  Created by Artur Mkrtchyan on 2/26/20.
//  Copyright © 2020 arturdev. All rights reserved.
//

import Foundation
import Unrealm
import LocalStorage

public typealias Realmable = Unrealm.Realmable

extension Storable {
	static func all(in storage: LocalStorage = RealmStorage.default) -> StorageResults<Self> {
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
	func objects<T: Storable & Realmable>(_ type: T.Type) -> StorageResults<T> {
		let rlmResult = self.realm.objects(T.self)
		let result: StorageResults<T> = StorageResults(result: Array(rlmResult))		
		return result
	}
}

public class RealmStorage: LocalStorage {
	public static let `default` = RealmStorage()
	private init() {}
	fileprivate let realm = try! Realm()
		
	public func addOrUpdate<T>(value: T) where T : Storable {
		guard let value = value as? Realmable else { return }
		try! realm.write {
			realm.add(value)
		}
	}
	
	public func addOrUpdate<T>(values: [T]) where T : Storable {
		values.forEach({self.addOrUpdate(value: $0)})
	}
	
	public func objects<T>(_ type: T.Type) -> StorageResults<T> where T : Storable {
		guard let type = type as? Realmable.Type else { return StorageResults(result: []) }
		return StorageResults(result: Array(realm.anyObjectArray(type).compactMap({$0 as? T})))
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
		Realm.registerRealmables(storables.compactMap({$0 as? RealmableBase.Type}))
	}
}
