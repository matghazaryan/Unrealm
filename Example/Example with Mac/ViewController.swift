//
//  ViewController.swift
//  Example with Mac
//
//  Created by Artur Mkrtchyan on 3/20/20.
//  Copyright © 2020 arturdev. All rights reserved.
//

import Cocoa
import Unrealm

class ViewController: NSViewController {

	@objc dynamic var items: [TableCellViewModel] = []

    private var results: Unrealm.Results<ToDoItem>?
    private var resultsToken: NotificationToken?

	@IBOutlet weak var tableView: NSTableView!

	override func viewDidLoad() {
		super.viewDidLoad()

		results = ToDoItem.all().sorted(byKeyPath: "id")
		resultsToken = results?.observe { [weak self] _ in
			self?.regenerateCellVMs()
        }
	}

	private func regenerateCellVMs() {
		guard let results = results else { return }
		items = Array(results).map(TableCellViewModel.init)
	}

	@IBAction func completeActions(_ sender: NSButton) {
		guard let results = results else { return }
		let row = tableView.row(for: sender)
		var item = results[row]
		item.toggleCompleted()
	}

}

