//
//  UsersSubscriptionsViewModel.swift
//  HesApp-Tracker
//
//  Created by Emir Sansar on 3.08.2024.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class UsersSubscriptionsViewModel: ObservableObject {
    
    @Published var planAddingError: String?
    @Published var isAddingPlan: Bool = false
    @Published var planAddedSuccesfully: Bool = false
    
    @Published var userSubscriptions: [UsersSub] = []
    @Published var fetchingSubsError: String?
    @Published var isFetchingSubs: Bool = false
    
    @Published var fetchSubscriptionSummaryError: String?
    @Published var isGettingUserSubCountandSpending: Bool = false
    
    @Published var totalSubscriptionCount: Int = 0
    @Published var totalMonthlySpending: Double = 0.0
    
    
    func addPlanToUserOnFirestore(serviceName: String, plan: Plan, personCount: Int, completion: @escaping (Bool) -> Void) {
        let userEmail = Auth.auth().currentUser!.email! as String
        
        let db = Firestore.firestore()
        let userRef = db.collection("Users").document(userEmail)
        
        userRef.getDocument { documentSnapshot, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.planAddingError = "There is an error: \(error.localizedDescription)"
                    self.planAddedSuccesfully = false
                    self.isAddingPlan = false
                }
                return
                completion(false)
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

    
    func fetchUserSubscriptions(userEmail: String) {
        let db = Firestore.firestore()
        let userRef = db.collection("Users").document(userEmail)
        
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
            
            var fetchedSubscriptions: [UsersSub] = []
            
            for (serviceName, serviceDetails) in subscriptions {
               if let planName = serviceDetails["PlanName"] as? String,
                  let price = serviceDetails["Price"] as? Double,
                  let personCount = serviceDetails["PersonCount"] as? Int {
                   
                   let userSub = UsersSub(serviceName: serviceName, planName: planName, planPrice: price, personCount: personCount)
                   fetchedSubscriptions.append(userSub)
                   
               }
           }
           
           DispatchQueue.main.async {
               self.userSubscriptions = fetchedSubscriptions
           }
        }
        
    }


    
    func removeSubscriptionFromUser(selectedSub: UsersSub, completion: @escaping (Bool, Error?) -> Void) {
        guard let userEmail = Auth.auth().currentUser?.email else {
            completion(false, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "User is not found."]))
            return
        }
        
        let db = Firestore.firestore()
        let userRef = db.collection("Users").document(userEmail)
        
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
    
    
    func fetchSubscriptionsSummary(userEmail: String) {
        isGettingUserSubCountandSpending = true
        
//        guard let userEmail = Auth.auth().currentUser?.email else {
//            fetchSubscriptionSummaryError = "User is not found."
//            isGettingUserSubCountandSpending = false
//            return
//        }
        
        let db = Firestore.firestore()
        let userRef = db.collection("Users").document(userEmail)
        
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
            var serviceCount: Int = subscriptions.count
            
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
    
    
    private func replaceCommaWithDot(text: String) -> String {
        return text.replacingOccurrences(of: ",", with: ".")
    }

}
