//
//  channelTableViewCell.swift
//  Complete
//
//  Created by Chuck Dibilio on 10/9/18.
//  Copyright © 2018 Chuck Dibilio. All rights reserved.
//

import UIKit

class channelTableViewCell: UITableViewCell {
    
    // --- Outlets ---
    @IBOutlet var channelCellTitle: UILabel!
    
    
    // --- Helper Functions ---
    // Update View of Channel Cell
    func updateViews(channel: Channel) {
        channelCellTitle.text = "#"+channel._name
    }

}
