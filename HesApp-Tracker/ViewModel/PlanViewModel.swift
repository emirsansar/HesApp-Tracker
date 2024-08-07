//
//  ServicePlanViewModel.swift
//  HesApp-Tracker
//
//  Created by Emir Sansar on 3.08.2024.
//

import Foundation

class PlanViewModel: ObservableObject {
    
    @Published var plans = [Plan]()
    
    
    func getPlansOfServiceFromFirestore(documentID: String, completion: @escaping ([Plan]?, Error?) -> Void){
        
        FirestoreManager.shared.db.collection("Services").document(documentID).getDocument { (documentSnapshot, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            if let document = documentSnapshot, document.exists {
                let data = document.data() ?? [:]
                var plans: [Plan] = []
                
                if let plansMap = data["Plans"] as? [String: Any] {
                    for (key, value) in plansMap {
                        if let planPrice = value as? Double {
                            let plan = Plan(planName: key, planPrice: planPrice)
                            plans.append(plan)
                        }
                    }
                }
                
                plans.sort { $0.planPrice < $1.planPrice }
                
                completion(plans, nil)
            } else {
                completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Document not found or empty"]))
            }
        }
        
    }
    
}
