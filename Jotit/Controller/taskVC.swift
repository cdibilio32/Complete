//
//  taskVC.swift
//  Complete
//
//  Created by Chuck Dibilio on 9/23/18.
//  Copyright © 2018 Chuck Dibilio. All rights reserved.
//

import UIKit
import FirebaseDatabase

// --- Main taskVC Class ---
class taskVC: UIViewController, UITableViewDataSource, UITableViewDelegate,deleteTaskUpdate, ToLogInDelegate {
    
    // --- Outlets ---
    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet var taskTblView: UITableView!
    @IBOutlet var currentChannelLbl: UILabel!
    @IBOutlet var laneSegmentControl: UISegmentedControl!
    @IBOutlet var blackOutView: UIView!
    @IBOutlet var topConstraint: NSLayoutConstraint!
    @IBOutlet var activitySpinner: UIView!
    @IBOutlet var priorityBtn: UIButton!
    @IBOutlet var noSectionPopUp: UIView!
    @IBOutlet var noSectionPopUpBtn: UIButton!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    // --- Instance Variables ---
    // All Data For User
    var allTasks = [String:[Task]]()
    var lanes = ["To Do", "In Progress", "Complete"]
    var categories = [Category]()   

    
    // Current Selection Data and Help With Filtering
    var selectedLane:String?
    var tasksForCurrentChannel:[String:[Task]]!         // All tasks for current channel
    var tasksForCurrentChannelAndLane:[String:[Task]]! // All tasks for current channel, filtered by lane selected
    var categoriesForCurrentChannel:[Category]!        // All categories for current channel
    var selectedTask:Task?
    
    // Class to pass data to Channel vc
    var channelVC:channelVC!
    
    // Uppdated taska and categories for drag and drop
    var updateTaskRankList = [Task]()
    var updateTaskCategoryList = [Task]()
    var updateCategoryList = [Category]()
    var updateCategoryRankList = [Category]()
    
    // Bool to designate if in edit mode or not
    var priorityBtnPressed = false
    
    // Bool is loading or not
    var loading = false

    
    
