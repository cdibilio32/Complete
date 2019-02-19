//
//  SettingsHeaderTableViewCell.swift
//  Complete
//
//  Created by Chuck Dibilio on 2/17/19.
//  Copyright © 2019 Chuck Dibilio. All rights reserved.
//

import UIKit

class SettingsHeaderTableViewCell: UITableViewCell {

    // --- Outlets ---
    @IBOutlet var title: UILabel!
    
    // --- Functions ---
    // Update cell
    func updateCell(currentTitle:String) {
        title.text = currentTitle
    }
}
