//
//  ToDoItem.swift
//  Unrealm_Example
//
//  Created by Artur Mkrtchyan on 5/26/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import Unrealm

struct ToDoItem: Realmable {
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

// MARK: - CRUD methods

extension ToDoItem {
    static func all(in realm: Realm = try! Realm()) -> Unrealm.Results<ToDoItem> {
        return realm.objects(ToDoItem.self)            
    }
    
    @discardableResult
    static func add(text: String, in realm: Realm = try! Realm())
        -> ToDoItem {
            let item = ToDoItem(text)
            try! realm.write {
                realm.add(item)
            }
            return item
    }
    
    mutating func toggleCompleted() {
        guard let realm = try? Realm() else { return }
        isCompleted.toggle()
        try! realm.write {
            realm.add(self, update: .all)
        }
    }
    
    func delete() {
        guard let realm = try? Realm() else { return }
        try! realm.write {
            realm.delete(self)
        }
    }
}
