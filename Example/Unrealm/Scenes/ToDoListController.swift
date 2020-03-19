//
//  ToDoListController.swift
//  Unrealm_Example
//
//  Created by Artur Mkrtchyan on 5/26/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import Unrealm

class ToDoListController: UITableViewController {
    
    private var items: Unrealm.Results<ToDoItem>?
    private var itemsToken: NotificationToken?
    
    // MARK: - ViewController life-cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        items = ToDoItem.all().sorted(byKeyPath: "isCompleted")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        itemsToken = items?.observe { [weak tableView] changes in
            guard let tableView = tableView else { return }
            
            switch changes {
            case .initial:
                tableView.reloadData()
            case .update(_, let deletions, let insertions, let updates):
                tableView.applyChanges(deletions: deletions, insertions: insertions, updates: updates)
            case .error: break
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        itemsToken?.invalidate()
    }
    
    // MARK: - Actions
    
    @IBAction func addItem() {
        userInputAlert("Add Todo Item") { text in
            ToDoItem.add(text: text)
        }
    }
    
    func toggleItem(_ item:inout ToDoItem) {
        item.toggleCompleted()
    }
    
    func deleteItem(_ item: ToDoItem) {
        item.delete()
    }
}

// MARK: - Table View Data Source

extension ToDoListController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? ToDoTableViewCell,
            let item = items?[indexPath.row] else {
                return ToDoTableViewCell(frame: .zero)
        }
        
        cell.configureWith(item) { [unowned self, cell] in
            guard let ip = self.tableView.indexPath(for: cell), var item = self.items?[ip.row] else {return}
            self.toggleItem(&item)
        }
        
        return cell
    }
}

// MARK: - Table View Delegate

extension ToDoListController {
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let item = items?[indexPath.row], editingStyle == .delete else { return }
        deleteItem(item)
    }
}
