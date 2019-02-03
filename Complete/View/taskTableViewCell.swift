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
        if task._id == "Error Task" {
            self.mocCellView.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.9607843137, blue: 0.968627451, alpha: 1)
            self.mocCellView.layer.borderWidth = 0
            self.taskTitleLbl.textColor = #colorLiteral(red: 0, green: 0.5333333333, blue: 1, alpha: 1)
        }
        else {
        // Border
        self.taskTitleLbl.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        self.mocCellView.layer.cornerRadius = 10
        self.mocCellView.layer.borderWidth = 0.2
        self.mocCellView.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        self.mocCellView.layer.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
    }

}
