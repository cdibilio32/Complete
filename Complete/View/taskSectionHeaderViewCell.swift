//
//  taskSectionHeaderViewCell.swift
//  Complete
//
//  Created by Chuck Dibilio on 12/1/18.
//  Copyright © 2018 Chuck Dibilio. All rights reserved.
//

import UIKit

class taskSectionHeaderViewCell: UITableViewCell {

    // --- Outlets ---
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var addTaskSectionBtn: UIButton!
    @IBOutlet var upButton: UIButton!
    @IBOutlet var downButton: UIButton!
    
    
    
    // --- Instance Variables ---
    var category:String!
    var categoryIndex:Int!

    
    
    // --- Functions ---
    // Update Cell
    func updateCell(category:String, categoryIndex:Int) {
        self.titleLbl.text = category
        self.category = category
        self.categoryIndex = categoryIndex
    }
}
