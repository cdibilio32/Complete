//
//  taskDetailVC.swift
//  Complete
//
//  Created by Chuck Dibilio on 9/30/18.
//  Copyright © 2018 Chuck Dibilio. All rights reserved.
//

import UIKit



// --- Protocol declaration to delte task ---
protocol deleteTaskUpdate {
    func deleteTaskAndUpdateTable(task:Task)
}





class taskDetailVC: UIViewController, UITextViewDelegate, UITextFieldDelegate {

    // --- Outlets ---
    @IBOutlet var taskTitleLbl: UITextField!
    @IBOutlet var taskSegControlBar: UISegmentedControl!
    @IBOutlet var taskNotes: UITextView!
    @IBOutlet var errorMsg: UILabel!
    
    @IBOutlet var dateLbl: UILabel!
    
    @IBOutlet var headerTitle: UILabel!
    
    
    // --- Instance Variables ---
    var allTasks:[String:[Task]]!
    var currentTask:Task!
    var lanes:[String]!
    var delegate:deleteTaskUpdate!
    var selectedLane:String!
    
    
    
    
    
    // --- Actions ---
    // When Segmentation Control Changed
    @IBAction func segControlChanged(_ sender: UISegmentedControl) {
        let selectedIndex = taskSegControlBar.selectedSegmentIndex
        selectedLane = lanes[selectedIndex]
    }
    // Back Button Pressed
    @IBAction func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    // Save Button Pressed
    @IBAction func saveBtnPressed(_ sender: Any) {
        if taskTitleLbl.text != "" {
            // If task changed - Put in Dict to send to database and send
            var updatedData = [String:String]()
            
            // By Lane
            if currentTask.didTaskChange(byLane: selectedLane) {
                updatedData["lane"] = selectedLane
            }
            
            // By Name
            if currentTask.didTaskChange(byName: taskTitleLbl.text!) {
                updatedData["name"] = taskTitleLbl.text
            }
            
            // By Description
            if currentTask.didTaskChange(byDescription: taskNotes.text) {
                if taskNotes.text == taskDescPHForTaskDetail {
                    updatedData["description"] = ""
                }
                else {
                    updatedData["description"] = taskNotes.text
                }
            }
            
            // Update in Database
            if currentTask.didTaskChange(byLane: selectedLane) || currentTask.didTaskChange(byName: taskTitleLbl.text!) || currentTask.didTaskChange(byDescription: taskNotes.text) {
                DataService.instance.editTask(updatedData: updatedData, taskId: currentTask._id!)
            }
            
            // Update in taskVC -> Doesn't Matter to repeat - low computation
            currentTask._name = taskTitleLbl.text!
            currentTask._lane = selectedLane
            if taskNotes.text == taskDescPHForTaskDetail {
                currentTask._description = ""
            }
            else {
                currentTask._description = taskNotes.text
            }
            
            // Dismiss back to taskVC
            dismiss(animated: true, completion: nil)
        }
        else {
            errorMsg.isHidden = false
        }
    }
    
    
    // --- Load Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Update Fields
        taskTitleLbl.text = currentTask._name
        if currentTask._description.isEmpty {
            taskNotes.text = taskDescPHForTaskDetail
            taskNotes.textColor = UIColor.lightGray
        }
        else {
            taskNotes.text = currentTask._description
        }
        
        if currentTask._lane == "To Do" {
            taskSegControlBar.selectedSegmentIndex = 0
            selectedLane = lanes[taskSegControlBar.selectedSegmentIndex]
        }
        else if currentTask._lane == "In Progress" {
            taskSegControlBar.selectedSegmentIndex = 1
            selectedLane = lanes[taskSegControlBar.selectedSegmentIndex]
        }
        else {
            taskSegControlBar.selectedSegmentIndex = 2
            selectedLane = lanes[taskSegControlBar.selectedSegmentIndex]
        }
        
        // Disable Keyboard When User clicks out of it
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        // Set Up delegates
        taskNotes.delegate = self
        taskTitleLbl.delegate = self
        
        // Hide Error Message
        errorMsg.isHidden = true
        
        // Update Header Title With Category
        headerTitle.text = currentTask._catgory
        
        // Format and display date
        formatDate()
        
        // Format of seg controller
        formatSegmentControl()
    }
    
    
    
    
    // --- Helper Functions ---
    // Close Keyboard
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // Format Date and  Display
    // *** IN PROGRESS ***
    func formatDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let date = dateFormatter.date(from: currentTask._date)
        //dateLbl.text = date?.description
    }
    
    // Seg Controller Format
    func formatSegmentControl() {
        let titleTextAttributesWhenSelected = [NSAttributedStringKey.foregroundColor: UIColor.white]
        let titleTextAttributesWhenNotSelected = [NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.3294117647, green: 0.6862745098, blue: 1, alpha: 1)]
        UISegmentedControl.appearance().setTitleTextAttributes(titleTextAttributesWhenNotSelected, for: .normal)
        UISegmentedControl.appearance().setTitleTextAttributes(titleTextAttributesWhenSelected, for: .selected)
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
            textView.text = taskDescPHForTaskDetail
            textView.textColor = UIColor.lightGray
        }
    }
    
    // UITextField
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if !errorMsg.isHidden {
            errorMsg.isHidden = true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text == "" {
            textField.placeholder = "Task Name"
        }
    }
}
