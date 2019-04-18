//
//  signUpVC.swift
//  Complete
//
//  Created by Chuck Dibilio on 9/30/18.
//  Copyright © 2018 Chuck Dibilio. All rights reserved.
//

import UIKit
import FirebaseAuth

class signUpVC: UIViewController {
    
    // --- Outlets ---
    @IBOutlet var titleLogo: UILabel!
    @IBOutlet var emailTxtLbl: UITextField!
    @IBOutlet var passwordTxtLbl: UITextField!
    @IBOutlet var confirmPWTxtLbl: UITextField!
    @IBOutlet var errorMsg: UILabel!
    @IBOutlet var signUpBtn: UIButton!
    @IBOutlet var signUpBtnBottomConstraint: NSLayoutConstraint!
    @IBOutlet var titleTopConstraint: NSLayoutConstraint!
    
    
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
                        userID = (Auth.auth().currentUser?.uid)!
                        isNewUser = true
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
        
        // Format Sign Up Button
        signUpBtn.layer.cornerRadius = 10.0
        
        // Listener for keyboard to adjust height of sign up
        NotificationCenter.default.addObserver(self, selector: #selector(updateSignUPButtonHeight(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(decreaseSignUpButtonHeight(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // Update bottom constraint
        signUpBtnBottomConstraint.isActive = false
    }
    
    
    
    
    // --- Listener Functions ---
    // Keyboard appears
    @objc func updateSignUPButtonHeight(notification:NSNotification) {
        if let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            
            // Constraints
            titleTopConstraint.isActive = false
            signUpBtnBottomConstraint.isActive = true
            signUpBtnBottomConstraint.constant = keyboardHeight + 5.0
        }
    }
    
    // Keyboard dissapears
    @objc func decreaseSignUpButtonHeight(notification:NSNotification) {
        // Fix constraints
        titleTopConstraint.isActive = true
        signUpBtnBottomConstraint.isActive = false
    }
}
