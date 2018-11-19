//
//  taskSectionHeaderFooterView.swift
//  Complete
//
//  Created by Chuck Dibilio on 11/19/18.
//  Copyright © 2018 Chuck Dibilio. All rights reserved.
//

import UIKit

class taskSectionHeaderFooterView: UIView {

    // --- Outlets ---
    @IBOutlet var sectionTitle: UILabel!
    
    
    
    
    
    // --- Functions ---
    func updateSection(title:String) {
        // Text
        self.sectionTitle.text = title
    }
    
}
