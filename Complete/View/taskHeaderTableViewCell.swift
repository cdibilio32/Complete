//
//  taskHeaderTableViewCell.swift
//  Complete
//
//  Created by Chuck Dibilio on 11/18/18.
//  Copyright © 2018 Chuck Dibilio. All rights reserved.
//

import UIKit

class taskHeaderTableViewCell: UITableViewCell {
    
    // --- Outlets ---
    @IBOutlet var sectionTitle: UILabel!
    
    // Update Section Header Format
    func updateSection(title:String) {
        // Data
        sectionTitle.text = title
        
        // Format
        self.layer.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.9607843137, blue: 0.968627451, alpha: 1)
        
        
    }

}
