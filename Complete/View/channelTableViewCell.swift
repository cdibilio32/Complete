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
    @IBOutlet var formatView: UIView!
    
    // Instance Variable
    var cellHighlighted = false
    
    
    // --- Helper Functions ---
    // Update View of Channel Cell
    func updateViews(channel: Channel, selectedChannel:Channel) {
        channelCellTitle.text = channel._name
        
        
        // If Current selected celll highlight
        if selectedChannel._id == channel._id {
            self.channelCellTitle.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            self.formatView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            self.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            cellHighlighted = true
        }
        
        // If was selected cell but not anymore put correct color background
        if cellHighlighted && selectedChannel._id != channel._id {
            self.channelCellTitle.backgroundColor = #colorLiteral(red: 0.3294117647, green: 0.6862745098, blue: 1, alpha: 1)
            self.formatView.backgroundColor = #colorLiteral(red: 0.3294117647, green: 0.6862745098, blue: 1, alpha: 1)
            self.backgroundColor = #colorLiteral(red: 0.3294117647, green: 0.6862745098, blue: 1, alpha: 1)
            cellHighlighted = false
        }
    }
}
