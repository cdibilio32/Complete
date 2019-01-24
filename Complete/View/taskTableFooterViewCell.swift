//
//  taskTableFooterViewCell.swift
//  Complete
//
//  Created by Chuck Dibilio on 12/19/18.
//  Copyright © 2018 Chuck Dibilio. All rights reserved.
//

import UIKit

class taskTableFooterViewCell: UITableViewCell {
    
    // --- Outlets ---
    @IBOutlet var addCategoryBtn: UIButton!
    
    func formatView() {
        addCategoryBtn.layer.borderWidth = 1
        addCategoryBtn.layer.borderColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        addCategoryBtn.layer.cornerRadius = 10
        addCategoryBtn.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }
    
}
