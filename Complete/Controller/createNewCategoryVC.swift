//
//  createNewCategoryVC.swift
//  Complete
//
//  Created by Chuck Dibilio on 12/19/18.
//  Copyright © 2018 Chuck Dibilio. All rights reserved.
//

import UIKit

class createNewCategoryVC: UIViewController, UITextFieldDelegate {
    
    // --- Outlets ---
    @IBOutlet var popUpView: UIView!
    @IBOutlet var catNameField: UITextField!
    @IBOutlet var saveBtn: UIButton!
    @IBOutlet var exitBtn: UIButton!
    @IBOutlet var errorMsg: UILabel!
    @IBOutlet var bottomConstraint: NSLayoutConstraint!
    
    
    
    
    // --- Instance Variables
    var currentChannel:Channel!
    
    
    
    
    // --- Actions ---
    // Save Category Btn Pressed
    @IBAction func saveBtnPressed(_ sender: Any) {
        // Check to see if name is not empty
        if catNameField.text != "" {
            // Grab Data
            let name = catNameField.text
            let channelId = currentChannel._id
            
            // Create Category
            totalCategoryCount = totalCategoryCount + 1
            let category  = Category(name: name!, id: nil, channelId: channelId!, rank: totalCategoryCount)
            
            // Add to Database (remember gets id in dataservice function)
            DataService.instance.uploadCategoryForUser(category: category) { (uploaded, category) in
                if uploaded {
                    // Print successful and leave
                    debugPrint("Successful save of category")
                    
                    // back to task vc
                    newTaskOrCategoryCreated = true
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
            errorMsg.isHidden = false
        }
    }
    
    // Exit btn pressed
    @IBAction func exitBtnPressed(_ sender: Any) {
        closePopUp()
    }
    
    
    
    
    // --- Load Functions ---
    override func viewDidLoad() {
        super.viewDidLoad()
        // Delegates
        catNameField.delegate = self
        
        // Display Keyboard
        catNameField.becomeFirstResponder()
        
        // Dismiss Keyboard
        //*taken out for design purposes*
        //self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        // Adjust menu to keyboard height
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        // Blur background VC
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        
        // Task Name error message
        errorMsg.isHidden = true
        
        // Format view
        formatView()
    }
    
    
    
    
    // --- Helper Functions ---
    // Close out of pop up box
    func closePopUp() {
        self.view.removeFromSuperview()
    }
    
    // Format View
    func formatView() {
        // Format Pop UP View
        popUpView.layer.cornerRadius = 10
        
        // Format save button
        saveBtn.layer.cornerRadius = 10
        saveBtn.layer.borderWidth = 1
        saveBtn.layer.borderColor = #colorLiteral(red: 0.3294117647, green: 0.6862745098, blue: 1, alpha: 1)
        
    }
    
    // Keyboard Functions
    // UPdate height of menu when keyboard appears
    @objc func keyboardWillShow(notification:NSNotification) {
        updateMenuHeight(notification: notification)
    }
    
    // Dismiss Keyboard
    @objc func dismissKeyboard() {
        view.endEditing(true)
        closePopUp()
    }
    
    // Menu Functions
    // Update menu height
    func updateMenuHeight(notification: NSNotification) {
        if let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            
            // Get Values to calculate height
            let screenHeight = self.view.frame.height
            let keyboardHeight = keyboardFrame.cgRectValue.height
            let menuHeight = self.popUpView.frame.size.height
            
            let keyboardMarginHeight = (screenHeight - keyboardHeight - menuHeight)*0.5
            
            bottomConstraint.constant = keyboardHeight + 0.5*keyboardMarginHeight
        }
        
        
    }
    
    
    
    
    
    // --- Delegate ---
    // UITextField
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if !catNameField.isHidden {
            errorMsg.isHidden = true
        }
    }
}
