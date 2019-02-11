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

class channelVC: UIViewController, UITableViewDataSource, UITableViewDelegate, ToTaskVCFromChannelVC, UISearchBarDelegate {
    
    // --- Outlets ---
    @IBOutlet var channelTbl: UITableView!
    @IBOutlet var searchViewContainer: UIView!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var allTasksButton: UIButton!
    @IBOutlet var navView: UIView!
    @IBOutlet var navViewTopConstraint: NSLayoutConstraint!
    @IBOutlet var navViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var searchBarCenterY: NSLayoutConstraint!
    @IBOutlet var searchBarBottomContraint: NSLayoutConstraint!
    @IBOutlet var signOutBtn: UIButton!
    
    
    // --- Instance Variables ---
    var allChannels = [Channel]()
    var filteredChannels = [Channel]()
    var selectedChannel: Channel!
    let searchController = UISearchController(searchResultsController: nil)
    
    // Class to pass data to Task vc
    var taskVC:taskVC!
    
    // Allow log in screen to appear if logged out
    var delegate:ToLogInDelegate!
    
    
    // --- Actions ---
    // Subscribe user and make purchase
    @IBAction func subscribeBtnPressed(_ sender: Any) {
        debugPrint("in add action")
        PurchaseManager.instance.purchaseSubscription(renewing: "monthly", onComplete: { (success) in
            debugPrint("call back \(success)")
            if success {
                self.taskVC.bannerAdContainerHeightConstraint.constant = CGFloat(0)
            }
        })
    }
        
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
        let alert = UIAlertController(title: "Are you sure you want to leave?", message: "We would love to continue remembering everything so you do not need to!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Nah, I'll stay!", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Log Out", style: .default, handler:  { action in

            // Detach Listeners
            DataService.instance.removeChannelListener()
            DataService.instance.removeTaskListener()
            DataService.instance.removeCategoryListener()

            // Clear Data
            // Channel VC
            self.selectedChannel = Channel(name: "All Tasks", id: "allTasks", date: Date().description, rank: -1)
            self.allChannels.removeAll()

            // Task VC
            self.taskVC.allTasks.removeAll()
            let errorTaskST = Task(name: "(No Tasks Listed)", id: "Error Task", description: "Error Task", categoryId: "Error Task", lane: "Error Task", channelID: "Error Task", userID: "Error Task", date:"Error Task", rank:-1)
            let errorTaskMT = Task(name: "(No Tasks Listed)", id: "Error Task", description: "Error Task", categoryId: "Error Task", lane: "Error Task", channelID: "Error Task", userID: "Error Task", date:"Error Task", rank: -1)
            let errorTaskLT = Task(name: "(No Tasks Listed)", id: "Error Task", description: "Error Task", categoryId: "Error Task", lane: "Error Task", channelID: "Error Task", userID: "Error Task", date:"Error Task", rank: -1)
            self.taskVC.allTasks["Short Term"] = [errorTaskST]
            self.taskVC.allTasks["Medium Term"] = [errorTaskMT]
            self.taskVC.allTasks["Long Term"] = [errorTaskLT]

            // Task VC update instance variables
            self.taskVC.updateTaskRankList.removeAll()
            self.taskVC.updateTaskCategoryList.removeAll()
            self.taskVC.updateCategoryList.removeAll()
            self.taskVC.updateCategoryRankList.removeAll()
            self.taskVC.categories.removeAll()
            self.taskVC.categoriesForCurrentChannel.removeAll()

            // UPdate all data and titles
            self.taskVC.updateTaskTable()
            self.taskVC.updateChannelLabel()
            self.channelTbl.reloadData()

            // Constants
            userID = "Logged Out"
            isNewUser = false
            justLoggedIn = false

            // Log out
            AuthService.instance.logOffUser()

            // Push to Task VC so when log back in goes to correct page
            self.revealViewController()?.pushFrontViewController(self.taskVC, animated: true)

            // Show Log In Page
            self.delegate.toLogIn()
        }))
        
        alert.addAction(UIAlertAction(title: "Update to JotItt Premium", style: .default, handler: { (alert) in
            // Start Purchase
            debugPrint("in add action")
//            PurchaseManager.instance.purchaseSubscription(renewing: "monthly", onComplete: { (success) in
//                if success {
//                    self.taskVC.loadBannerView()
//                }
//            })
            // Go Too Subscription Page
            self.performSegue(withIdentifier: "toSubscribeSegue", sender: nil)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Restore Subscription", style: .default, handler: { (alert) in
            // Restore Purchase if needed
            PurchaseManager.instance.restorePurchases { (success) in
                debugPrint("restore completion: \(success)")
                if success {
                    self.taskVC.loadBannerView()
                }
            }
        }))
        
            self.present(alert, animated: true)
    }
    
    // View All Tasks Button Pressed
    @IBAction func viewAllTaksBtnPressed(_ sender: Any) {
        selectedChannel = Channel(name: "All Tasks", id: "allTasks", date: Date().description, rank: -1)
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
        
        // Delegate For Task controller
        searchBar.delegate = self
        
        // Connect to taskVC
        taskVC = self.revealViewController()?.frontViewController as? taskVC
        
        // Format navigation bar with search bar
        navigationBarFormatting()
        
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
        if !searchBarIsEmpty() {
            return filteredChannels.count
        }
        else { return allChannels.count }
    }
    
    // Content of Cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "channelTblCell", for: indexPath) as? channelTableViewCell {
            
            // Update Cell
            if !searchBarIsEmpty() {
                let channel = filteredChannels[indexPath.row]
                cell.updateViews(channel: channel, selectedChannel: selectedChannel)
                return cell
            }
            else {
                let channel = allChannels[indexPath.row]
                cell.updateViews(channel: channel, selectedChannel: selectedChannel)
                return cell
            }
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
        // Update task table to get rid of highlight
        updateChannelTable()
        
        // Return correct channel
        if !searchBarIsEmpty() {
            selectedChannel = filteredChannels[indexPath.row]
        }
        else { selectedChannel = allChannels[indexPath.row] }
        
        // Go to taskVC
        updateChannelDatainTaskVC()
        self.revealViewController()?.pushFrontViewController(taskVC, animated: true)
    }
    
    // Slide out option to delete
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            // Grab Data
            let channelToDeleteIndex = indexPath.row
            let channelToDelete:Channel!
            if !self.searchBarIsEmpty() {
                channelToDelete = self.filteredChannels[channelToDeleteIndex]
            }
            else { channelToDelete = self.allChannels[channelToDeleteIndex] }
            
            // Tasks
            // If in channel, delete and update ranks
            for (_,taskArray) in self.taskVC.allTasks {
                for task in taskArray {
                    if task._channelID == channelToDelete._id {
                        self.taskVC.deleteTask(task: task, updateTableWithOutLoadTable: false)
                    }
                }
            }
            
            // Categories
            // If in channel, delete and update ranks
            for cat in self.taskVC.categories {
                if cat._channelId == channelToDelete._id {
                    self.taskVC.deleteCategory(category: cat)
                }
            }
            
            // Channels
            // Delete Channel - update counts - change channel if current selected one
            self.deleteChannel(channelToDelete: channelToDelete, indexPath: indexPath)
            
            // Remove from database - all channel - category - task
            DataService.instance.deleteChannelForUser(channel: channelToDelete)
            
            // Update Ranks - category and task
            self.taskVC.uploadUpdatedCategoryRanksToDatabase()
            self.taskVC.uploadUpdatedTaskRanksToDatabase()
        }
        return [delete]
    }
        
    
    
    
    
    
    // --- Helper Functions ---
    
    // Sort Channels
    func sortChannels() {
        allChannels.sort(by: {$0._name < $1._name})
    }
    // Update table view
    func updateChannelTable() {
        sortChannels()
        self.channelTbl.reloadData()
    }
    
    // Update channelData in TaskVC
    func updateChannelDatainTaskVC() {
        taskVC?.updateTaskTable()
        taskVC?.updateChannelLabel()
    }
    
    func deleteChannel(channelToDelete: Channel, indexPath:IndexPath) {
        // Update Counts
        totalChannelCount = totalChannelCount - 1
        
        // Remove From Instance Variables
        if !searchBarIsEmpty() {
            filteredChannels.remove(at: indexPath.row)
            let allChannelIndex = allChannels.firstIndex(where: {$0._id == channelToDelete._id})
            allChannels.remove(at: allChannelIndex!)
        }
        else { allChannels.remove(at: indexPath.row) }
        
        // Remove from channel table
        self.channelTbl.deleteRows(at: [indexPath], with: .fade)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {self.updateChannelTable()})
        
        // If current channel is deleted, change assignment to first index
        if channelToDelete._id == self.selectedChannel?._id {
            if self.allChannels.count > 0 {
                self.selectedChannel = self.allChannels[0]
                self.updateChannelDatainTaskVC()
            }
        }
    }
    
    
    
    
    
    
    
    
    
    // --- View Helper Functions
    // UPdate navigation bar based on ndevice - update for
    func navigationBarFormatting() {
        if UIDevice.current.modelName.contains("iPhone10") {
            debugPrint("in iphone10")
            // Top Constraint
            navViewTopConstraint.isActive = false
            navView.topAnchor.constraint(equalTo: topLayoutGuide.topAnchor).isActive = true
            
            // Height
            navViewHeightConstraint.isActive = false
            navView.heightAnchor.constraint(equalToConstant: navView.frame.size.height + 28).isActive = true
            
            // Search Bar
            searchBarCenterY.isActive = false
            searchBarBottomContraint.constant = CGFloat(8)
        }
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
    
    
    
    
    
    // --- Delegate For Search Bar ---
    // Update table by text in search bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterChannelsForSearchText(searchText: searchText)
    }
    
    // Dismiss keyboard when exit search
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
    
    
    
    
    // --- Helper Functions For Search ---
    // See if search bar is empty
    func searchBarIsEmpty() -> Bool {
        return searchBar.text?.isEmpty ?? true
    }
    
    // Filter Channels for search bar
    func filterChannelsForSearchText(searchText:String) {
        filteredChannels = allChannels.filter({ (channel) -> Bool in
            return channel._name.lowercased().contains(searchText.lowercased())
        })
        updateChannelTable()
    }
}
