//
//  UserAuthAndDetailsViewModel.swift
//  HesApp-Tracker
//
//  Created by Emir Sansar on 3.08.2024.
//

import Foundation

class UserAuthAndDetailsViewModel: ObservableObject {
    
    @Published var registrationError: String?
    @Published var registrationSuccess: Bool = false
    @Published var isRegistering: Bool = false
    
    @Published var loginError: String?
    @Published var isLoggingIn: Bool = false
    @Published var loginSuccess: Bool = false
    
    @Published var fullname: String = ""
    
    
    func registerUserToFirebaseAuth(email: String, password: String, name: String, surname: String, completion: @escaping (Bool) -> Void) {
        isRegistering = true
        registrationError = nil
        
        AuthManager.shared.auth.createUser(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.registrationError = error.localizedDescription
                    self.registrationSuccess = false
                    self.isRegistering = false
                    completion(false)
                } else {
                    self.saveUserDetailsToFirestore(email: email, name: name, surname: surname) { success in
                        self.registrationSuccess = success
                        self.isRegistering = false
                        completion(success)
                    }
                }
            }
        }
    }
    
    private func saveUserDetailsToFirestore(email: String, name: String, surname: String, completion: @escaping (Bool) -> Void) {
        
        FirestoreManager.shared.db.collection("Users").document(email).setData([
            "Name": name,
            "Surname": surname
        ]) { error in
            if let error = error {
                self.registrationError = error.localizedDescription
                completion(false)
            } else {
                completion(true)
            }
        }
        
    }
    
    
    func loginUser(email: String, password: String, completion: @escaping (Bool) -> Void) {
        
        AuthManager.shared.auth.signIn(withEmail: email, password: password) { result, error in
            if error != nil {
                self.loginError = error?.localizedDescription
                self.isLoggingIn = false
                completion(false)
            } else {
                self.loginSuccess = true
                completion(true)
            }
            self.isLoggingIn = false
        }
        
    }
    
    func getUserFullname () {
        
        FirestoreManager.shared.db.collection("Users").document(AuthManager.shared.currentUserEmail!).getDocument { documentSnapshot, error in
            if let error = error {
                print(error.localizedDescription)
                self.fullname=""
            }
            
            if let document = documentSnapshot {
                let name = document.get("Name") as? String ?? ""
                let surname = document.get("Surname") as? String ?? ""
                
                DispatchQueue.main.async {
                    self.fullname = "\(name) \(surname)"
                }
            }
        }
        
    }
    
}

