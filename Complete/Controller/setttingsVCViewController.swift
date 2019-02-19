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
    
    
    
    
    
    // --- Instance Variables ---
    var tableData:[String:[String]]!
    var sections:[String]!
    
    
    
    
    // --- Actions ---
    // Go back to channel vc
    @IBAction func backBtnPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
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
    }
    
    
    
    
    
    
    
    
    
    // --- Helper Functions ---
    // --- Table View ---
    func setUpDataForTable() {
        // Table Cells
        let subOptions = ["Upgrade To Premium",
                          "Subscription Details",
                          "Restore Subscription",
                          "Log Out"]
        let legalOptions = ["Privacy Policy",
                            "Terms and Conditions"]
        
        sections = ["Upgrade", "Subscription", "Legal", "Log Out"]
        
        tableData = [String:[String]]()
        tableData["Subscription"] = subOptions
        tableData["Legal"] = legalOptions
    }
    
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
            return CGFloat(115)
        }
        else if sectionId == "Log Out" {
            return CGFloat(100)
        }
        else if sectionId == "Subscription" {
            return CGFloat(20)
        }
        else {
            return CGFloat(65.5)
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

}
