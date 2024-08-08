import Foundation
import FirebaseAuth

class AuthManager {
    
    static var shared = AuthManager()
    
    let auth: Auth
    var currentUserEmail: String?
    
    private init() {
        self.auth = Auth.auth()
        
        if (Auth.auth().currentUser != nil) {
            self.currentUserEmail = Auth.auth().currentUser?.email
        }
    }
    
}
