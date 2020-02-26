//
//  ToDoItem.swift
//  Example with Abstraction
//
//  Created by Artur Mkrtchyan on 2/26/20.
//  Copyright © 2020 arturdev. All rights reserved.
//

import Foundation
import LocalStorage

struct ToDoItem: Storable {
    var id = UUID().uuidString
    var text = ""
    var isCompleted = false
    
    static func primaryKey() -> String? {
        return "id"
    }
}

extension ToDoItem {
    init(_ text: String) {
        self.text = text
    }
}

extension ToDoItem {

    @discardableResult
    static func add(text: String, in storage: LocalStorage) -> ToDoItem {
		let item = ToDoItem(text)
		storage.addOrUpdate(value: item)
		return item
    }

	mutating func toggleCompleted(in storage: LocalStorage) {
        isCompleted.toggle()
		storage.addOrUpdate(value: self)
    }
}
