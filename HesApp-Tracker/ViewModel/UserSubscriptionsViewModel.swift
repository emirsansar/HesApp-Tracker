import FirebaseFirestore
import SwiftData
import os.log

class UserSubscriptionsViewModel: ObservableObject {
    
    enum FetchingSubscriptionsState: Equatable{
        case loading
        case success
        case failure
    }
    
    enum FetchingUserSummaryState: Equatable{
        case loading
        case success
        case failure
    }

    @Published var fetchingSubscriptionsState: FetchingSubscriptionsState?
    @Published var fetchingUserSummaryState: FetchingUserSummaryState?
    
    @Published var userSubscriptions = [UserSubscription]()
    
    @Published var totalSubscriptionCount: Int = 0
    @Published var totalMonthlySpending: Double = 0.0
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "UserSubscriptionsViewModel")
    
    
// MARK: - Firestore
    
    /// Adds a subscription plan to the user's collection in Firestore.
    func addPlanToUserOnFirestore(serviceName: String, plan: Plan, personCount: Int, completion: @escaping (Bool) -> Void) {

        let userRef = FirestoreManager.shared.db.collection("Users").document(AuthManager.shared.currentUserEmail!)
        
        userRef.getDocument { documentSnapshot, error in
            guard error == nil else {
                DispatchQueue.main.async {
                    self.logger.error("There is an error: \(error!.localizedDescription)")
                }
                completion(false)
                return
            }
            
            var updateData: [String: Any] = [:]
            
            if let document = documentSnapshot, document.exists {
                let existingSubscriptions = document.data()?["Subscriptions"] as? [String: Any] ?? [:]
                var updatedSubscriptions = existingSubscriptions
                updatedSubscriptions[serviceName] = [
                    "PlanName": plan.planName,
                    "Price": plan.planPrice,
                    "PersonCount": personCount
                ]
                
                updateData["Subscriptions"] = updatedSubscriptions
            } 
            else {
                updateData["Subscriptions"] = [
                    serviceName: [
                        "PlanName": plan.planName,
                        "Price": plan.planPrice,
                        "PersonCount": personCount
                    ]
                ]
            }
            
            userRef.setData(updateData, merge: true) { error in
                DispatchQueue.main.async {
                    if let error = error {
                        self.logger.error("Error: \(error.localizedDescription)")
                        completion(false)
                    } else {
                        self.logger.info("Successfully added plan \(plan.planName, privacy: .public) to user \(AuthManager.shared.currentUserEmail!, privacy: .public).")
                        completion(true)
                    }
                }
            }
        }
        
    }

    /// Fetchs the user's subscriptions from Firestore.
    func fetchUserSubscriptionsFromFirestore(completion: @escaping ([UserSubscription]? ,Bool) -> Void) {
        self.fetchingSubscriptionsState = .loading
        
        let userRef = FirestoreManager.shared.db.collection("Users").document(AuthManager.shared.currentUserEmail!)
        
        userRef.getDocument { documentSnapshot, error in
            if let error = error {
                self.logger.error("An error occurred whilte trying to fetch user's subscription list: \(error.localizedDescription)")
                self.fetchingSubscriptionsState = .failure
                completion(nil, false)
                return
            }
            
            guard let document = documentSnapshot, document.exists,
                  let subscriptions = document.data()?["Subscriptions"] as? [String: [String: Any]] else {
                
                self.logger.error("User's subscription list cannot be found.")
                self.fetchingSubscriptionsState = .failure
                completion(nil, false)
                return
            }
            
            var fetchedSubscriptions: [UserSubscription] = []
            
            for (serviceName, serviceDetails) in subscriptions {
               if let planName = serviceDetails["PlanName"] as? String,
                  let planPrice = serviceDetails["Price"] as? Double,
                  let personCount = serviceDetails["PersonCount"] as? Int {
                   
                   let userSub = UserSubscription(serviceName: serviceName, planName: planName, planPrice: planPrice, personCount: personCount)
                   fetchedSubscriptions.append(userSub)
               }
           }
           
           DispatchQueue.main.async {
               self.logger.info("User's subscriptions list have been fetched successfully.")
               self.userSubscriptions = fetchedSubscriptions
               self.fetchingSubscriptionsState = .success
               completion(self.userSubscriptions, true)
           }
        }
       
    }

    /// Removes a selected subscription from the user's collection in Firestore.
    func removeSubscriptionFromUser(selectedSub: UserSubscription, completion: @escaping (Bool, Error?) -> Void) {
        
        let userRef = FirestoreManager.shared.db.collection("Users").document(AuthManager.shared.currentUserEmail!)
        
        userRef.getDocument { documentSnapshot, error in
            if let error = error {
                completion(false, error)
                return
            }
 
            let fieldToRemove = selectedSub.serviceName
            
            userRef.updateData(["Subscriptions.\(fieldToRemove)": FieldValue.delete()]) { error in
                if let error = error {
                    self.logger.error("Error while trying to remove sub: \(error.localizedDescription)")
                    completion(false, error)
                } else {
                    DispatchQueue.main.async {
                        if let index = self.userSubscriptions.firstIndex(where: { $0.serviceName == selectedSub.serviceName }) {
                            self.userSubscriptions.remove(at: index)
                        }
                    }
                    self.logger.info("Subscriptions have been removed successfully.")
                    completion(true, nil)
                }
            }
        }
        
    }
    
    /// Fetches a summary of the user's total subscription count and monthly spending from Firestore.
    func fetchSubscriptionsSummary(completion: @escaping (Int, Double) -> Void){
        self.fetchingUserSummaryState = .loading

        let userRef = FirestoreManager.shared.db.collection("Users").document(AuthManager.shared.currentUserEmail!)
        
        userRef.getDocument { documentSnapshot, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.logger.error("User's summary error: \(error.localizedDescription)")
                    self.fetchingUserSummaryState = .failure
                }
                return
            }
            
            guard let document = documentSnapshot, document.exists,
                  let subscriptions = document.data()?["Subscriptions"] as? [String: [String: Any]] else {
                    DispatchQueue.main.async {
                        self.logger.error("No subscriptions found.")
                        self.fetchingUserSummaryState = .failure
                }
                return
            }
            
            var monthlySpend: Double = 0.0
            let serviceCount: Int = subscriptions.count
            
            for (_, serviceDetails) in subscriptions {
                if let price = serviceDetails["Price"] as? Double,
                   let personCount = serviceDetails["PersonCount"] as? Int {
                    monthlySpend += price / Double(personCount)
                }
            }
            
            DispatchQueue.main.async {
                self.totalSubscriptionCount = serviceCount
                self.totalMonthlySpending = monthlySpend
                self.fetchingUserSummaryState = .success
                
                self.logger.info("User's subscriptions summary have been fetched succesfully.")
                completion(self.totalSubscriptionCount, self.totalMonthlySpending)
            }
        }
        
    }
    
    /// Updates the selected subscription on Firebase.
    func updateSubscription(updatedSubscription: UserSubscription, completion: @escaping (Bool) -> Void) {
        
        let userRef = FirestoreManager.shared.db.collection("Users").document(AuthManager.shared.currentUserEmail!)
        
        userRef.getDocument { documentSnapshot, error in
            if let error = error {
                self.logger.error("Error when trying to update sub: \(error.localizedDescription)")
                completion(false)
            }
            
            guard let document = documentSnapshot, document.exists,
                  var subscriptions = document.data()?["Subscriptions"] as? [String: [String: Any]] else {
                self.logger.info("No subscriptions found or document does not exist.")
                completion(false)
                return
            }
            
            if var serviceDetails = subscriptions[updatedSubscription.serviceName] {
                serviceDetails["PlanName"] = updatedSubscription.planName
                serviceDetails["Price"] = updatedSubscription.planPrice
                serviceDetails["PersonCount"] = updatedSubscription.personCount
                
                subscriptions[updatedSubscription.serviceName] = serviceDetails
                
                userRef.updateData(["Subscriptions": subscriptions]) { error in
                    if let error = error {
                        self.logger.error("\(error.localizedDescription)")
                        completion(false)
                    } else {
                        DispatchQueue.main.async {
                            if let index = self.userSubscriptions.firstIndex(where: { $0.serviceName == updatedSubscription.serviceName }) {
                                self.userSubscriptions[index] = updatedSubscription
                            }
                            self.logger.info("Service have been updated successfully.")
                            completion(true)
                        }
                    }
                }
            } 
            else {
                self.logger.error("Service not found in user's subscriptions.")
                completion(false)
            }
        }
    }
    
    
