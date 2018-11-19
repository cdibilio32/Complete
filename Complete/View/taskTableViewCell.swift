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
    @IBOutlet var mocCellView: UIView!
    
    
    
    
    func updateViews(task: Task) {
        // Data
        taskTitleLbl.text = task._name
        // Format
        // Border
        self.mocCellView.layer.cornerRadius = 10
    }

}
