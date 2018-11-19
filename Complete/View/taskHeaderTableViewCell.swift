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
        self.clipsToBounds = false
        
    }

}
