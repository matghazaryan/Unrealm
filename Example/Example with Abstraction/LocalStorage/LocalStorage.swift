//
//  LocalStorage.swift
//  Unrealm_Example
//
//  Created by Artur Mkrtchyan on 2/26/20.
//  Copyright © 2020 arturdev. All rights reserved.
//

import Foundation

public protocol StorableBase {}
public protocol Storable: StorableBase {
	static func all(in storage: LocalStorage) -> LocalStorageResults<Self>
	func store(in storage: LocalStorage)
	func delete(from storage: LocalStorage)
}

public extension Storable {
	static func all(in storage: LocalStorage) -> LocalStorageResults<Self> {
		return storage.objects(Self.self)
	}
	
	func store(in storage: LocalStorage) {
		storage.addOrUpdate(value: self)
	}
	
	func delete(from storage: LocalStorage) {
		storage.delete(value: self)
	}
}

public protocol LocalStorage {
	func addOrUpdate<T: Storable>(value: T)
	func addOrUpdate<T: Storable>(values: [T])
	func objects<T: Storable>(_ type: T.Type) -> LocalStorageResults<T>
	func object<T: Storable, KeyType>(_ type: T.Type, forPrimaryKey key: KeyType) -> T?
	func delete<T: Storable>(value: T)
	func delete<T: Storable>(values: [T])
	
	func registerStorables(_ storables:StorableBase.Type...)
}

//extension
