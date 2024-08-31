import Foundation
import os.log

class PlanViewModel: ObservableObject {
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "PlanViewModel")
    
    /// Fetchs plans of selected service from 'Services' collection in Firestore.
    func fetchPlansOfServiceFromFirestore(documentID: String, completion: @escaping ([Plan]?, Error?) -> Void){
        FirestoreManager.shared.db.collection("Services").document(documentID).getDocument { (documentSnapshot, error) in
            
            if let error = error {
                self.logger.error("Fetching plans error: \(error.localizedDescription)")
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
                
                self.logger.info("Plans has been fetched successfully.")
                completion(plans, nil)
            } else {
                self.logger.error("Plan's document cannot be found or empty")
                completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Document not found or empty"]))
            }
        }
    }
    
}
