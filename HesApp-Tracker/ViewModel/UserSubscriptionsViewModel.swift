import Foundation
import FirebaseFirestore

class UserSubscriptionsViewModel: ObservableObject {
    
    @Published var planAddingError: String?
    @Published var isAddingPlan: Bool = false
    @Published var planAddedSuccesfully: Bool = false
    
    @Published var userSubscriptions: [UserSubscription] = []
    @Published var fetchingSubsError: String?
    @Published var isFetchingSubs: Bool = false
    
    @Published var fetchSubscriptionSummaryError: String?
    @Published var isGettingUserSubCountandSpending: Bool = false
    
    @Published var totalSubscriptionCount: Int = 0
    @Published var totalMonthlySpending: Double = 0.0
    
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
    func fetchUserSubscriptions() {

        let userRef = FirestoreManager.shared.db.collection("Users").document(AuthManager.shared.currentUserEmail!)
        
        userRef.getDocument { documentSnapshot, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.fetchingSubsError = "An error occurred: \(error.localizedDescription)"
                }
                return
            }
            
            guard let document = documentSnapshot, document.exists,
                  let subscriptions = document.data()?["Subscriptions"] as? [String: [String: Any]] else {
                DispatchQueue.main.async {
                    self.fetchingSubsError = "There are no subscriptions."
                }
                return
            }
            
            var fetchedSubscriptions: [UserSubscription] = []
            
            for (serviceName, serviceDetails) in subscriptions {
               if let planName = serviceDetails["PlanName"] as? String,
                  let planPrice = serviceDetails["Price"] as? Double,
                  let personCount = serviceDetails["PersonCount"] as? Int {
                   
                   let plan = Plan(planName: planName, planPrice: planPrice)
                   let userSub = UserSubscription(serviceName: serviceName, plan: plan, personCount: personCount)
                   fetchedSubscriptions.append(userSub)
               }
           }
           
           DispatchQueue.main.async {
               self.userSubscriptions = fetchedSubscriptions
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
    func fetchSubscriptionsSummary() {
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
            }
        }
        
    }

}
