//
//  AuthManager.swift
//  HesApp-Tracker
//
//  Created by Emir Sansar on 7.08.2024.
//

import Foundation
import FirebaseAuth

class AuthManager {
    
    static var shared = AuthManager()
    
    let auth: Auth
    var currentUserEmail: String?
    
    private init() {
        self.auth = Auth.auth()
        self.currentUserEmail = auth.currentUser?.email
    }
    
}
