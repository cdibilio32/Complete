//
//  UpgradeTableViewCell.swift
//  Complete
//
//  Created by Chuck Dibilio on 2/18/19.
//  Copyright © 2019 Chuck Dibilio. All rights reserved.
//

import UIKit

class UpgradeTableViewCell: UITableViewCell {
    
    // --- Outlets ---
    @IBOutlet var upgradeBtn: UIButton!
    
    
    
    
    
    // --- Actions ---
    @IBAction func upgradeBtnPressed(_ sender: Any) {
    }
    
    
    
    
    // --- Functions ---
    func updateCell() {
        upgradeBtn.layer.cornerRadius = 10
    }
    
    
}
