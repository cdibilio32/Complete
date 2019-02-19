//
//  SettingsCellTableViewCell.swift
//  Complete
//
//  Created by Chuck Dibilio on 2/17/19.
//  Copyright © 2019 Chuck Dibilio. All rights reserved.
//

import UIKit

class SettingsCellTableViewCell: UITableViewCell {

    // --- Outlets ---
    @IBOutlet var title: UILabel!
    
    
    
    
    // --- Functions ---
    func updateCell(currentTitle:String) {
        title.text = currentTitle
    }
    

}
