//
//  LogOutTableViewCell.swift
//  Complete
//
//  Created by Chuck Dibilio on 2/18/19.
//  Copyright © 2019 Chuck Dibilio. All rights reserved.
//

import UIKit

class LogOutTableViewCell: UITableViewCell {

    // --- Outlets ---
    @IBOutlet var logOutBtn: UIButton!
    
    
    
    
    
    // --- Actions ---
    @IBAction func logOutBtnPressed(_ sender: Any) {
    }
    
    
    
    
    // --- Functions ---
    func updateCell() {
        logOutBtn.layer.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        logOutBtn.layer.cornerRadius = 10
    }
    
    
}