// MARK: - SwiftData
    
    /// Saves an array of Service models to SwiftData.
    func saveUserSubscriptionsToSwiftData(userSubscriptions: [UserSubscription], context: ModelContext) {
        
        for subscription in userSubscriptions {
            context.insert(subscription)
        }
        
        do {
            try context.save()
            self.logger.info("User's subscriptions have been successfully saved to SwiftData.")
        } catch {
            self.logger.error("Failed to save user's subscriptions to SwiftData: \(error.localizedDescription)")
        }
    }

    /// Removes a subscription from SwiftData.
    func removeUserSubscriptionFromSwiftData(selectedSub: UserSubscription, userSubsriptionsFromSWData: [UserSubscription], context: ModelContext, completion: @escaping (Bool) -> Void) {
        
        if let index = userSubsriptionsFromSWData.firstIndex(where: { $0.serviceName == selectedSub.serviceName }) {
            context.delete(userSubsriptionsFromSWData[index])
            
            do {
                try context.save()
                self.logger.info("User's subscriptions have been successfully removed to SwiftData.")
                completion(true)
            } catch {
                self.logger.error("Failed to remove subscription from SwiftData: \(error)")
                completion(false)
            }
        }
    }
    
    /// Updates a subscription in SwiftData.
    func updateUserSubscriptionInSwiftData(selectedSub: UserSubscription, updatedSub: UserSubscription, userSubsriptionsFromSWData: [UserSubscription], context: ModelContext, completion: @escaping (Bool) -> Void) {

        if let index = userSubsriptionsFromSWData.firstIndex(where: { $0.serviceName == selectedSub.serviceName }) {

            let subscriptionToUpdate = userSubsriptionsFromSWData[index]
            subscriptionToUpdate.planName = updatedSub.planName
            subscriptionToUpdate.planPrice = updatedSub.planPrice
            subscriptionToUpdate.personCount = updatedSub.personCount
            subscriptionToUpdate.serviceName = updatedSub.serviceName
            
            do {
                try context.save()
                
                self.logger.info("Subscription successfully updated in SwiftData.")
                completion(true)
            } catch {
                self.logger.error("Failed to update subscription in SwiftData: \(error)")
                completion(false)
            }
        } else {
            self.logger.error("Subscription not found on SwiftData.")
            completion(false)
        }
    }

    /// Removes all user subscriptions directly from SwiftData.
    func removeAllUserSubscriptionsFromSwiftData(context: ModelContext, completion: @escaping (Bool) -> Void) {
        let fetchRequest = FetchDescriptor<UserSubscription>()
        
        do {
            let allUserSubscriptions = try context.fetch(fetchRequest)
            
            for subscription in allUserSubscriptions {
                context.delete(subscription)
            }
            
            try context.save()
            
            self.logger.info("All user subscriptions successfully removed from SwiftData.")
            completion(true)
        } catch {
            self.logger.error("Failed to remove all user subscriptions from SwiftData: \(error)")
            completion(false)
        }
    }


}
