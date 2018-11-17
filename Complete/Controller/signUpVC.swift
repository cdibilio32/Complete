//
//  signUpVC.swift
//  Complete
//
//  Created by Chuck Dibilio on 9/30/18.
//  Copyright © 2018 Chuck Dibilio. All rights reserved.
//

import UIKit

class signUpVC: UIViewController {
    
    // --- Outlets ---
    @IBOutlet var titleLogo: UILabel!
    @IBOutlet var emailTxtLbl: UITextField!
    @IBOutlet var passwordTxtLbl: UITextField!
    @IBOutlet var confirmPWTxtLbl: UITextField!
    @IBOutlet var errorMsg: UILabel!
    
    
    
    // --- Actions ---
    // Back Button Pressed
    @IBAction func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // Back Button Pressed
    @IBAction func signUpButtonPressed(_ sender: Any) {
        
        // Check is password matches
        if passwordTxtLbl.text == confirmPWTxtLbl.text {
            // If matches - sign up
            // Check if there is anything in text fields
            if emailTxtLbl.text != "" && passwordTxtLbl.text != "" {
                // Sign Up
                AuthService.instance.registerUser(withEmail: emailTxtLbl.text!, andPassword: passwordTxtLbl.text!) { (registered, error) in
                    if registered {
                        self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
                    }
                    else {
                        print(String(describing: error?.localizedDescription))
                        self.errorMsg.text = String(describing: error!.localizedDescription)
                        self.errorMsg.isHidden = false
                    }
                }
            }
            // one or both fields left blank
            else  {
                errorMsg.text = "Please Provide Email and Password"
                errorMsg.isHidden = false
            }
        }
        // Passwords do not match
        else {
            errorMsg.text = "Your Password Does Not Match"
            errorMsg.isHidden = false
        }
    }
    
    // Log Out
    @IBAction func logOutUser(_ sender: Any) {
        AuthService.instance.logOffUser()
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Edit title Logo
        self.titleLogo.layer.cornerRadius = CGFloat(Float(5.0))
        
        // Hide Error message
        errorMsg.isHidden = true
        errorMsg.isHidden = true
    }
}
