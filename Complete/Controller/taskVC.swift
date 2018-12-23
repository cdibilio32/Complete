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
    
    // --- Instance Variables ---
    // All Data For User
    var allTasks = [String:[Task]]()
    var lanes = ["To Do", "In Progress", "Complete"]
    var categories = [Category]()
    var dballTasks = [String:[Task]]()    

    
    // Current Selection Data and Help With Filtering
    var selectedLane:String?
    var tasksForCurrentChannel:[String:[Task]]!         // All tasks for current channel
    var tasksForCurrentChannelAndLane:[String:[Task]]! // All tasks for current channel, filtered by lane selected
    var categoriesForCurrentChannel:[Category]!        // All categories for current channel
    var selectedTask:Task?
    
    // Class to pass data to Channel vc
    var channelVC:channelVC!
    
    // Tasks to update for drag and drop
    var updateTaskRankList = [Task]()
    var updateTaskCategoryList = [Task]()

    
    
    // --- Actions ---
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
            // For Categories
            for task in updateTaskCategoryList {
                DataService.instance.updateTaskCategory(task: task)
            }
            
            // For Rank
            for task in updateTaskRankList {
                DataService.instance.updateTaskRank(task: task)
            }
            
            // Erase Items in update arrays
            updateTaskCategoryList.removeAll()
            updateTaskRankList.removeAll()
            
            // Edit Button
            updatePriorityBtnView()
            
            // Disallow to edit
            taskTblView.isEditing = !taskTblView.isEditing
        }
    }
    
    
    
    
    // --- Load Functions ---
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateTaskTable()
        
        // If it is a new user need to reload data
        // Only one time - once put here change isNewUserToFalse
        if isNewUser {
            DataService.instance.removeTaskListener()
            loadApplicationData()
            isNewUser = false
        }
        
        // Hide black out view
        blackOutView.isHidden = true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set table to not editting at first
        taskTblView.isEditing = false
        
        // Set Up VC to pass data to channelVC
        channelVC = self.revealViewController()?.rearViewController as? channelVC
        
        // Placeholder for current channel
        let allChannelPlaceHolder = Channel(name: "All Tasks", id: "allTasks", date: Date().description, rank:-1)
        channelVC.selectedChannel = allChannelPlaceHolder
        channelVC.allChannels.append(allChannelPlaceHolder)
        
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
        loadApplicationData()
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
            
            // Add Listener to button
            cell.addTaskSectionBtn.addTarget(self, action: #selector(addTaskInTableBtnPressed(sender:)), for: .touchUpInside)
            
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
            
            var allTaskArray = self.allTasks[category!]
            let allTaskIndex = allTaskArray!.firstIndex(where: {$0 === task})
            let allTask = allTaskArray![allTaskIndex!]
            
            // Remove Item from instance variables
            allTaskArray!.remove(at: allTaskIndex!)
            self.allTasks[category!] = allTaskArray
            self.tasksForCurrentChannel = self.filterTasksForCurrentChannel(tasks: self.allTasks, channel: self.channelVC.selectedChannel)
            self.tasksForCurrentChannelAndLane = self.filterTasksForCurrentLane(tasks: self.tasksForCurrentChannel, lane: self.selectedLane!)
            
            totalTaskCount = totalTaskCount - 1

            // Remove from database
            DataService.instance.deleteTaskForUser(task: allTask)
            
            // remove from table
            self.taskTblView.deleteRows(at: [indexPath], with: .fade)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {self.updateTaskTable()})
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
        return true
    }
    
    // Action when moved
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // Get source task to update rank
        let sourceTaskArray = tasksForCurrentChannelAndLane?[categoriesForCurrentChannel[sourceIndexPath.section]._id!]
        let sourceTask = sourceTaskArray![sourceIndexPath.row]
        let destinationTaskArray = tasksForCurrentChannelAndLane?[categoriesForCurrentChannel[destinationIndexPath.section]._id!]
        
        
        // If switched cells in same section
        if categoriesForCurrentChannel[sourceIndexPath.section]._id! == categoriesForCurrentChannel[destinationIndexPath.section]._id! {
            // Get destination task
            let destinationTask = destinationTaskArray![destinationIndexPath.row]
            
            // Update on tasks not source or destination depends on if source is being moed up or down
            let oldSourceTaskRank = sourceTask._rank
            if sourceTask._rank > destinationTask._rank {
                // Change Rank of source task
                updateSourceRank(sourceTask: sourceTask, destinationTask: destinationTask)
                
                // Increase rank of all task if ranked higher than destination
                for (category, taskArray) in allTasks {
                    for task in taskArray {
                        if task._rank >= destinationTask._rank && task._rank < oldSourceTaskRank && task._id != sourceTask._id && task._id != "Error Task" {
                            increaseRank(task:task)
                        }
                    }
                }
            }
            
            else if sourceTask._rank < destinationTask._rank {
                // Change Rank of source task
                updateSourceRank(sourceTask: sourceTask, destinationTask: destinationTask)
                
                
                // Increase rank of all task if ranked lower than destination
                for (category, taskArray) in allTasks {
                    for task in taskArray {
                        if task._rank <= destinationTask._rank && task._rank > oldSourceTaskRank && task._id != sourceTask._id && task._id != "Error Task" {
                            decreaseRank(task: task)
                        }
                    }
                }
            }
        }
        
        // If switched cells are in different categories
        else {
            let oldSourceTaskRank = sourceTask._rank
            
            // Get Destination Task
            var destinationTask:Task!
            // If task is only one in the category, change category and put in update for category
            if destinationTaskArray?.count == 1 {
                // Update Task Category
                if  destinationIndexPath.row >= (destinationTaskArray?.count)! {
                    destinationTask = destinationTaskArray![destinationIndexPath.row - 1]
                }
                else {
                    destinationTask = destinationTaskArray![destinationIndexPath.row]
                }
                updateTaskCategory(task: sourceTask, category: destinationTask._categoryId)
                updateTaskTable()
            }
            
            // If more than one task is in section
            else {
                // If destination task is in last index of array - make destination index the last one
                if destinationTaskArray!.count <= destinationIndexPath.row {
                    destinationTask = destinationTaskArray![destinationIndexPath.row - 1]
                }
                // If not assign destinationTask to detiation index
                else {
                    destinationTask = destinationTaskArray![destinationIndexPath.row]
                }
                
                // If order does change - check to see if task goes from last row in previous section to first in next section
                if sourceTask._rank + 1 == destinationTask._rank || sourceTask._rank - 1 == destinationTask._rank {
                    // Do Nothing - Needed for else statement
                    updateTaskCategory(task: sourceTask, category: destinationTask._categoryId)
                }
                else {
                    // Update on tasks not source or destination depends on if source is being moed up or down
                    if sourceTask._rank > destinationTask._rank {
                        // Change Rank of source task
                        updateTaskCategory(task: sourceTask, category: destinationTask._categoryId)
                        updateSourceRank(sourceTask: sourceTask, destinationTask: destinationTask)
                        
                        // Increase rank of all task if ranked higher than destination
                        for (category, taskArray) in allTasks {
                            for task in taskArray {
                                if task._rank >= destinationTask._rank && task._rank < oldSourceTaskRank && task._id != sourceTask._id && task._id != "Error Task" {
                                    increaseRank(task:task)
                                }
                            }
                        }
                    }
                        
                    else if sourceTask._rank < destinationTask._rank {
                        // Change Rank of source task
                        updateTaskCategory(task: sourceTask, category: destinationTask._categoryId)
                        updateSourceRank(sourceTask: sourceTask, destinationTask: destinationTask)
                
                        // Increase rank of all task if ranked lower than destination
                        for (category, taskArray) in allTasks {
                            for task in taskArray {
                                if task._rank <= destinationTask._rank && task._rank > oldSourceTaskRank && task._id != sourceTask._id && task._id != "Error Task" {
                                    decreaseRank(task: task)
                                }
                            }
                        }
                    }
                }
            }
        }
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
    
    // Icrease Rank of task
    func increaseRank(task:Task) {
        // Update in All Tasks
        for (category, taskArray) in allTasks {
            for currentTask in taskArray {
                if currentTask._id == task._id {
                    currentTask._rank = currentTask._rank + 1
                }
            }
        }
        
        // Put Task In Update Task List to Be saved to database later
        if updateTaskRankList.contains(where: {$0._id == task._id}) {
            let taskInArrayIndex = updateTaskRankList.firstIndex(where: {$0._id == task._id})
            let taskInArray = updateTaskRankList.remove(at: taskInArrayIndex!)
            updateTaskRankList.insert(taskInArray, at: taskInArrayIndex!)
        }

        else {
            updateTaskRankList.append(task)
        }
    }
    
    // Update Rank of task
    func decreaseRank(task:Task) {
        // Update in All Tasks
        for (category, taskArray) in allTasks {
            for currentTask in taskArray {
                if currentTask._id == task._id {
                    currentTask._rank = currentTask._rank - 1
                }
            }
        }
        
        // Put Task In Update Task List to Be saved to database later
        if updateTaskRankList.contains(where: {$0._id == task._id}) {
            let taskInArrayIndex = updateTaskRankList.firstIndex(where: {$0._id == task._id})
            let taskInArray = updateTaskRankList.remove(at: taskInArrayIndex!)
            updateTaskRankList.insert(taskInArray, at: taskInArrayIndex!)
        }
            
        else {
            updateTaskRankList.append(task)
        }
    }
    
    // Update source rank
    func updateSourceRank(sourceTask:Task, destinationTask:Task) {
        for (categeory, taskArray) in allTasks {
            for task in taskArray {
                if task._id == sourceTask._id {
                    sourceTask._rank = destinationTask._rank
                    
                    // Put Source Task in UPdate Task Rank array
                    if updateTaskRankList.contains(where: {$0._id == sourceTask._id}) {
                        let taskInArrayIndex = updateTaskRankList.firstIndex(where: {$0._id == sourceTask._id})
                        let taskInArray = updateTaskRankList.remove(at: taskInArrayIndex!)
                        updateTaskRankList.insert(taskInArray, at: taskInArrayIndex!)
                    }
                        
                    else {
                        updateTaskRankList.append(sourceTask)
                    }
                }
            }
        }
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
        if updateTaskCategoryList.contains(where: {$0._id == task._id}) {
            let taskInArrayIndex = updateTaskCategoryList.firstIndex(where: {$0._id == task._id})
            let taskInArray = updateTaskCategoryList.remove(at: taskInArrayIndex!)
            updateTaskCategoryList.insert(taskInArray, at: taskInArrayIndex!)
        }
            
        else {
            updateTaskCategoryList.append(task)
        }
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
            // Put in dbCategories OR categories
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
