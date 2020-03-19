//
//  TableCellViewModel.swift
//  Example with Mac
//
//  Created by Artur Mkrtchyan on 3/20/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation

class TableCellViewModel: NSObject {
	@objc dynamic var id: String
	@objc dynamic var text: String
	@objc dynamic var isCompleted: Bool

	init(item: ToDoItem) {
		self.id = item.id
		self.text = item.text
		self.isCompleted = item.isCompleted
		super.init()
	}
}
