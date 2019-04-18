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
    func updateTaskTableFromTaskDetailVC()
}





class taskDetailVC: UIViewController, UITextViewDelegate, UITextFieldDelegate {

    // --- Outlets ---
    @IBOutlet var taskTitleLbl: UITextField!
    @IBOutlet var taskSegControlBar: UISegmentedControl!
    @IBOutlet var taskNotes: UITextView!
    @IBOutlet var errorMsg: UILabel!
    @IBOutlet var saveBtnBottomConstraint: NSLayoutConstraint!
    @IBOutlet var dateLbl: UILabel!
    @IBOutlet var headerTitle: UILabel!
    @IBOutlet var progressTitle: UILabel!
    @IBOutlet var descTitleTopConstraint: NSLayoutConstraint!
    
    @IBOutlet var navView: UIView!
    @IBOutlet var navViewTopConstraint: NSLayoutConstraint!
    @IBOutlet var navViewHeightConstraint: NSLayoutConstraint!
    
    
    // --- Instance Variables ---
    var allTasks:[String:[Task]]!
    var currentTask:Task!
    var lanes:[String]!
    var delegate:deleteTaskUpdate!
    var selectedLane:String!
    var currentCategoryName:String!
    
    
    
    
    
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
            delegate.updateTaskTableFromTaskDetailVC()
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
        
        // Push Save Button Up when keyboard appears
        NotificationCenter.default.addObserver(self, selector: #selector(pushSaveBtnAboveKeyboard(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        // Set Up delegates
        taskNotes.delegate = self
        taskTitleLbl.delegate = self
        
        // Hide Error Message
        errorMsg.isHidden = true
        
        // Update Header Title With Category
        headerTitle.text = currentCategoryName
        
        // Format and display date
        formatDate()
        
        // Format of seg controller
        formatSegmentControl()
        
        // Format navigation bar
        navigationBarFormatting()
        
        // Allow user to put links in task description
        configureTextView()
    }
    
    
    
    
    // --- Helper Functions ---
    // Keyboard
    @objc func pushSaveBtnAboveKeyboard(notification:Notification) {
        if let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue  {
            // Adjust Keyboard
            let keyboardHeight = keyboardFrame.cgRectValue.height
            saveBtnBottomConstraint.constant = keyboardHeight + CGFloat(5)
        }
        
        // Progress Items
        progressTitle.isHidden = true
        taskSegControlBar.isHidden = true
        
        // Description
        descTitleTopConstraint.constant = CGFloat(-55)
    }
    
    // Close Keyboard
    @objc func dismissKeyboard() {
        // Save Button
        saveBtnBottomConstraint.constant = CGFloat(20)
        
        // Progress Items
        progressTitle.isHidden = false
        taskSegControlBar.isHidden = false
        
        // Description
        descTitleTopConstraint.constant = CGFloat(32)
        
        // Dismiss Keyboard
        view.endEditing(true)
    }
    
    // Format Date and  Display
    // *** IN PROGRESS ***
    func formatDate() {
        // Get and translate date
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .full
        let date = dateFormatter.date(from: currentTask._date)
        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = "MM/dd/yyyy"
        let dateString = dateFormatter2.string(from: date!)
        
        // Time since today
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day]
        formatter.unitsStyle = .full
        let intervalString = formatter.string(from: date!, to: Date())
        dateLbl.text = intervalString! + " on list"
    }
    
    // Seg Controller Format
    func formatSegmentControl() {
        let titleTextAttributesWhenSelected = [NSAttributedStringKey.foregroundColor: UIColor.white]
        let titleTextAttributesWhenNotSelected = [NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.3294117647, green: 0.6862745098, blue: 1, alpha: 1)]
        UISegmentedControl.appearance().setTitleTextAttributes(titleTextAttributesWhenNotSelected, for: .normal)
        UISegmentedControl.appearance().setTitleTextAttributes(titleTextAttributesWhenSelected, for: .selected)
    }
    
    // UPdate navigation bar based on ndevice - update for
    func navigationBarFormatting() {
        if UIDevice.current.modelName.contains("iPhone10") {
            debugPrint("in iphone10")
            // Top Constraint
            navViewTopConstraint.isActive = false
            navView.topAnchor.constraint(equalTo: topLayoutGuide.topAnchor).isActive = true
            
            // Height
            navViewHeightConstraint.isActive = false
            navView.heightAnchor.constraint(equalToConstant: navView.frame.size.height + 16).isActive = true
        }
    }
    
    
    
    
    // --- URL Detection ---
    func detectURL(text:String) -> [NSTextCheckingResult] {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
        return matches
    }
    
    // Implement URL
    func implementURL(matches:[NSTextCheckingResult], taskDesription:NSMutableAttributedString) -> NSMutableAttributedString {
        for match in matches {
            taskDesription.addAttribute(.link, value: match.url, range: match.range)
        }
        return taskDesription
    }
    
    
    
    
    // --- UITextView ---
    func configureTextView() {
        // Set Up Gesture Recognizer
        var recognizer:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(taskDescriptionTapped(textViewTapped:)))
        recognizer.numberOfTapsRequired = 1
        taskNotes.addGestureRecognizer(recognizer)
    }
    @objc func taskDescriptionTapped(textViewTapped:UITapGestureRecognizer) {
        taskNotes.isEditable = true
        taskNotes.becomeFirstResponder()
    }
    
    
    
    
    
    // --- Delegate ---
    // --- UITextView ---
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
        // Add placeholder text
        if textView.text.isEmpty {
            textView.text = taskDescPHForTaskDetail
            textView.textColor = UIColor.lightGray
        }
        
        // Make uneditable when exited out
        textView.isEditable = false
    }
    
    // Is Edditing
    func textViewDidChangeSelection(_ textView: UITextView) {
        // Get Text
        let attributedString = textView.attributedText
        let mutableAttributedString = NSMutableAttributedString(attributedString: attributedString!)
        
        // Detect and embed URL
        let matches = detectURL(text: textView.text)
        let responseText = implementURL(matches: matches, taskDesription: mutableAttributedString)
        
        // Set Text with URL
        textView.attributedText = responseText
    }
    
    // Allow interaction with URL
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return true
    }
    
    
    
    
    
    // --- UITextField ----
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
