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
    @IBOutlet var forwardLbl: UIImageView!
    
    
    
    // --- Functions ---
    func updateCell(currentTitle:String) {
        title.text = currentTitle
        
        if currentTitle == "Upgrade To Premium" || currentTitle == "Subscription Details" ||
            currentTitle == "Privacy Policy" ||
            currentTitle == "Terms and Conditions" {
            // Do NOthing
        }
        else {
            forwardLbl.isHidden = true
        }
    }
    

}
