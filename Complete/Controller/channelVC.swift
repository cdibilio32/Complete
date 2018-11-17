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
    @IBOutlet var channelTitle: UILabel!
    @IBOutlet var channelTbl: UITableView!
    
    
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
        selectedChannel = Channel(name: "Errands", id: nil, date: Date().description)
        allChannels.removeAll()
        taskVC.allTasks.removeAll()
        let errorTaskST = Task(name: "(No Tasks Listed)", id: "Error Task", description: "Error Task", category: "Error Task", lane: "Error Task", channelID: "Error Task", userID: "Error Task", date:"Error Task")
        let errorTaskMT = Task(name: "(No Tasks Listed)", id: "Error Task", description: "Error Task", category: "Error Task", lane: "Error Task", channelID: "Error Task", userID: "Error Task", date:"Error Task")
        let errorTaskLT = Task(name: "(No Tasks Listed)", id: "Error Task", description: "Error Task", category: "Error Task", lane: "Error Task", channelID: "Error Task", userID: "Error Task", date:"Error Task")
        taskVC.allTasks["Short Term"] = [errorTaskST]
        taskVC.allTasks["Medium Term"] = [errorTaskMT]
        taskVC.allTasks["Long Term"] = [errorTaskLT]
        taskVC.updateTaskTable()
        selectedChannel = Channel(name: "Errand", id: nil, date: Date().description)
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allChannels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "channelTblCell", for: indexPath) as? channelTableViewCell {

            // Update Cell
            let channel = allChannels[indexPath.row]
            cell.updateViews(channel:channel)
            return cell
        }
        else {
            return taskTableViewCell()
        }
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
}