    // --- Actions ---
    // Delete Category
    @objc func deleteCategory(sender:UIButton) {
        let alert = UIAlertController(title: "Are You Sure?", message: "Selecting yes will delete all tasks associated with this category.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler:  { action in
            
            // Get Category and index
            let categoryIndex = sender.tag
            let category = self.categoriesForCurrentChannel[categoryIndex]
            
            // TASKS
            let taskArray = self.allTasks[category._id!]
            for task in taskArray! {
                // Delete Task and update ranks
                self.deleteTask(task: task, updateTableWithOutLoadTable: true)
            }
            
            // CATEGORIES
            // Delete Category and update ranks
            self.deleteCategory(category: category)
            
            // Send new ranks to database
            self.uploadUpdatedCategoryRanksToDatabase()
            self.uploadUpdatedTaskRanksToDatabase()
            
            // Update Task Table
            self.updateTaskTable()
        }))
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    // Switch Section with section below it
    @objc func dropSection(sender:UIButton) {
        // Get origin and destination Categories
        let originCatIndex = sender.tag
        let destinationCatIndex = originCatIndex + 1
        var originCat = categoriesForCurrentChannel[originCatIndex]
        var destinationCat = categoriesForCurrentChannel[destinationCatIndex]
        
        // Update ranks and put into update instance variable
        // Origin
        let oldOriginRank = originCat._rank
        originCat._rank = destinationCat._rank
        updateCategoryList.append(originCat)
        increaseAllCategorieRank(oldOriginRank: oldOriginRank, originId: originCat._id!, destinationRank: destinationCat._rank)
        
        // Update table so categories are rearanged
        updateTaskTable()
    }
    
    // Switch section with section above it
    @objc func riseSection(sender:UIButton) {
        // Get origin and destination Categories
        let originCatIndex = sender.tag
        let destinationCatIndex = originCatIndex - 1
        var originCat = categoriesForCurrentChannel[originCatIndex]
        var destinationCat = categoriesForCurrentChannel[destinationCatIndex]
        
        // Update ranks and put into update instance variable
        // Origin
        let oldOriginRank = originCat._rank
        originCat._rank = destinationCat._rank
        updateCategoryList.append(originCat)
        decreaseAllCategorieRank(oldOriginRank: oldOriginRank, originId: originCat._id!, destinationRank: destinationCat._rank)
        
        // Update table so categories are rearanged
        updateTaskTable()
    }
    @IBAction func addFirstCategoryToChannel(_ sender: Any) {
        // If all channels is selected -> show error message
        if channelVC.selectedChannel._id == "allTasks" {
            let alert = UIAlertController(title: "Sorry you can't add a category to the #All channel.", message: "Please select a specific channel to add a category.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
            
            // If not allow user to create a new category
        else {
            guard let createNewTaskPopUpVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "createNewCategoryVC") as? createNewCategoryVC else {return}
            
            // Pass Data Over to Child View
            createNewTaskPopUpVC.currentChannel = channelVC.selectedChannel
            
            // Start Pop Up
            self.addChildViewController(createNewTaskPopUpVC)
            createNewTaskPopUpVC.view.frame = self.view.frame
            self.view.addSubview(createNewTaskPopUpVC.view)
            createNewTaskPopUpVC.didMove(toParentViewController: self)
        }
    }
    // Pop up to add Category when btn pressed
    @objc func addCategorToTaskTable(sender:UIButton) {
        // If all channels is selected -> show error message
        if channelVC.selectedChannel._id == "allTasks" {
            let alert = UIAlertController(title: "Sorry you can't add a category to the #All channel.", message: "Please select a specific channel to add a category.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
        
        // If not allow user to create a new category
        else {
            guard let createNewTaskPopUpVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "createNewCategoryVC") as? createNewCategoryVC else {return}
            
            // Pass Data Over to Child View
            createNewTaskPopUpVC.currentChannel = channelVC.selectedChannel
            
            // Start Pop Up
            self.addChildViewController(createNewTaskPopUpVC)
            createNewTaskPopUpVC.view.frame = self.view.frame
            self.view.addSubview(createNewTaskPopUpVC.view)
            createNewTaskPopUpVC.didMove(toParentViewController: self)
        }
    }
    
    // Pop up to add Task - in section
    @objc func addTaskInTableBtnPressed(sender:UIButton) {
        // If all channels is selected -> show error message
        if channelVC.selectedChannel._id == "allTasks" {
            let alert = UIAlertController(title: "Sorry you can't add a task to the #All channel.", message: "Please select a specific channel to add a task.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            
            self.present(alert, animated: true)
        }
            // If not allow user to create a new task
        else {
            guard let createNewTaskPopUpVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "createNewTaskPopUpID") as? createNewTaskPopUpVC else {return}
            
            // Pass Data Over to Child View
            createNewTaskPopUpVC.currentChannel = channelVC.selectedChannel
            createNewTaskPopUpVC.currentCategory = categoriesForCurrentChannel[sender.tag]._id
            
            // Start Pop Up
            self.addChildViewController(createNewTaskPopUpVC)
            createNewTaskPopUpVC.view.frame = self.view.frame
            self.view.addSubview(createNewTaskPopUpVC.view)
            createNewTaskPopUpVC.didMove(toParentViewController: self)
        }
    }
    
    
     // When User Changes Lane
    @IBAction func laneSegControlDidChange(_ sender: UISegmentedControl) {
        // Get New Lane, update tasks, reload table
        let selectedIndex = laneSegmentControl.selectedSegmentIndex
        selectedLane = lanes[selectedIndex]
//        tasksForCurrentChannelAndLane = filterTasksForCurrentLane(tasks: tasksForCurrentChannel, lane: selectedLane!)
//        taskTblView.reloadData()
        updateTaskTable()
    }
    
    // Make Table editable
    @IBAction func dragAndDropBtnPressed(_ sender: Any) {
        
        // Update Task Table to hide appropriate buttons
        updateTaskTable()
        
        // Check if user is click to start or end drag and drop (editting)
        // User Starts Editing
        if !taskTblView.isEditing {
            // Edit Button
            priorityBtn.layer.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            priorityBtn.layer.cornerRadius = 10
            priorityBtn.setTitleColor(#colorLiteral(red: 0.3294117647, green: 0.6862745098, blue: 1, alpha: 1), for: .normal)
            
            // Allow to Edit
            taskTblView.isEditing = !taskTblView.isEditing
        }
        
        // User Ends Editing
        else {
            // Save Updated Values to Database
            // For task category
            for task in updateTaskCategoryList {
                DataService.instance.updateTaskCategory(task: task)
            }
            
            // For task rank
            for task in updateTaskRankList {
                DataService.instance.updateTaskRank(task: task)
            }
            
            // For categories
            for category in updateCategoryList {
                DataService.instance.updateCategoryRank(category: category)
            }
            
            // Erase Items in update arrays
            updateTaskCategoryList.removeAll()
            updateTaskRankList.removeAll()
            updateCategoryList.removeAll()
            
            // Edit Button
            updatePriorityBtnView()
            
            // Disallow to edit
            taskTblView.isEditing = !taskTblView.isEditing
        }
        
        // Update Priority Btn Pressed
        priorityBtnPressed = !priorityBtnPressed
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    // --- Load Functions ---
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // If it is a new user need to reload data
        // Only one time - once put here change isNewUserToFalse
        debugPrint(isNewUser)
        debugPrint(loading)
        debugPrint("")
        if isNewUser && !loading {
            updateTaskTable()
        }
        
        // Deselect cell
        if let index = self.taskTblView.indexPathForSelectedRow{
            self.taskTblView.deselectRow(at: index, animated: false)
        }
        
        // Hide black out view
        blackOutView.isHidden = true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Start Activity Spinner
        let transform = CGAffineTransform(scaleX: CGFloat(2), y: CGFloat(2))
        activityIndicator.transform = transform
        activityIndicator.startAnimating()
        
        // Set table to not editting at first
        taskTblView.isEditing = false
        
        // Set Up VC to pass data to channelVC
        channelVC = self.revealViewController()?.rearViewController as? channelVC
        
        // Placeholder for current channel
        let allChannelPlaceHolder = Channel(name: "All Tasks", id: "allTasks", date: Date().description, rank:-1)
        channelVC.selectedChannel = allChannelPlaceHolder
        
        // SWViewController Swipe Right
        menuBtn.addTarget(self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)), for: .touchUpInside)
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        
        // Delegates
        // Table
        taskTblView.dataSource = self // table
        taskTblView.delegate = self   // table
        channelVC.delegate = self     // To Log In VC Delegate
        
        // Hide navigation bar
        self.navigationController?.setNavigationBarHidden(true  , animated: true)
        
        // Update View
        // Lane Segment Control font
        formatSegmentControl()
        updatePriorityBtnView()
        formatNoSectionPopUp()
        
        // Hide no category pop up
        noSectionPopUp.isHidden = true
        
        // Load All Data
        if isNewUser {
            loadApplicationData()
        }
    }
    
    
    
    
    
    
    
    
    
    

    // --- Table View Delegates ---
    // Sections
    func numberOfSections(in tableView: UITableView) -> Int {
        if categoriesForCurrentChannel == nil || categoriesForCurrentChannel.count == 0 {
            noSectionPopUp.isHidden = false
            return 0
        }
        else {
            noSectionPopUp.isHidden = true
            return categoriesForCurrentChannel.count
            
        }
    }
    
    // Height of section
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(40)
    }
    
    // Format of section
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "taskSectionHeader") as? taskSectionHeaderViewCell {
            // Update Cell
            cell.updateCell(category: categoriesForCurrentChannel[section]._name, categoryIndex: section)
            
            // Attach category section to button
            cell.addTaskSectionBtn.tag = section
            cell.upButton.tag = section
            cell.downButton.tag = section
            cell.deleteCategoryButton.tag = section
            
            // Disable UP and down buttons if at top or bottom of table
            if section == categoriesForCurrentChannel.count - 1 {
                cell.downButton.isEnabled = false
            }
            if section == 0 {
                cell.upButton.isEnabled = false
            }
            
            // Hide category up/down buttons When Priority btn not pressed
            if priorityBtnPressed {
                cell.upButton.isHidden = false
                cell.downButton.isHidden = false
                cell.deleteCategoryButton.isHidden = false
                cell.addTaskSectionBtn.isHidden = true
            }
            
            // Hide add task button if pririoty btn is pressed
            else {
                cell.upButton.isHidden = true
                cell.downButton.isHidden = true
                cell.deleteCategoryButton.isHidden = true
                cell.addTaskSectionBtn.isHidden = false
            }
            
            
            
            // Add Listener to buttons
            cell.addTaskSectionBtn.addTarget(self, action: #selector(addTaskInTableBtnPressed(sender:)), for: .touchUpInside)
            cell.upButton.addTarget(self, action: #selector(riseSection(sender:)), for: .touchUpInside)
            cell.downButton.addTarget(self, action: #selector(dropSection(sender:)), for: .touchUpInside)
            cell.deleteCategoryButton.addTarget(self, action: #selector(deleteCategory(sender:)), for: .touchUpInside)
            
            return cell
        }
        else {
            return taskSectionHeaderViewCell()
        }
    }
    
        
    // Cells
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let currentCategory = categoriesForCurrentChannel[section]._id
        let currentTaskArray = tasksForCurrentChannelAndLane[currentCategory!]
        return (currentTaskArray?.count)!
    }
    
    // Configure Cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // If there is a cell, return it
        if let cell = tableView.dequeueReusableCell(withIdentifier: "TaskTableCell", for: indexPath) as? taskTableViewCell {
            // Make Cell and return it
            let section = categoriesForCurrentChannel[indexPath.section]._id
            let tasks = tasksForCurrentChannelAndLane[section!]
            let task = tasks![indexPath.row]
        
            // Update Cell
            cell.updateViews(task: task)
            return cell
        }
        // If no cell provided return empty one
        else {
            return taskTableViewCell()
        }
    }
    
    
    // Height of cell at row - hide error cell if count > 1
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Grab Data
        let currentSection = categoriesForCurrentChannel[indexPath.section]._id
        let currentTaskArray = tasksForCurrentChannelAndLane[currentSection!]
        let currentTask = currentTaskArray![indexPath.row]
        
        if (currentTaskArray?.count)! > 1 && currentTask._id == "Error Task" {
            return CGFloat(0)
        }
        else {
            return CGFloat(45)
        }
    }
    
    // When Cell is selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedSection = categoriesForCurrentChannel[indexPath.section]._id
        
        // Make sure it is not a place holding task, if so don't do anything
        if tasksForCurrentChannel[selectedSection!] != nil {
            let tasksForSelectedSection = tasksForCurrentChannelAndLane[selectedSection!]
            selectedTask = tasksForSelectedSection?[indexPath.row]
            
            // If not error task perform segue
            if selectedTask?._id != "Error Task" {
                performSegue(withIdentifier: "taskVCToTaskDetailVC", sender: nil)
            }
        }
    }
    
    // Slide out option to delete
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            // Grab Data
            let categoryIndex = indexPath.section
            let category = self.categoriesForCurrentChannel[categoryIndex]._id
            let taskArray = self.tasksForCurrentChannelAndLane[category!]
            let task = taskArray![indexPath.row]
            
            // Delete TAsk
            self.deleteTask(task: task, updateTableWithOutLoadTable: true)
            
            // remove from table
            self.taskTblView.deleteRows(at: [indexPath], with: .fade)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {self.updateTaskTable()})

            // Update Ranks of other tasks
            self.uploadUpdatedTaskRanksToDatabase()
            
        }
        return [delete]
    }
    
    // Footer for table
    // height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == categoriesForCurrentChannel.count - 1 {
            return CGFloat(40)
        }
        else {return CGFloat(0)}
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        // Only add footer if is in last category
        if section == categoriesForCurrentChannel.count - 1 {
            // Get Cell
            if let cell = tableView.dequeueReusableCell(withIdentifier: "taskTableFooterView") as? taskTableFooterViewCell {
                // Set Up Listener for button
                cell.addCategoryBtn.addTarget(self, action: #selector(addCategorToTaskTable(sender:)), for: .touchUpInside)
                
                return cell
            }
            // If no cell provided return empty one
            else {
                return taskTableViewCell()
            }
        }
        else {return nil}
    }
    
    // Drag and Drop
    // Allow to move
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Get DAta
        let currentTaskArray = tasksForCurrentChannelAndLane![categoriesForCurrentChannel[indexPath.section]._id!]
        let currentTask = currentTaskArray![indexPath.row]
        
        // Allow only if not error task
        if currentTask._id == "ErrorTask" {
            return false
        }
        else {
            return true
        }
    }
    
    // Action when moved
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // Get source task to update rank
        var sourceTaskArray = tasksForCurrentChannelAndLane?[categoriesForCurrentChannel[sourceIndexPath.section]._id!]
        let sourceTask = sourceTaskArray![sourceIndexPath.row]
        var destinationTaskArray = tasksForCurrentChannelAndLane?[categoriesForCurrentChannel[destinationIndexPath.section]._id!]
        
        // If Cells are in same section
        if sourceIndexPath.section == destinationIndexPath.section {
            // Get Destination Task
            let destinationTask = destinationTaskArray![destinationIndexPath.row]
            
            // If Cell is moved to top of list
            let oldDestinationTaskRank = destinationTask._rank
            if sourceIndexPath.row > destinationIndexPath.row {
                for i in destinationIndexPath.row...(sourceIndexPath.row - 1) {
                    updateTaskRank(rank: sourceTaskArray![i+1]._rank, task: sourceTaskArray![i])
                }
                updateTaskRank(rank: oldDestinationTaskRank, task: sourceTaskArray![sourceIndexPath.row])
            }
            
            // If Cell is moved to bottom of list
            else {
                var i = destinationIndexPath.row
                while i > sourceIndexPath.row {
                    updateTaskRank(rank: sourceTaskArray![i - 1]._rank, task: sourceTaskArray![i])
                    i = i - 1
                }
                updateTaskRank(rank: oldDestinationTaskRank, task: sourceTaskArray![sourceIndexPath.row])
            }
        }
        
        // If Cells are in Different sections
        else {
            // If no other cells in section, just update category
            if destinationTaskArray?.count == 1 {
                // Update Category Category and reload
                updateTaskCategory(task: sourceTask, category: categoriesForCurrentChannel[destinationIndexPath.section]._id!)
            }
                
            // If there are other cells in section, update all task rank and update task category
            else {
                // Iterate to find correct rank for task
                let currentTask = sourceTaskArray!.remove(at: sourceIndexPath.row)
                var i = destinationIndexPath.row
                destinationTaskArray?.insert(currentTask, at: i)
                var needToItterate = false
                
                
                // Update array into dictionary
                tasksForCurrentChannelAndLane[categoriesForCurrentChannel[sourceIndexPath.section]._id!] = sourceTaskArray
                tasksForCurrentChannelAndLane[categoriesForCurrentChannel[destinationIndexPath.section]._id!] = destinationTaskArray
                
                
                // Change category ID in all Tasks
                updateTaskCategory(task: destinationTaskArray![i], category: categoriesForCurrentChannel[destinationIndexPath.section]._id!)
                
                // If destination task is in last row - see if need to itterate
                if i == destinationTaskArray!.count - 1 {
                    if destinationTaskArray![i]._rank < destinationTaskArray![i-1]._rank {
                        switchTaskRanks(task1: destinationTaskArray![i], task2: destinationTaskArray![i-1], section: destinationIndexPath.section, task1Index: i, task2Index: i-1)
                        i = i - 1
                        needToItterate = true
                    }
                    else { needToItterate = false }
                }
                else { needToItterate = true }
                
                // Itterate if needed
                if needToItterate {
                    // Start Iteration
                    while destinationTaskArray![i]._rank > destinationTaskArray![i+1]._rank || destinationTaskArray![i]._rank < destinationTaskArray![i-1]._rank {
                        // Move Pointer Up
                        if destinationTaskArray![i]._rank > destinationTaskArray![i+1]._rank {
                            switchTaskRanks(task1: destinationTaskArray![i], task2: destinationTaskArray![i+1], section: destinationIndexPath.section, task1Index: i, task2Index: i+1)
                            i = i + 1
                        }
                        
                        // Move Pointer down
                        else if destinationTaskArray![i]._rank < destinationTaskArray![i-1]._rank {
                            switchTaskRanks(task1: currentTask, task2: destinationTaskArray![i-1], section: destinationIndexPath.section, task1Index: i, task2Index: i-1)
                            i = i - 1
                        }
                        
                        // Break loop if i is 0 or length of destination task array
                        if i == 0 || i == destinationTaskArray!.count - 1 {
                            break
                        }
                    }
                }
            }
        }
        for task in updateTaskRankList {
            debugPrint("\(task._name): \(task._rank)")
        }
        debugPrint("")
        updateTaskTable()
    }
    
    
    
    
    
    
    
    
    
    
    // --- Helper Functions For Instance Variables ---
    // Return only categories associated with Channel
    func filterCategoriesForCurrentChannel() {
        // Store filtered categories
        var filteredCategories = [Category]()
        
        // Filter
        for cat in categories {
            if cat._channelId == channelVC.selectedChannel._id || channelVC.selectedChannel._id == "allTasks" {
                filteredCategories.append(cat)
            }
        }
        categoriesForCurrentChannel = filteredCategories
    }
    // Return only tasks associated with Channel
    func filterTasksForCurrentChannel(tasks:[String:[Task]], channel:Channel) -> [String: [Task]] {
        
        // Variable to stored filter tasks if needed
        var filteredTasks = [String:[Task]]()
        
        // Filter for Current Channel
        for (section, taskArray) in tasks{
            for task in taskArray {
                if task._channelID == channel._id || task._channelID == "Error Task" || channel._id == "allTasks"  {
                    // If section already has entry
                    if (filteredTasks.keys.contains(section)) {
                        var array = filteredTasks[section]
                        array?.append(task)
                        filteredTasks[section] = array
                    }
                    // If section not have task yet
                    else {
                        var array:[Task] = []
                        array.append(task)
                        filteredTasks[section] = array
                    }
                }
            }
        }
        return filteredTasks
    }
    
    // Return tasks only associated with Lane
    func filterTasksForCurrentLane(tasks:[String:[Task]], lane:String) -> [String:[Task]] {
        // Variable to stored filter tasks if needed
        var filteredTasks = [String:[Task]]()
        
        // Filter all tasks for lane
        for (section, taskArray) in tasks{
            for task in taskArray {
                if task._lane == lane || task._lane == "Error Task" {
                    // If section already has entry
                    if (filteredTasks.keys.contains(section)) {
                        var array = filteredTasks[section]
                        array?.append(task)
                        filteredTasks[section] = array
                    }
                        // If section not have task yet
                    else {
                        var array:[Task] = []
                        array.append(task)
                        filteredTasks[section] = array
                    }
                }
            }
        }
        return filteredTasks
    }
    
    
    
    
    
    
    // Helper Functions for Drag and Drap Rank
    // Sort Tasks By Rank
    func sortTasks() {
        for category in allTasks.keys {
            var taskArray = allTasks[category]
            taskArray?.sort(by: {$0._rank < $1._rank})
            allTasks[category] = taskArray
        }
    }
    
    // Sort Categories By Rank
    func sortCategories() {
        categories.sort(by: {$0._rank < $1._rank})
    }
    
    // Categories
    // Increase rank
    func increaseAllCategorieRank(oldOriginRank: Int, originId: String, destinationRank:Int) {
        for category in categories {
            if category._rank <= destinationRank && category._rank > oldOriginRank && category._id != originId {
                // Update in categories
                category._rank = category._rank - 1
                
                // Put in update instance variable
                updateCategoryList.append(category)
            }
        }
    }
    
    // Decrease RAnk
    // Increase rank
    func decreaseAllCategorieRank(oldOriginRank: Int, originId: String, destinationRank:Int) {
        for category in categories {
            if category._rank >= destinationRank && category._rank < oldOriginRank && category._id != originId {
                // Update in categories
                category._rank = category._rank + 1
                
                // Put in update instance variable
                updateCategoryList.append(category)
            }
        }
    }
    
    
    // ----- NEW ---_----
    // Tasks
    // Update Task Rank
    func updateTaskRank(rank: Int, task:Task) {
        var taskArray = allTasks[task._categoryId]
        let currentTaskIndex = taskArray!.firstIndex(where: {$0._id == task._id})
        let currentTask = taskArray!.remove(at: currentTaskIndex!)
        currentTask._rank = rank
        taskArray?.append(currentTask)
        allTasks[task._categoryId] = taskArray
        putTaskInUpdateTaskRankArray(task: task)
    }
    
    // Switch TAsk Ranks
    func switchTaskRanks(task1: Task, task2: Task, section: Int, task1Index:Int, task2Index:Int) {
        // Get data
        let currentCategoryId = categoriesForCurrentChannel[section]._id
        var taskArray = allTasks[currentCategoryId!]
        
        // Get two tasks indices
        let firstTaskIndex = taskArray!.firstIndex(where: {$0._id == task1._id})
        let secondTaskIndex = taskArray!.firstIndex(where: {$0._id == task2._id})
        
        // Switch Ranks
        // In All Tasks
        var tempRank = taskArray![firstTaskIndex!]._rank
        taskArray![firstTaskIndex!]._rank = taskArray![secondTaskIndex!]._rank
        taskArray![secondTaskIndex!]._rank = tempRank
        
        // Put back in all tasks
        allTasks[currentCategoryId!] = taskArray
        
        // Put in update Array
        debugPrint("above put in task array")
        putTaskInUpdateTaskRankArray(task: taskArray![firstTaskIndex!])
        putTaskInUpdateTaskRankArray(task: taskArray![secondTaskIndex!])
    }
    
    // Update category value and change order in allTasks
    func updateTaskCategory(task:Task, category:String) {
        // Get old category value
        let oldCategory = task._categoryId
        
        // Update category value
        task._categoryId = category
        
        var taskArray = allTasks[oldCategory]
        
        // Remove from old category list
        let taskInArrayIndex = taskArray!.firstIndex(where: {$0._id == task._id})
        taskArray!.remove(at: taskInArrayIndex!)
        allTasks[oldCategory] = taskArray
        
        // Insert in New category
        var taskArrayNew = allTasks[category]
        taskArrayNew?.append(task)
        allTasks[category] = taskArrayNew
        
        // Insert in array to update task category
        putTaskInUpdatedTaskCategoryArray(task: task)
    }
    
    // Put in update Arrays
    // Put task in update task Category List
    func putTaskInUpdatedTaskCategoryArray(task:Task) {
        // If there update
        if updateTaskCategoryList.contains(where: {$0._id == task._id}) {
            let taskInArrayIndex = updateTaskCategoryList.firstIndex(where: {$0._id == task._id})
            let taskInArray = updateTaskCategoryList.remove(at: taskInArrayIndex!)
            taskInArray._rank = task._rank
            updateTaskCategoryList.insert(taskInArray, at: taskInArrayIndex!)
        }
        
        // Append if not
        else {
            updateTaskCategoryList.append(task)
        }
    }
    
    // Put task in update task rank list
    func putTaskInUpdateTaskRankArray(task:Task) {
        // If it is already there, just update
        if updateTaskRankList.contains(where: {$0._id == task._id}) {
            let taskInArrayIndex = updateTaskRankList.firstIndex(where: {$0._id == task._id})
            let taskInArray = updateTaskRankList.remove(at: taskInArrayIndex!)
            taskInArray._rank = task._rank
            updateTaskRankList.insert(taskInArray, at: taskInArrayIndex!)
        }
        
        // Apend if not there yet
        else {
            updateTaskRankList.append(task)
        }
    }
    
    // Put category in update category rank list
    func putCategoryInUpdateCategoryRankArray(category:Category) {
        // If already there, update
        if updateCategoryRankList.contains(where: {$0._id == category._id}) {
            let categoryIndex = updateCategoryRankList.firstIndex(where: {$0._id == category._id})
            categories[categoryIndex!]._rank = category._rank
        }
        
        // Append if not there
        else {
            categories.append(category)
        }
    }
    
    
    // Update rank of channel, category and task if deleted helper functions
    // Task
    func updateTaskRanksForDeletionOfTask(deletedTask:Task) {
        // Find All Tasks need to Update and update in all tasks
        for (_, taskArray) in allTasks {
            for task in taskArray {
                if task._rank > deletedTask._rank {
                    task._rank = task._rank - 1
                    putTaskInUpdateTaskRankArray(task: task)
                }
            }
        }
    }
    
    // Store updated task ranks in database
    func uploadUpdatedTaskRanksToDatabase() {
        for task in updateTaskRankList {
            DataService.instance.updateTaskRank(task: task)
        }
        self.updateTaskRankList.removeAll()
    }
    
    // Category
    func updateCategoryRanksForDeletionOfCategory(deletedCategory:Category) {
        for cat in categories {
            if cat._rank > deletedCategory._rank {
                cat._rank = cat._rank - 1
                putCategoryInUpdateCategoryRankArray(category: cat)
            }
        }
    }
    
    // Store updated Category ranks in database
    func uploadUpdatedCategoryRanksToDatabase() {
        for cat in updateCategoryRankList {
            DataService.instance.updateCategoryRank(category: cat)
        }
        updateCategoryRankList.removeAll()
    }
    
    
    
    
    
    // --- Helper method for deleting tasks, category and channels ---
    // Tasks
    func deleteTask(task:Task, updateTableWithOutLoadTable:Bool) {
        // Dont do this for error task
        if task._id != "Error Task" {
            // Remove Item from instance variables
            let taskIndex = allTasks[task._categoryId]?.firstIndex(where: {$0._id == task._id})
            allTasks[task._categoryId]?.remove(at: taskIndex!)
            
            // Update Table
            if updateTableWithOutLoadTable { updateTaskTableWithoutReloadingData() }
            else { updateTaskTable() }
            
            // Update Count
            totalTaskCount = totalTaskCount - 1
            
            // Remove from database
            DataService.instance.deleteTaskForUser(task: task)
            
            // Take out of update task rank list if in list
            if updateTaskRankList.contains(where: {$0._id == task._id}) {
                let taskIndex = updateTaskRankList.firstIndex(where: {$0._id == task._id})
                updateTaskRankList.remove(at: taskIndex!)
            }
            
            
            // Update Task Ranks and put in database
            updateTaskRanksForDeletionOfTask(deletedTask: task)
        }
    }
    
    // Category
    func deleteCategory(category: Category) {
        // Update Counts
        totalCategoryCount = totalCategoryCount - 1
        
        // remove from database
        DataService.instance.deleteCategoryForUser(category: category)
        
        // remove categories from data structure
        self.categories.removeAll(where: {$0._id == category._id})
        allTasks.removeValue(forKey: category._id!)
        
        updateTaskTable()
        
        // If in update category rank, take out
        if updateCategoryRankList.contains(where: {$0._id == category._id}) {
            let categoryIndex = updateCategoryRankList.firstIndex(where: {$0._id == category._id})
            updateCategoryRankList.remove(at: categoryIndex!)
        }
        
        // Update Ranks
        self.updateCategoryRanksForDeletionOfCategory(deletedCategory: category)
    }
    
    
    
    
    // --- Helper Function for Segue ---
    // Prepare for Segue when task is selected
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Prepare with data for TaskDetailVC
        if let taskDetailVC = segue.destination as? taskDetailVC {
            if selectedTask != nil {
                taskDetailVC.delegate = self
                taskDetailVC.currentTask = selectedTask
                taskDetailVC.lanes = lanes
                taskDetailVC.allTasks = allTasks
                
                // Give Sectio Name to taskDetail
                let categoryId = selectedTask?._categoryId
                for cat in categories {
                    if cat._id == categoryId {
                        taskDetailVC.currentCategoryName = cat._name
                    }
                }
            }
        }
    }
    
    
    
    
    // --- Helper function for Table Function ---
    // Update Task and Channel for Table
    func updateTaskTable() {
        // Display catgories for current channel
        sortCategories()
        filterCategoriesForCurrentChannel()
        
        // Display Tasks associated with Current Channel
        sortTasks()
        tasksForCurrentChannel = filterTasksForCurrentChannel(tasks: allTasks, channel: channelVC.selectedChannel!)
        tasksForCurrentChannelAndLane = filterTasksForCurrentLane(tasks: tasksForCurrentChannel, lane: selectedLane!)
        
        // Populate Task Table
        taskTblView.reloadData()
    }
    
    // Update Task and Channel for Table
    func updateTaskTableWithoutReloadingData() {
        // Display Tasks associated with Current Channel
        sortTasks()
        tasksForCurrentChannel = filterTasksForCurrentChannel(tasks: allTasks, channel: channelVC.selectedChannel!)
        tasksForCurrentChannelAndLane = filterTasksForCurrentLane(tasks: tasksForCurrentChannel, lane: selectedLane!)
        
    }
    
    // Update channel label
    func updateChannelLabel() {
        currentChannelLbl.text = "#"+(channelVC.selectedChannel._name)
    }
    
    // Load data for application
    func loadApplicationData() {
        loading = true
        // --- Load All Data ---
        // Lanes
        // Get Currently Selected Lane
        let indexSelect = laneSegmentControl.selectedSegmentIndex
        selectedLane = lanes[indexSelect]
        
        // Update Channel Label
        updateChannelLabel()
        
        // Upload and listen to Channels
        DataService.instance.getAllChannelsForUser(handler: { (channel) in
            // Put in allChannels if not there already
            var inAllChannels = false
            for i in self.channelVC.allChannels {
                if i._id == channel._id {
                    inAllChannels = true
                }
            }
            if !inAllChannels {
                self.channelVC.allChannels.append(channel)
            }
        })
        
        
        
        // Categories
        DataService.instance.getAllCategoriesForUser { (category) in
            // Put categories
            var inCategories = false
            for i in self.categories {
                if i._id == category._id {
                    inCategories = true
                }
            }
            if !inCategories {
                self.categories.append(category)
                let errorTask = Task(name: "(No Tasks Listed)", id: "Error Task", description: "Error Task", categoryId: category._id!, lane: "Error Task", channelID: "Error Task", userID: "Error Task", date:"Error Task", rank:-1)
                self.allTasks = errorTask.add(toDictionary: self.allTasks)
                self.updateTaskTable()
            }
        }
        
        // Tasks
        // Upload and listen to tasks Taks
        DataService.instance.getAllTasksForUser(handler: { (currentTask) in
            
            // Add Task to allTasks
            self.allTasks = currentTask.add(toDictionary: self.allTasks)
            
            // Filter tasks and update table
            self.updateTaskTable()
            
            // Update indication spinner
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
        })
        
        // Get Total Count for Tasks
        DataService.instance.getTotalTaskCount { (count) in
            totalTaskCount = count
        }
        
        // Get Total Count for Channels
        DataService.instance.getTotalChannelCount { (count) in
            totalChannelCount = count
        }
        
        // Get Total Count for Channels
        DataService.instance.getTotalCategoryCount { (count) in
            totalCategoryCount = count
        }
        loading = false
    }
    
    
    
    
    
    
    
    // --- Helper Function For segment control view
    func formatSegmentControl() {
        let titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        UISegmentedControl.appearance().setTitleTextAttributes(titleTextAttributes, for: .normal)
        UISegmentedControl.appearance().setTitleTextAttributes(titleTextAttributes, for: .selected)
    }
    

    
    
    
    
    
    // --- Delegate Function deleteTaskUpdate ---
    // Delete task from allTasks and update table
    func deleteTaskAndUpdateTable(task: Task) {
        // Delete from taskVC
        let category = task._categoryId
        var taskArray = allTasks[category]
        var idArray = [String]()
        for task in taskArray! {
            idArray.append(task._id!)
        }
        var taskIndex = idArray.firstIndex(of: task._id!)
        taskArray!.remove(at: taskIndex!)
        allTasks[category] = taskArray
        updateTaskTable()
    }
    
    
    
    
    // --- Helper Functions for View ---
    func updatePriorityBtnView() {
        priorityBtn.backgroundColor = #colorLiteral(red: 0.1764705882, green: 0.6156862745, blue: 1, alpha: 1)
        priorityBtn.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
        priorityBtn.layer.cornerRadius = 10
        priorityBtn.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        priorityBtn.layer.borderWidth = 1
    }
    
    func formatNoSectionPopUp() {
        noSectionPopUpBtn.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        noSectionPopUpBtn.setTitleColor(#colorLiteral(red: 0.1764705882, green: 0.6156862745, blue: 1, alpha: 1), for: .normal)
        noSectionPopUpBtn.layer.cornerRadius = 10
        noSectionPopUpBtn.layer.borderColor = #colorLiteral(red: 0.1764705882, green: 0.6156862745, blue: 1, alpha: 1)
        noSectionPopUpBtn.layer.borderWidth = 1
    }
    
    
    
    
    // --- Delegate Function ToLogInVC ---
    // Push Log In VC ontop of task VC
    func toLogIn() {
        // Safe Present
        if let logInVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "logInVC") as? logInVC {
            present(logInVC, animated: true, completion: nil)
        }
    }
}
