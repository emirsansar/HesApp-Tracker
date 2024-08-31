import Foundation
import os.log

class AuthenticationViewModel: ObservableObject {
    
    enum RegisterState: Equatable{
        case registering
        case success
        case failure
    }
    
    enum LoginState: Equatable{
        case logging
        case success
        case failure
    }
    
    enum LoggingOutState: Equatable{
        case loggingOut
        case success
        case failure(String)
    }
    
    @Published var registerState: RegisterState?
    @Published var registrationError: String?

    @Published var loginState: LoginState?
    @Published var loggingError: String?
 
    @Published var loggingOutState: LoggingOutState?
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "AuthenticationViewModel")
    
    
// MARK: - Firebase
    
    /// Registers a user with Firebase Authentication.
    func registerUserToFirebaseAuth(email: String, password: String, name: String, surname: String) {
        self.registerState = .registering
        
        AuthManager.shared.auth.createUser(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async {
                guard error == nil else {
                    self.logger.error("Register error: \(error!.localizedDescription)")
                    self.registrationError = error!.localizedDescription
                    return
                }
                
                self.saveUserDetailsToFirestore(email: email, name: name, surname: surname) { success in
                    if success {
                        self.logger.info("Registiration has been successful.")
                        self.registerState = .success
                    } else {
                        self.registerState = .failure
                    }
                }
            }
        }
    }
    
    /// Saves user details to Firestore.
    private func saveUserDetailsToFirestore(email: String, name: String, surname: String, completion: @escaping (Bool) -> Void) {
        let userData: [String: Any] = ["Name": name, "Surname": surname, "Subscriptions": [:] ]
        
        FirestoreManager.shared.db.collection("Users").document(email).setData(userData) { error in
            DispatchQueue.main.async {
                guard error == nil else {
                    self.logger.error("An error occured while trying to save user's details on Firestore: \(error!.localizedDescription)")
                    completion(false)
                    return
                }
                self.logger.info("User's details has been saved on Firestore successfully.")
                completion(true)
            }
        }
    }
    
    /// Logs in a user with Firebase Authentication.
    func loginUser(email: String, password: String) {
        self.loginState = .logging
        
        AuthManager.shared.auth.signIn(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async {
                guard error == nil else {
                    self.logger.error("Login error: \(error!.localizedDescription)")
                    self.loggingError = error!.localizedDescription
                    self.loginState = .failure
                    return
                }
                
                self.logger.info("Login successful.")
                self.loginState = .success
                AuthManager.shared.currentUserEmail = result?.user.email
            }
        }
        
    }
    
    /// Logs out a user with Firebase Authentication.
    func logOut() {
        self.loggingOutState = .loggingOut
        
        do {
            try AuthManager.shared.auth.signOut()
        }
        catch let signOutError as NSError {
            print(signOutError)
            self.logger.error("Log out error: \(signOutError)")
            self.loggingOutState = .failure("logging_out_error")
            return
        }
        
        self.logger.info("Log out successful.")
        self.loggingOutState = .success
        UserDefaults.standard.set(false, forKey: "isUserLoggedIn")
    }
    
}
