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
    func blackenTaskVC()
    func brightenTaskVC()
}


class createNewChannelPopUpVC: UIViewController, UITextFieldDelegate {
    // --- Outlets ---
    @IBOutlet var menuView: UIView!
    @IBOutlet var newChannelNameField: UITextField!
    @IBOutlet var channelNameErrorMsg: UILabel!
    @IBOutlet var saveBtn: UIButton!
    @IBOutlet var rightMenuConstraint: NSLayoutConstraint!
    
    @IBOutlet var bottomMenuConstraint: NSLayoutConstraint!
    
    
    
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
            totalChannelCount = totalChannelCount + 1
            let channel  = Channel(name: name!, id: nil, date: dateString, rank: totalChannelCount)
            
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
    // View Did Appear
    override func viewDidAppear(_ animated: Bool) {
        super .viewDidAppear(animated)
        delegate.blackenTaskVC()
    }
    // View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure Keyboard
        // Show Keyboard
        newChannelNameField.becomeFirstResponder()
        
        // Dismiss Keyboard
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        // Set Up Notifications for Keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        // Delegates
        newChannelNameField.delegate = self
        
        // Blur background VC
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        // Update Views
        updateMenuView()
        updateWidthMenuPositioning()
        updateSaveButton()
        
        
        // Hide Hidden Error Message
        channelNameErrorMsg.isHidden = true
    }
    
    
    
    
    
    // --- Helper Functions ---
    // Close out of pop up box
    func closePopUp() {
        delegate.brightenTaskVC()
        self.view.removeFromSuperview()
    }
    
    // Take away error message when user puts name in
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if !channelNameErrorMsg.isHidden {
            channelNameErrorMsg.isHidden = true
        }
    }
    
    
    
    
    
    // --- Keyboard ---
    // Fire When Keyboard Appears
    @objc func keyboardWillShow(notification:NSNotification) {
        updateHeightMenuPositioning(notification: notification)
    }
    
    // Fire to get rid of keyboard
    @objc func dismissKeyboard() {
        view.endEditing(true)
        closePopUp()
    }
    
    
    
    
    
    // -- Edit Views and Positioning ---
    // Update Menu View
    func updateMenuView() {
        menuView.layer.cornerRadius = 10
        menuView.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        menuView.layer.borderWidth = 1
    }
    
    // Update side to side positioning of menu
    func updateWidthMenuPositioning() {
        // Update Right Constraint
        let screenWidth = self.view.frame.size.width
        let taskVCWidth = 0.1*self.view.frame.size.width
        let menuWidth = menuView.frame.size.width
        let menuToTaskVCWidth = (screenWidth - menuWidth - 2.0*taskVCWidth)/2.0
        
        rightMenuConstraint.constant =  4.0*menuToTaskVCWidth + taskVCWidth
    }
    
    // Update vertical menu positioning
    func updateHeightMenuPositioning(notification: NSNotification) {
        // Update Bottom Constraint
        if let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue  {
            
            // Get Height Values
            let screenHeight = self.view.frame.size.height
            let keyboardHeight = keyboardFrame.cgRectValue.height
            let menuHeight = self.menuView.frame.size.height
            
            let keyboardMarginHeight = (screenHeight - keyboardHeight - menuHeight)*0.5 - 0.5*menuHeight
            bottomMenuConstraint.constant = keyboardHeight + keyboardMarginHeight
        }
    }
    
    // Update Save Button
    func updateSaveButton() {
        saveBtn.layer.cornerRadius = 10
        saveBtn.layer.borderWidth = 1
        saveBtn.layer.borderColor = #colorLiteral(red: 0.3294117647, green: 0.6862745098, blue: 1, alpha: 1)
        
    }
}
