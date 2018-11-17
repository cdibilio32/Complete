//
//  AuthService.swift
//  Complete
//
//  Created by Chuck Dibilio on 11/9/18.
//  Copyright © 2018 Chuck Dibilio. All rights reserved.
//

import Foundation
import FirebaseAuth

class AuthService {
    static let instance = AuthService()
    
    // Register new User
    func registerUser(withEmail email: String, andPassword password: String, userCreationComplete: @escaping (_ status:Bool, _ error: Error?) ->()) {
        Auth.auth().createUser(withEmail:email , password: password) { (results, error) in
            // Return with error if user is not created
            guard let user = results?.user else {
                userCreationComplete(false, error)
                return
            }
            
            // If user is created
            let userData = ["provider": user.providerID, "email": user.email]
            
            // send to database user
            // TODO
            DataService.instance.createDBUser(userId: user.uid, userData: userData as! [String : String])
            userCreationComplete(true, nil)
        }
    }
    
    // Log In User
    func loginUser(withEmail email: String, andPassword password:String, loginComplete: @escaping (_ status: Bool, _ error: Error?)->()) {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if error != nil {
                loginComplete(false, error)
                return
            }
            loginComplete(true, nil)
        }
    }
    
    // Log off user
    func logOffUser() {
        do {
            try Auth.auth().signOut()
        } catch {
            debugPrint("sign out error")
        }
    }
}

