//
//  WindowController.swift
//  Example with Mac
//
//  Created by Artur Mkrtchyan on 3/20/20.
//  Copyright © 2020 arturdev. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {

	@IBAction func addTapped(_ sender: Any) {
		let alert = NSAlert()
		alert.messageText = "Please enter a value"
		alert.addButton(withTitle: "Save")
		alert.addButton(withTitle: "Cancel")

		let inputTextField = NSTextField(frame: NSRect(x: 0, y: 0, width: 300, height: 24))
		inputTextField.placeholderString = "Enter text"
		alert.accessoryView = inputTextField
		alert.beginSheetModal(for: NSApp.keyWindow!) { (modalResponse) in
			if modalResponse == .alertFirstButtonReturn {
				let text = inputTextField.stringValue
				ToDoItem.add(text: text)
			}
		}
	}

}
