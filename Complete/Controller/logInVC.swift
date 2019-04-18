//
//  logInVC.swift
//  Complete
//
//  Created by Chuck Dibilio on 9/30/18.
//  Copyright © 2018 Chuck Dibilio. All rights reserved.
//

import UIKit
import FirebaseAuth

class logInVC: UIViewController {

    // --- Outlets ---
    @IBOutlet var titleLogo: UILabel!
    @IBOutlet var emailTxtField: UITextField!
    @IBOutlet var passwordTxtField: UITextField!
    @IBOutlet var errorMsgLbl: UILabel!
    @IBOutlet var logInBtn: UIButton!
    @IBOutlet var topConstraint: NSLayoutConstraint!
    @IBOutlet var bottomConstraint: NSLayoutConstraint!
    
    
    // --- Actions ---
    // Log In User
    @IBAction func logInUser(_ sender: Any) {
        if emailTxtField.text != nil && passwordTxtField.text != nil {
            AuthService.instance.loginUser(withEmail: emailTxtField.text!, andPassword: passwordTxtField.text!) { (success, error) in
                if success {
                    userID = (Auth.auth().currentUser?.uid)!
                    justLoggedIn = true
                    // Set Up Database for user
                    self.dismiss(animated: true, completion: nil)
                }
                else {
                    self.errorMsgLbl.text = String(describing: error!.localizedDescription)
                    self.errorMsgLbl.isHidden = false
                }
            }
        }
        else {
            errorMsgLbl.text = "E-mail or Password is Incorrect"
            errorMsgLbl.isHidden = false
        }
    }
    
    // Go to Sign In Page
    @IBAction func signUpBtnPressed(_ sender: Any) {
    }
    
    
    
    // --- Load Functions ---
    override func viewDidLoad() {
        super.viewDidLoad()
        // Edit Title Logo
        self.titleLogo.layer.cornerRadius = CGFloat(Float(5.0))
        
        // Hide error message
        errorMsgLbl.isHidden = true
        
        // Format Log In button
        logInBtn.layer.cornerRadius = 10.0
        
        // Fix alignment of screen with keyboard showing
        // Listener for keyboard to adjust height of sign up
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardAppears(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDissapears(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        bottomConstraint.isActive = false
    }
    
    
    
    
    // --- Helper functions ---
    @objc func keyboardAppears(notification:NSNotification) {
        if let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            
            // Constraints
            topConstraint.isActive = false
            bottomConstraint.isActive = true
            bottomConstraint.constant = keyboardHeight + 5.0
        }
    }
    
    // Keyboard dissapears
    @objc func keyboardDissapears(notification:NSNotification) {
        // Fix constraints
        topConstraint.isActive = true
        bottomConstraint.isActive = false
    }
}
