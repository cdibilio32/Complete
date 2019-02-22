//
//  LegalVC.swift
//  Complete
//
//  Created by Chuck Dibilio on 2/19/19.
//  Copyright © 2019 Chuck Dibilio. All rights reserved.
//

import UIKit

class LegalVC: UIViewController {
    
    // --- Outlets ---
    @IBOutlet var navBarTitle: UILabel!
    @IBOutlet var navViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var navView: UIView!
    @IBOutlet var navViewTopConstraint: NSLayoutConstraint!
    @IBOutlet var bodyText: UITextView!
    
    
    
    // --- Instance Variable ---
    var sectionTitle:String!
    
    
    
    
    
    // --- Actions ---
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
    
    
    
    
    
    
    
    
    // --- Load Functions ---
    override func viewDidLoad() {
        super.viewDidLoad()

        // Nav Bar Formatting + title
        navigationBarFormatting()
        navBarTitle.text = sectionTitle
        
        // Get information to display
        getBodyText()
    }
    
    
    
    
    
    
    
    
    
    // --- Helper Functions ---
    // --- Navigation Bar ---
    // Formating
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
    
    
    
    // Get Documents
    func getBodyText() {
        // get file name
        let file:String!
        if sectionTitle == "Subscription Details" {
            file = "JotItt_Subscription_Policy"
        }
        else if sectionTitle == "Privacy Policy"{
            file = "JotItt_Privacy_Policy"
        }
        else {
            file = "JotItt_Terms_Of_Use"
        }
        
        // Get URL
        var filePath = Bundle.main.url(forResource: file, withExtension: "rtf")
        
        // Get Content and display
        do {
            let attributedStringWithRtf: NSAttributedString = try NSAttributedString(url: filePath!, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.rtf], documentAttributes: nil)
            bodyText.attributedText = attributedStringWithRtf
        }
        catch {
            debugPrint(error.localizedDescription)
        }
    }
}
