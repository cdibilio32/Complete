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
       taskTitleLbl.text = task._name
    }

}
