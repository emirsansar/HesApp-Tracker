import Foundation
import SwiftData
import os.log

class UserViewModel: ObservableObject {
    
    @Published var currentUser: User
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "UserViewModel")

    init() {
        let email = AuthManager.shared.currentUserEmail!
        currentUser = User(email: email, fullName: "", subscriptionCount: 0, monthlySpend: 0)
    }

    
    func updateCurrentUserName(fullName: String) {
        self.currentUser.fullName = fullName
    }
    
    func updateCurrentUserSubscriptionSummary(subscriptionCount: Int, monthlySpend: Double) {
        self.currentUser.subscriptionCount = subscriptionCount
        self.currentUser.monthlySpend = monthlySpend
    }
    
    /// Fetchs  the user's full name from Firestore to show on Home page.
    func fetchsUserFullname (completion: @escaping (String?) -> Void )  {
        let email = AuthManager.shared.currentUserEmail
        
        FirestoreManager.shared.db.collection("Users").document(email!).getDocument { documentSnapshot, error in
            DispatchQueue.main.async {
                guard let document = documentSnapshot, error == nil else {
                    self.logger.error("User cannot be found on 'Users' collection.")
                    return
                }
                
                let name = document.get("Name") as? String ?? ""
                let surname = document.get("Surname") as? String ?? ""
                let fullname = "\(name) \(surname)"
                completion(fullname)
            }
        }
    }
    
    /// Saves or updates the user's details in SwiftData.
    func saveUserDetailsToSwiftData(user: User, context: ModelContext) {

        if let existingUser = self.fetchUserFromSwiftData(byEmail: user.email, context: context) {
            existingUser.fullName = user.fullName
            existingUser.subscriptionCount = user.subscriptionCount
            existingUser.monthlySpend = user.monthlySpend
        } else {
            context.insert(user)
        }
                
        do {
            try context.save()
            self.logger.info("User data saved or updated successfully on SwiftData.")
        } catch {
            self.logger.error("Failed to save or update user data on SwiftData: \(error)")
        }
    }
    
    /// Fetchs the first User from SwiftData that matches the given email, if any.
    func fetchUserFromSwiftData(byEmail email: String, context: ModelContext) -> User? {
        let fetchRequest = FetchDescriptor<User>(
            predicate: #Predicate { $0.email == email }
        )
        
        do {
            let fetchedUsers = try context.fetch(fetchRequest)
            self.logger.info("User has been fetched from SwiftData.")
            return fetchedUsers.first
        } catch {
            self.logger.error("Failed to fetch user on SwiftData: \(error)")
            return nil
        }
    }

        
    
}
