import Foundation
import SwiftData

class UserViewModel: ObservableObject {
    
    @Published var currentUser: User

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
            print("User data saved or updated successfully.")
        } catch {
            print("Failed to save or update user data: \(error)")
        }
    }
    
    /// Fetchs the first User from SwiftData that matches the given email, if any.
    func fetchUserFromSwiftData(byEmail email: String, context: ModelContext) -> User? {
        let fetchRequest = FetchDescriptor<User>(
            predicate: #Predicate { $0.email == email }
        )
        
        do {
            let fetchedUsers = try context.fetch(fetchRequest)
            return fetchedUsers.first
        } catch {
            print("Failed to fetch user: \(error)")
            return nil
        }
    }

        
    
}
