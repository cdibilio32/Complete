//
//  taskTableViewCellVC.swift
//  Complete
//
//  Created by Chuck Dibilio on 10/5/18.
//  Copyright © 2018 Chuck Dibilio. All rights reserved.
//

import UIKit

class taskTableViewCell: UITableViewCell {
    
    // --- Outlets ---
    @IBOutlet var taskTitleLbl: UILabel!
    
    
    
    
    func updateViews(task: Task) {
        // Data
        taskTitleLbl.text = task._name
        
        // Format
        // Border
        self.layer.cornerRadius = 5
        self.layer.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }

}
