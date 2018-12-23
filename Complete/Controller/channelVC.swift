//
//  channelVC.swift
//  Complete
//
//  Created by Chuck Dibilio on 9/23/18.
//  Copyright © 2018 Chuck Dibilio. All rights reserved.
//

import UIKit
import FirebaseDatabase

protocol ToLogInDelegate {
    func toLogIn()
}

class channelVC: UIViewController, UITableViewDataSource, UITableViewDelegate, ToTaskVCFromChannelVC {
    
    // --- Outlets ---
    @IBOutlet var channelTbl: UITableView!
    @IBOutlet var searchViewContainer: UIView!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var allTasksButton: UIButton!
    
    
    // --- Instance Variables ---
    var allChannels = [Channel]()
    var selectedChannel: Channel!
    
    // Class to pass data to Task vc
    var taskVC:taskVC!
    
    // Allow log in screen to appear if logged out
    var delegate:ToLogInDelegate!
    
    
    // --- Actions ---
    // Show Pop Up to Create New Channel
    @IBAction func showCreateChannelPopUp(_ sender: Any) {
        let createNewChannelPopUpVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "createNewChannelPopUpID") as! createNewChannelPopUpVC
        
        // Assign Delegate
        createNewChannelPopUpVC.delegate = self
        self.addChildViewController(createNewChannelPopUpVC)
        createNewChannelPopUpVC.view.frame = self.view.frame
        self.view.addSubview(createNewChannelPopUpVC.view)
        createNewChannelPopUpVC.didMove(toParentViewController: self)
    }
    
    @IBAction func signOutClicked(_ sender: Any) {
        // Detach Listeners
        DataService.instance.removeChannelListener()
        DataService.instance.removeTaskListener()
        
        // Clear Data
        selectedChannel = Channel(name: "Errands", id: nil, date: Date().description, rank: -1)
        allChannels.removeAll()
        taskVC.allTasks.removeAll()
        let errorTaskST = Task(name: "(No Tasks Listed)", id: "Error Task", description: "Error Task", categoryId: "Error Task", lane: "Error Task", channelID: "Error Task", userID: "Error Task", date:"Error Task", rank:-1)
        let errorTaskMT = Task(name: "(No Tasks Listed)", id: "Error Task", description: "Error Task", categoryId: "Error Task", lane: "Error Task", channelID: "Error Task", userID: "Error Task", date:"Error Task", rank: -1)
        let errorTaskLT = Task(name: "(No Tasks Listed)", id: "Error Task", description: "Error Task", categoryId: "Error Task", lane: "Error Task", channelID: "Error Task", userID: "Error Task", date:"Error Task", rank: -1)
        taskVC.allTasks["Short Term"] = [errorTaskST]
        taskVC.allTasks["Medium Term"] = [errorTaskMT]
        taskVC.allTasks["Long Term"] = [errorTaskLT]
        taskVC.updateTaskTable()
        selectedChannel = Channel(name: "Errand", id: nil, date: Date().description, rank:-1)
        taskVC.updateChannelLabel()
        channelTbl.reloadData()
        
        // Log out
        AuthService.instance.logOffUser()
        userID = "Logged Out"
        
        // Push to Task VC so when log back in goes to correct page
        self.revealViewController()?.pushFrontViewController(taskVC, animated: true)
        
        // Show Log In Page
        delegate.toLogIn()
    }
    
    // View All Tasks Button Pressed
    @IBAction func viewAllTaksBtnPressed(_ sender: Any) {
        selectedChannel = allChannels[0]
        updateChannelDatainTaskVC()
        self.revealViewController()?.pushFrontViewController(taskVC, animated: true)
    }
    
    
    // --- Load Functions ---
    // view did appear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateChannelTable()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Determine Width of Channel VC
        self.revealViewController()?.rearViewRevealWidth = self.view.frame.size.width - 0.1*self.view.frame.size.width
        
        // Delegate for Table Views
        channelTbl.delegate = self
        channelTbl.dataSource = self
        
        // Connect to taskVC
        taskVC = self.revealViewController()?.frontViewController as? taskVC
        
        // Load Table
        updateChannelTable()
    }
    
    
    // --- Table View Delegate Functions ---
    // Sections
    // Number of Sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Height of Section
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(40)
    }
    
    // Format of Section
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "channelSectionHeader") as? channelSectionHeaderViewCell {
            
            // Update Cell
            cell.updateViews(title: "Channels")
            return cell
        }
        else {
            return channelSectionHeaderViewCell()
        }
    }
    
    // Cells
    // Numbers of Cells in Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allChannels.count
    }
    
    // Content of Cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "channelTblCell", for: indexPath) as? channelTableViewCell {

            // Update Cell
            let channel = allChannels[indexPath.row]
            cell.updateViews(channel:channel)
            return cell
        }
        else {
            return channelTableViewCell()
        }
    }
    
    // Height of Cell
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(40)
    }

    // When table item selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedChannel = allChannels[indexPath.row]
        
        // Go to taskVC
        updateChannelDatainTaskVC()
        self.revealViewController()?.pushFrontViewController(taskVC, animated: true)
    }
    
    // Slide out option to delete
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            // Grab Data
            let channelToDeleteIndex = indexPath.row
            debugPrint(channelToDeleteIndex)
            let channelToDelete = self.allChannels[channelToDeleteIndex]
            
            // Remove from instance variables
            self.allChannels.remove(at: channelToDeleteIndex)
            
            totalChannelCount = totalChannelCount - 1
            
            // Remove from database and return all tasks without tasks associated with channel
            self.taskVC.allTasks = DataService.instance.deleteChannelForUser(channel: channelToDelete, allTasks: self.taskVC.allTasks)
            
            // Remove from table
            self.channelTbl.deleteRows(at: [indexPath], with: .fade)
            
            // If current channel is deleted, change assignment to first index
            if channelToDelete._id == self.selectedChannel?._id {
                if self.allChannels.count > 0 {
                    self.selectedChannel = self.allChannels[0]
                    self.updateChannelDatainTaskVC()
                    debugPrint(self.selectedChannel._name)
                }
            }
        }
        return [delete]
    }
        
    
    // --- Helper Functions ---
    
    // Update table view
    func updateChannelTable() {
        self.channelTbl.reloadData()
    }
    
    // Update channelData in TaskVC
    func updateChannelDatainTaskVC() {
        taskVC?.updateTaskTable()
        taskVC?.updateChannelLabel()
    }
    
    
    
    
    
    // --- Define Delegate functions of ToTAskVCFromChannelVC ---
    // go to taskVC after saving channel - need to change current channel and upload new data
    func toTaskVC() {
        // go to task VC
        self.revealViewController()?.pushFrontViewController(taskVC, animated: true)
    }
    
    // Make ChannelVC Full Screen
    func blackenTaskVC() {
        taskVC.blackOutView.backgroundColor =  UIColor.black.withAlphaComponent(0.5)
        taskVC.blackOutView.isHidden = false
    }
    
    // Have ChannelVC back to normal view
    func brightenTaskVC() {
        taskVC.blackOutView.isHidden = true
    }
}
