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
    @IBOutlet var notesTextView: UITextView!
    @IBOutlet var taskTitleLbl: UILabel!
    @IBOutlet var taskSegControlBar: UISegmentedControl!
    @IBOutlet var taskNotes: UITextView!
    
    
    
    
    
    // --- Instance Variables ---
    var allTasks:[String:[Task]]!
    var currentTask:Task!
    var lanes:[String]!
    var delegate:deleteTaskUpdate!
    
    
    
    
    
    // --- Actions ---
    // When Segmentation Control Changed
    @IBAction func segControlChanged(_ sender: UISegmentedControl) {
        let selectedIndex = taskSegControlBar.selectedSegmentIndex
        let selectedLane = lanes[selectedIndex]
    }
    // Back Button Pressed
    @IBAction func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    // Save Button Pressed
    @IBAction func saveBtnPressed(_ sender: Any) {
        // If task changed
        let currentLane = lanes[taskSegControlBar.selectedSegmentIndex]
        if currentTask.didTaskChange(lane: currentLane, description: taskNotes.text) {
            var updatedData = ["lane": currentLane,
                               "description":taskNotes.text] as [String : Any]
            // Update in Database
            DataService.instance.editTask(updatedData: updatedData, taskId: currentTask._id!)
            
            // Update in taskVC
            currentTask._description = taskNotes.text
            currentTask._lane = currentLane
        }
        
        // Dismiss back to taskVC
        dismiss(animated: true, completion: nil)
    }
    // Delete Button Pressed
    @IBAction func delteBtnPressed(_ sender: Any) {
        // Delete from database
        DataService.instance.deleteTaskForUser(task: currentTask)
        
        // Delegate - delete from taskVC
        delegate.deleteTaskAndUpdateTable(task: currentTask)
        
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
    // --- Load Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Put border around Note Text Field
        self.notesTextView.layer.borderColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        self.notesTextView.layer.borderWidth = CGFloat(Float(1.0))
        
        // Update Fields
        taskTitleLbl.text = currentTask._name
        taskNotes.text = currentTask._description
        if currentTask._lane == "To Do" {
            taskSegControlBar.selectedSegmentIndex = 0
        }
        else if currentTask._lane == "In Progress" {
            taskSegControlBar.selectedSegmentIndex = 1
        }
        else {
            taskSegControlBar.selectedSegmentIndex = 2
        }
    }
}
