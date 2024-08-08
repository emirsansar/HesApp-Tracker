import Foundation

class UserAuthAndDetailsViewModel: ObservableObject {
    
    @Published var registrationError: String?
    @Published var registrationSuccess: Bool = false
    @Published var isRegistering: Bool = false
    
    @Published var loginError: String?
    @Published var isLoggingIn: Bool = false
    @Published var loginSuccess: Bool = false
    
    @Published var fullname: String = ""
    
    // Registers a user with Firebase Authentication.
    func registerUserToFirebaseAuth(email: String, password: String, name: String, surname: String, completion: @escaping (Bool) -> Void) {
        isRegistering = true
        registrationError = nil
        
        AuthManager.shared.auth.createUser(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async {
                guard error == nil else {
                    self.handleRegistrationError(error: error!.localizedDescription)
                    completion(false)
                    return
                }
                self.registrationSuccess = true
                self.isRegistering = false
                completion(true)
            }
        }
    }
    
    // Saves user details to Firestore.
    private func saveUserDetailsToFirestore(email: String, name: String, surname: String, completion: @escaping (Bool) -> Void) {

        let userData: [String: Any] = ["Name": name, "Surname": surname]
        
        FirestoreManager.shared.db.collection("Users").document(email).setData(userData) { error in
            DispatchQueue.main.async {
                guard error == nil else {
                    self.handleLoginError(error: error!.localizedDescription)
                    completion(false)
                    return
                }
                completion(true)
            }
        }
        
    }
    
    // Logs in a user with Firebase Authentication.
    func loginUser(email: String, password: String, completion: @escaping (Bool) -> Void) {
        
        AuthManager.shared.auth.signIn(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async {
                guard error == nil else {
                    self.handleLoginError(error: error!.localizedDescription)
                    completion(false)
                    return
                }
                self.loginSuccess = true
                self.isLoggingIn = false
                AuthManager.shared.currentUserEmail = result?.user.email
                completion(true)
            }
        }
        
    }
    
    // Fetch the user's full name from Firestore to show on Home page.
    func getUserFullname () {
        guard let email = AuthManager.shared.currentUserEmail else {
            fullname = ""
            return
        }
        
        FirestoreManager.shared.db.collection("Users").document(email).getDocument { documentSnapshot, error in
            DispatchQueue.main.async {
                guard let document = documentSnapshot, error == nil else {
                    self.fullname = ""
                    return
                }
                let name = document.get("Name") as? String ?? ""
                let surname = document.get("Surname") as? String ?? ""
                self.fullname = "\(name) \(surname)"
            }
        }
        
    }
    
    
    // Handles registration errors and updates the state
    private func handleRegistrationError(error: String) {
      registrationError = error
      registrationSuccess = false
      isRegistering = false
    }

    // Handles login errors and updates the state
    private func handleLoginError(error: String) {
      loginError = error
      loginSuccess = false
      isLoggingIn = false
    }
    
}
