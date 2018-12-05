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
    
    
    
    
    // --- Instance Variables ---
    var currentCategory:String!
    var currentChannel:Channel!
    let categories = ["Short Term", "Medium Term", "Long Term"]
    
    
    // --- Actions ---
    // Save New Task
    @IBAction func saveNewTask(_ sender: Any) {
        // Make sure name is provided
        if taskNameTxtField.text != "" {
            // Grab Data
            let name = taskNameTxtField.text
            let date = Date().description
            var description = taskDescriptionTxtField.text

            // Create Task
            // If description was not altered, save blank
            if description == taskDescriptionPlaceHolder {
                description = ""
            }
            let task  = Task(name: name!, id: nil, description: description!, category: currentCategory, lane: "To Do", channelID: currentChannel._id!, userID: userID, date: date)
            
            // Add to Database
            DataService.instance.uploadTaskForUser(task: task) { (uploaded) in
                if uploaded {
                    let taskVC = self.parent as? taskVC
                    taskVC?.updateTaskTable()
                }
            }
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

        // Blur background VC
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        
        // Segment Controller Format
        let font = UIFont.systemFont(ofSize: 10)
        
        // Description Text Placeholder
        taskDescriptionTxtField.text = taskDescriptionPlaceHolder
        taskDescriptionTxtField.textColor = UIColor.lightGray
        
        // Task Name error message
        taskNameErrorMessage.isHidden = true
    }
    
    
    // --- Helper Functions ---
    // Close out of pop up box
    func closePopUp() {
        self.view.removeFromSuperview()
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
            textView.text = "Placeholder"
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
