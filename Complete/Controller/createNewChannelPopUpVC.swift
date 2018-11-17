//
//  createNewChannelPopUpVC.swift
//  Complete
//
//  Created by Chuck Dibilio on 9/29/18.
//  Copyright © 2018 Chuck Dibilio. All rights reserved.
//

import UIKit

protocol ToTaskVCFromChannelVC {
    func toTaskVC()
}

class createNewChannelPopUpVC: UIViewController, UITextFieldDelegate {
    // --- Outlets ---
    @IBOutlet var newChannelNameField: UITextField!
    @IBOutlet var channelNameErrorMsg: UILabel!
    
    
    
    
    // --- Instance Variables ---
    var delegate:ToTaskVCFromChannelVC!
    
    
    
    
    // --- Actions ---
    // Exit Create New Channel Pop Up
    @IBAction func exitCreateNewChannelPopUp(_ sender: Any) {
        closePopUp()
    }
    
    @IBAction func saveNewChannel(_ sender: Any) {
        
        // Check to see if name is not empty
        if newChannelNameField.text != "" {
            // Grab Data
            let name = newChannelNameField.text
            let date = Date()
            let dateString = date.description
           
            // Create Channel
            let channel  = Channel(name: name!, id: nil, date: dateString)
            
            // Add to Database (remember gets id in dataservice function)
            DataService.instance.uploadChannelForUser(channel: channel) { (uploaded, returnedChannel) in
                if uploaded {
                    // Add to All tasks
                    let channelVC = self.parent as? channelVC
                    channelVC?.allChannels.append(returnedChannel)
                    channelVC?.updateChannelTable()
                    
                    // Update current channel and transition to allTasks
                    channelVC?.selectedChannel = returnedChannel
                    channelVC?.taskVC.updateChannelLabel()
                    channelVC?.taskVC.updateTaskTable()
                    self.delegate.toTaskVC()
                    self.closePopUp()
                }
                else {
                    // NEED TO HAVE ERROR MESSAGE
                    debugPrint("Channel Did Not Save.")
                }
            }
        }
        // If name is empty
        else {
            channelNameErrorMsg.isHidden = false
        }
    }
    
    
    // --- Load Functions ---
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Delegates
        newChannelNameField.delegate = self
        
        // Blur background VC
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        
        // Hide Hidden Error Message
        channelNameErrorMsg.isHidden = true
    }
    
    
    // --- Helper Functions ---
    // Close out of pop up box
    func closePopUp() {
        self.view.removeFromSuperview()
    }
    
    // Take away error message when user puts name in
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if !channelNameErrorMsg.isHidden {
            channelNameErrorMsg.isHidden = true
        }
    }
    
}
