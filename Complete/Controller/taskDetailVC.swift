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





class taskDetailVC: UIViewController {

    // --- Outlets ---
    @IBOutlet var taskTitleLbl: UITextField!
    @IBOutlet var taskSegControlBar: UISegmentedControl!
    @IBOutlet var taskNotes: UITextView!
    
    
    
    
    
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
            updatedData["description"] = taskNotes.text
        }
        
        // Update in Database
        if currentTask.didTaskChange(byLane: selectedLane) || currentTask.didTaskChange(byName: taskTitleLbl.text!) || currentTask.didTaskChange(byDescription: taskNotes.text) {
            DataService.instance.editTask(updatedData: updatedData, taskId: currentTask._id!)
        }
        
        // Update in taskVC -> Doesn't Matter to repeat - low computation
        currentTask._name = taskTitleLbl.text!
        currentTask._description = taskNotes.text
        currentTask._lane = selectedLane
        
        // Dismiss back to taskVC
        dismiss(animated: true, completion: nil)
    }
    
    
    // --- Load Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Update Fields
        taskTitleLbl.text = currentTask._name
        taskNotes.text = currentTask._description
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
    }
    
    
    
    
    // --- Helper Functions ---
    // Close Keyboard
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
