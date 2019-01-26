//
//  createNewTaskPopUpVC.swift
//  Complete
//
//  Created by Chuck Dibilio on 9/30/18.
//  Copyright © 2018 Chuck Dibilio. All rights reserved.
//

import UIKit

class createNewTaskPopUpVC: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    
    // --- Outlets ---
    @IBOutlet var taskNameTxtField: UITextField!
    @IBOutlet var taskDescriptionTxtField: UITextView!
    @IBOutlet var taskNameErrorMessage: UILabel!
    @IBOutlet var viewForLine: UIView!
    @IBOutlet var popUpView: UIView!
    @IBOutlet var bottomConstraint: NSLayoutConstraint!
    @IBOutlet var saveBtn: UIButton!
    
    
    
    // --- Instance Variables ---
    var currentCategory:String!
    var currentChannel:Channel!
    var currentLane:String!
    
    
    // --- Actions ---
    // Save New Task
    @IBAction func saveNewTask(_ sender: Any) {
        // Make sure name is provided
        if taskNameTxtField.text != "" {
            // Grab Data
            let name = taskNameTxtField.text
            var description = taskDescriptionTxtField.text
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .full
            dateFormatter.timeStyle = .full
            let date = dateFormatter.string(from: Date())

            // Create Task
            // If description was not altered, save blank
            if description == taskDescriptionPlaceHolder {
                description = ""
            }
            totalTaskCount = totalTaskCount + 1
            let task  = Task(name: name!, id: nil, description: description!, categoryId: currentCategory, lane: currentLane, channelID: currentChannel._id!, userID: userID, date: date, rank: totalTaskCount)
            
            // Add to Database
            DataService.instance.uploadTaskForUser(task: task) { (uploaded) in
                if uploaded {
                    let taskVC = self.parent as? taskVC
                    taskVC?.updateTaskTable()
                }
            }
             // BAck to task vc
            newTaskOrCategoryCreated = true
            self.closePopUp()
        }
        // Task name not provided
        else {
            taskNameErrorMessage.isHidden = false
        }
    }
    
    // Exit New Task Pop Up
    @IBAction func exitNewTaskPopUp(_ sender: Any) {
        closePopUp()
    }
    
    
    
    
    
    // --- Load Functions ---
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Delegates
        taskDescriptionTxtField.delegate = self
        taskNameTxtField.delegate = self
        
        // Display Keyboard
        taskNameTxtField.becomeFirstResponder()
        
        // Dismiss Keyboard
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        // Adjust menu to keyboard height
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)

        // Blur background VC
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        
        // Segment Controller Format
        let font = UIFont.systemFont(ofSize: 10)
        
        // Description Text Placeholder
        taskDescriptionTxtField.text = taskDescriptionPlaceHolder
        taskDescriptionTxtField.textColor = UIColor.lightGray
        
        // Task Name error message
        taskNameErrorMessage.isHidden = true
        
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
        // Set line between name and descriptions
        viewForLine.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        viewForLine.layer.borderWidth = 5
        
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
    // UITextView
    // Make Placeholder text in description
    // Began editting
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    // Stopped editting
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = taskDescriptionPlaceHolder
            textView.textColor = UIColor.lightGray
        }
    }
    
    
    // UITextField
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if !taskNameErrorMessage.isHidden {
            taskNameErrorMessage.isHidden = true
        }
    }
}
