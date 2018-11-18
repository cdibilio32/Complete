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
        self.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        self.layer.borderWidth = 5
        self.layer.cornerRadius = 5
    }

}
