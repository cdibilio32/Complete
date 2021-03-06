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

class channelVC: UIViewController, UITableViewDataSource, UITableViewDelegate, ToTaskVCFromChannelVC, UISearchBarDelegate, SubscriptionVCToChannelVC {
    
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
    // Show Pop Up to Create New Channel
    @IBAction func showCreateChannelPopUp(_ sender: Any) {
        // Direct user to subscription page if is not a subscriber but over channel limit
        if !UserDefaults.standard.bool(forKey: "subscriber") && totalChannelCount >= channelLimit {
            let alert = UIAlertController(title: "Channel Limit Reached", message: "You can upgrate to JotItt premium for unlimited channels or delete some of your current channels and save $0.99 per month.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "View Upgrade Options", style: .default, handler:  { action in
                self.performSegue(withIdentifier: "toSubscribeSegue", sender: nil)
            }))
            alert.addAction(UIAlertAction(title: "Nah, I'm good with basic membership.", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        }
            
        // If user is a subscriber but is over limit, have them contact team or delete channels
        else if UserDefaults.standard.bool(forKey: "subscriber") && totalChannelCount >= channelLimitWithSubscription {
            let alert = UIAlertController(title: "Safety Limit Reached", message: "You have reached the safety limit as a premium member.  Please contact the JotItt support team at this time.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Return", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            
        }
        
        // Allow User to create channel if meets limits
        else {
            let createNewChannelPopUpVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "createNewChannelPopUpID") as! createNewChannelPopUpVC
            
            // Assign Delegate
            createNewChannelPopUpVC.delegate = self
            self.addChildViewController(createNewChannelPopUpVC)
            createNewChannelPopUpVC.view.frame = self.view.frame
            self.view.addSubview(createNewChannelPopUpVC.view)
            createNewChannelPopUpVC.didMove(toParentViewController: self)
            
            // Remove ability to slide to task vc
            // enabled when channel vc does appear
            disableSlideGestures()
        }
    }
    
//    @IBAction func signOutClicked(_ sender: Any) {
//        let alert = UIAlertController(title: "Account Options", message: nil, preferredStyle: .alert)
//        
//        alert.addAction(UIAlertAction(title: "Go Back", style: .cancel, handler: nil))
//        
//        // Subscribe
//        alert.addAction(UIAlertAction(title: "Update to JotItt Premium", style: .default, handler: { (alert) in
//            // Start Purchase
//            debugPrint("in add action")
//            
//            // Go Too Subscription Page
//            self.performSegue(withIdentifier: "toSubscribeSegue", sender: nil)
//        }))
//        
//        // Restore
////        alert.addAction(UIAlertAction(title: "Restore Subscription", style: .default, handler: { (alert) in
////            self.restorePurchases()
////        }))
//        alert.addAction(UIAlertAction(title: "Log Out", style: .default, handler:  { action in
//            self.logOut()
//        }))
//        
//            self.present(alert, animated: true)
//    }
    
    // View All Tasks Button Pressed
    @IBAction func viewAllTaksBtnPressed(_ sender: Any) {
        selectedChannel = Channel(name: "All Tasks", id: "allTasks", date: Date().description, rank: -1)
        updateChannelDatainTaskVC()
        self.revealViewController()?.pushFrontViewController(taskVC, animated: true)
    }
    
    // Go to settings page
    @IBAction func settingsBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "channelVCToSettingsVC", sender: nil)
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
    
    // log out of application
    func logOut() {
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
    }
    
    // Restore purchases
//    func restorePurchases() {
//        PurchaseManager.instance.restorePurchases { (success) in
//            debugPrint("restore completion: \(success)")
//            if success {
//                self.taskVC.loadBannerView()
//            }
//            else {
//                // To Do - can't restore purchases
//                debugPrint("No purchases to restore")
//            }
//        }
//    }
    
    
    
    
    
    
    
    
    
    // --- Segue Functions ---
    // Prepare
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSubscribeSegue" {
            let destinationVC = segue.destination as! SubscriptionViewController
            destinationVC.subToChannelVCDelegate = self
            destinationVC.cameFromVC = "channelVC"
        }
        
        else if segue.identifier == "channelVCToSettingsVC" {
            let destinationVC = segue.destination as! setttingsVCViewController
            destinationVC.subToChannelVCDelegate = self
            destinationVC.cameFromVC = "channelVC"
        }
    }
    
    
    
    
    
    
    
    
    
    // --- View Helper Functions ---
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
    
    
    
    
    
    // --- Define Delegate   ---
    // --- ToTAskVCFromChannelVC ---
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
    
    
    
    
    // --- SubscriptionToChannelVC ---
    func updateBannerAds() {
        debugPrint("in update banner ads")
        self.taskVC.loadBannerView()
    }
    
    // Log out from settings -> yes it says Subscription but easier to do this than to create another protocol
    func logOutFromSettings() {
        logOut()
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
    
    
    
    
    
    
    
    
    
    // --- Helper Functions for Slide Gestures
    func disableSlideGestures() {
        self.taskVC.view.gestureRecognizers?[0].isEnabled = false
        self.taskVC.view.gestureRecognizers?[1].isEnabled = false
    }
    
    func enableSlideGestures() {
        self.taskVC.view.gestureRecognizers?[0].isEnabled = true
        self.taskVC.view.gestureRecognizers?[1].isEnabled = true
    }
}
