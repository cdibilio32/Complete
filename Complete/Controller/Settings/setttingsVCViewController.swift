//
//  setttingsVCViewController.swift
//  Complete
//
//  Created by Chuck Dibilio on 2/17/19.
//  Copyright © 2019 Chuck Dibilio. All rights reserved.
//

import UIKit

class setttingsVCViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // --- Outlets ---
    @IBOutlet var navHeader: UIView!
    @IBOutlet var table: UITableView!
    @IBOutlet var navView: UIView!
    @IBOutlet var navViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var navViewTopConstraint: NSLayoutConstraint!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var container: UIView!
    
    
    
    
    // --- Instance Variables ---
    var tableData:[String:[String]]!
    var sections:[String]!
    var selectedRow:String?
    var subToChannelVCDelegate:SubscriptionVCToChannelVC!
    var cameFromVC:String!
    
    
    
    
    // --- Actions ---
    // Go back to channel VC
    @IBAction func backBtnPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    // To Upgrade Page
    @IBAction func upgradeBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "settingsToSubscriptionVC", sender: nil)
    }
    
    // Log Out
    @IBAction func logOutBtnPressed(_ sender: Any) {
        // Need to erase data
        subToChannelVCDelegate.logOutFromSettings()
    }
    
    
    
    
    
    // --- Load functions ---
    override func viewDidLoad() {
        super.viewDidLoad()

        // Delegates
        table.delegate = self
        table.dataSource = self
        
        // Set up Data for Table
        setUpDataForTable()
        navigationBarFormatting()
        
        // Views
        formatActivityIndicatorView()
    }
    
    
    
    
    
    
    
    
    
    
    // --- Delegates Functions ---
    // --- Table View Delegates ---
    // --- Sections ---
    // Total Sections
    func numberOfSections(in tableView: UITableView) -> Int {
        let NUMBER_OF_SECTIONS = 4
        return NUMBER_OF_SECTIONS
    }
    
    // Height of section
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let sectionId = sections[section]
        
        if sectionId == "Upgrade" {
            return CGFloat(100)
        }
        else if sectionId == "Log Out" {
            return CGFloat(100)
        }
        else if sectionId == "Subscription" {
            return CGFloat(30)
        }
        else {
            return CGFloat(55.5)
        }
    }
    
    // Return Section
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionId = sections[section]
        
        if sectionId == "Upgrade" {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "Upgrade") as? UpgradeTableViewCell {
                cell.updateCell()
                
                return cell
            }
            else {
                return UpgradeTableViewCell()
            }
        }
        
        else if sectionId == "Log Out" {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "LogOut") as? LogOutTableViewCell {
                cell.updateCell()
                
                return cell
            }
            else {
                return LogOutTableViewCell()
            }
        }
        
        else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "settingHeader") as? SettingsHeaderTableViewCell {
                // Update Cell
                let title = sections[section]
                cell.updateCell(currentTitle: title)
                
                return cell
            }
            else {
                return SettingsCellTableViewCell()
            }
        }
    }
    
    
    
    // --- Cells ---
    // Number of cells in section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let currentSection = sections[section]
        
        // Upgrade and log out cells
        if currentSection == "Log Out" || currentSection == "Upgrade" {
            return 0
        }
        // normal header cells
        else {
            let options = tableData[currentSection]
            return (options?.count)!
        }
    }
    
    // Height of cell
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let ROW_HEIGHT = CGFloat(55)
        return ROW_HEIGHT
    }
    
    // Return Cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell") as? SettingsCellTableViewCell {
            // Update Cell
            let options = tableData[sections[indexPath.section]]
            let title = options![indexPath.row]
            cell.updateCell(currentTitle: title)
            
            return cell
        }
        else {
            return SettingsCellTableViewCell()
        }
    }
    
    // When Row is selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sectionId = sections[indexPath.section]
        let rowArray = tableData[sectionId]
        let rowId = rowArray![indexPath.row]
        
        // Go to upgrade page
        if rowId == "Upgrade To Premium" {
            performSegue(withIdentifier: "settingsToSubscriptionVC", sender: nil)
        }
        
        // Go to LegalVC (display text page
        else if rowId == "Subscription Details" || rowId == "Privacy Policy" || rowId == "Terms and Conditions" {
            selectedRow = rowId
            performSegue(withIdentifier: "toLegalVC", sender: nil)
        }
        
        // Restore Purchases
        else {
            restorePurchases()
        }
    }
    
    
    
    
    
    
    
    
    
    // --- Helper Functions ---
    // --- Segue ---
    // Prepare
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toLegalVC" {
            let destinationVC = segue.destination as! LegalVC
            destinationVC.sectionTitle = selectedRow!
        }
        
        else if segue.identifier == "settingsToSubscriptionVC" {
            let destinationVC = segue.destination as! SubscriptionViewController
            destinationVC.subToChannelVCDelegate = subToChannelVCDelegate
            destinationVC.cameFromVC = cameFromVC
        }
    }
    
    
    
    
    
    
    // --- Purchases ---
    // Restore Purchase if needed
    func restorePurchases() {
        PurchaseManager.instance.restorePurchases(activityIndicator: activityIndicator, activityContainer: container, onComplete: { (success) in
            debugPrint("restore completion: \(success)")
            if success {
                // Reactive Subsciption
                self.subToChannelVCDelegate.updateBannerAds()
                
                // Show alert to user
                let alert = UIAlertController(title: "Subscription Restored", message: "Enjoy your premium subscription and peace of mind that comes with it!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            }
            else {
                // Tell User Purchase Is Not there
                debugPrint("No purchases to restore")
                let alert = UIAlertController(title: "Subscription Not Restored", message: "We are sorry but we could not find your subscription.  If you believe this is an error, please try again or contact the JotItt support team.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            }
        })
    }
    
    
    
    

    // --- Table View ---
    // DAta For table
    func setUpDataForTable() {
        // Table Cells
        let subOptions = ["Upgrade To Premium",
                          "Subscription Details",
                          "Restore Subscription"]
        let legalOptions = ["Privacy Policy",
                            "Terms and Conditions"]
        
        sections = ["Upgrade", "Subscription", "Legal", "Log Out"]
        
        tableData = [String:[String]]()
        tableData["Subscription"] = subOptions
        tableData["Legal"] = legalOptions
    }
    
    
    
    
    
    // --- View ---
    // Update navigation bar based on ndevice - update for
    func navigationBarFormatting() {
        if UIDevice.current.modelName.contains("iPhone10") {
            // Top Constraint
            navViewTopConstraint.isActive = false
            navView.topAnchor.constraint(equalTo: topLayoutGuide.topAnchor).isActive = true
            
            // Height
            navViewHeightConstraint.isActive = false
            navView.heightAnchor.constraint(equalToConstant: navView.frame.size.height + 16).isActive = true
        }
    }
    
    // Activity Spinner and container
    func formatActivityIndicatorView() {
        // Activity Spinner
        let transform = CGAffineTransform(scaleX: CGFloat(2), y: CGFloat(2))
        activityIndicator.transform = transform
        activityIndicator.isHidden = true
        
        // Activity Spinner Container
        container.isHidden = true
        container.layer.cornerRadius = 10
        container.layer.borderWidth = 2
        container.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
    }
}
