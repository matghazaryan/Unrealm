//
//  ToDoTableViewCell.swift
//  Unrealm_Example
//
//  Created by Artur Mkrtchyan on 5/26/19.
//  Copyright © 2019 arturdev. All rights reserved.
//

import UIKit

class ToDoTableViewCell: UITableViewCell {
    private var onToggleCompleted: (() -> Void)?
    private var item: ToDoItem?
    
    @IBOutlet private var label: UILabel!
    @IBOutlet private var button: UIButton!
    @IBAction private func toggleCompleted() {
        guard item != nil else { fatalError("Missing Todo Item") }        
        onToggleCompleted?()
    }
    
    func configureWith(_ item: ToDoItem, onToggleCompleted: (() -> Void)? = nil) {
        self.item = item
        self.onToggleCompleted = onToggleCompleted
        
        label.attributedText = NSAttributedString(string: item.text,
                                                  attributes: item.isCompleted ? [.strikethroughStyle: true] : [:])
        button.setTitle(item.isCompleted ? "☑️": "⏺", for: .normal)
    }
}
