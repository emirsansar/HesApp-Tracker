import FirebaseFirestore
import SwiftData

class UserSubscriptionsViewModel: ObservableObject {
    
    @Published var planAddingError: String?
    @Published var isAddingPlan: Bool = false
    @Published var planAddedSuccesfully: Bool = false
    
    @Published var userSubscriptions = [UserSubscription]()
    @Published var fetchingSubsError: String?
    @Published var isFetchingSubs: Bool = false
    
    @Published var fetchSubscriptionSummaryError: String?
    @Published var isGettingUserSubCountandSpending: Bool = false
    
    @Published var totalSubscriptionCount: Int = 0
    @Published var totalMonthlySpending: Double = 0.0
 
    
// MARK: - Firestore
    
    /// Adds a subscription plan to the user's collection in Firestore.
    func addPlanToUserOnFirestore(serviceName: String, plan: Plan, personCount: Int, completion: @escaping (Bool) -> Void) {

        let userRef = FirestoreManager.shared.db.collection("Users").document(AuthManager.shared.currentUserEmail!)
        
        userRef.getDocument { documentSnapshot, error in
            guard error == nil else {
                DispatchQueue.main.async {
                    self.planAddingError = "There is an error: \(error!.localizedDescription)"
                    self.planAddedSuccesfully = false
                    self.isAddingPlan = false
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
                        self.planAddingError = "Error: \(error.localizedDescription)"
                        self.planAddedSuccesfully = false
                        completion(false)
                    } else {
                        self.planAddedSuccesfully = true
                        completion(true)
                    }
                    self.isAddingPlan = false
                }
            }
        }
        
    }

    /// Fetchs the user's subscriptions from Firestore.
    func fetchUserSubscriptions(completion: @escaping ([UserSubscription]? ,Bool) -> Void) {

        let userRef = FirestoreManager.shared.db.collection("Users").document(AuthManager.shared.currentUserEmail!)
        
        userRef.getDocument { documentSnapshot, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.fetchingSubsError = "An error occurred: \(error.localizedDescription)"
                }
                completion(nil, false)
                return
            }
            
            guard let document = documentSnapshot, document.exists,
                  let subscriptions = document.data()?["Subscriptions"] as? [String: [String: Any]] else {
                DispatchQueue.main.async {
                    self.fetchingSubsError = "There are no subscriptions."
                }
                completion(nil, false)
                return
            }
            
            var fetchedSubscriptions: [UserSubscription] = []
            
            for (serviceName, serviceDetails) in subscriptions {
               if let planName = serviceDetails["PlanName"] as? String,
                  let planPrice = serviceDetails["Price"] as? Double,
                  let personCount = serviceDetails["PersonCount"] as? Int {
                   
                   //let plan = Plan(planName: planName, planPrice: planPrice)
                   let userSub = UserSubscription(serviceName: serviceName, planName: planName, planPrice: planPrice, personCount: personCount)
                   fetchedSubscriptions.append(userSub)
               }
           }
           
           DispatchQueue.main.async {
               self.userSubscriptions = fetchedSubscriptions
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
                    completion(false, error)
                } else {
                    DispatchQueue.main.async {
                        if let index = self.userSubscriptions.firstIndex(where: { $0.serviceName == selectedSub.serviceName }) {
                            self.userSubscriptions.remove(at: index)
                        }
                    }
                    completion(true, nil)
                }
            }
        }
        
    }
    
    /// Fetches a summary of the user's total subscription count and monthly spending from Firestore.
    func fetchSubscriptionsSummary(completion: @escaping (Int, Double) -> Void){
        isGettingUserSubCountandSpending = true

        let userRef = FirestoreManager.shared.db.collection("Users").document(AuthManager.shared.currentUserEmail!)
        
        userRef.getDocument { documentSnapshot, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.fetchSubscriptionSummaryError = error.localizedDescription
                    self.isGettingUserSubCountandSpending = false
                }
                return
            }
            
            guard let document = documentSnapshot, document.exists,
                  let subscriptions = document.data()?["Subscriptions"] as? [String: [String: Any]] else {
                    DispatchQueue.main.async {
                        self.fetchSubscriptionSummaryError = "No subscriptions found."
                        self.isGettingUserSubCountandSpending = false
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
                self.isGettingUserSubCountandSpending = false
                
                completion(self.totalSubscriptionCount, self.totalMonthlySpending)
            }
        }
        
    }
    
    /// Updates the selected subscription on Firebase.
    func updateSubscription(editedSub: UserSubscription, completion: @escaping (Bool, String?) -> Void) {
        
        let userRef = FirestoreManager.shared.db.collection("Users").document(AuthManager.shared.currentUserEmail!)
        
        userRef.getDocument { documentSnapshot, error in
            if let error = error {
                completion(false, error.localizedDescription)
            }
            
            guard let document = documentSnapshot, document.exists,
                  var subscriptions = document.data()?["Subscriptions"] as? [String: [String: Any]] else {
                completion(false, "No subscriptions found or document does not exist.")
                return
            }
            
            if var serviceDetails = subscriptions[editedSub.serviceName] {
                serviceDetails["PlanName"] = editedSub.planName
                serviceDetails["Price"] = editedSub.planPrice
                serviceDetails["PersonCount"] = editedSub.personCount
                
                subscriptions[editedSub.serviceName] = serviceDetails
                
                userRef.updateData(["Subscriptions": subscriptions]) { error in
                    if let error = error {
                        completion(false, error.localizedDescription)
                    } else {
                        DispatchQueue.main.async {
                            if let index = self.userSubscriptions.firstIndex(where: { $0.serviceName == editedSub.serviceName }) {
                                self.userSubscriptions[index] = editedSub
                            }
                            completion(true, nil)
                        }
                    }
                }
            } 
            else {
                completion(false, "Service not found in user's subscriptions.")
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
            print("User's subscriptions have been successfully saved to SwiftData.")
        } catch {
            print("Failed to save user's subscriptions to SwiftData: \(error)")
        }
    }

    /// Removes a subscription from SwiftData.
    func removeUserSubscriptionFromSwiftData(selectedSub: UserSubscription, userSubsriptionsFromSWData: [UserSubscription], context: ModelContext, completion: @escaping (Bool) -> Void) {
        
        if let index = userSubsriptionsFromSWData.firstIndex(where: { $0.serviceName == selectedSub.serviceName }) {
            context.delete(userSubsriptionsFromSWData[index])
            
            do {
                try context.save()
                print("Subscription successfully removed from SwiftData.")
                completion(true)
            } catch {
                print("Failed to remove subscription from SwiftData: \(error)")
                completion(false)
            }
        }
    }
    
}
