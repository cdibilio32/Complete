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
    }
}
