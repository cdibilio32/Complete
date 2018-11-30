//
//  channelSectionHeaderViewCell.swift
//  Complete
//
//  Created by Chuck Dibilio on 11/30/18.
//  Copyright © 2018 Chuck Dibilio. All rights reserved.
//

import UIKit

class channelSectionHeaderViewCell: UITableViewCell {

    // --- Outlets ---
    @IBOutlet var channelSectionCellTitle: UILabel!
    
    
    // --- Helper Functions
    func updateViews(title: String) {
        channelSectionCellTitle.text = title
    }

}
