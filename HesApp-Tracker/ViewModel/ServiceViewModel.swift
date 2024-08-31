import Foundation
import SwiftData
import os.log

class ServiceViewModel: ObservableObject {
    
    @Published var services = [Service]()
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "ServiceViewModel")
    
    
// MARK: - Firestore
    
    /// Fetches all services from the 'Services' collection in Firestore.
    func fetchServicesFromFirestore(completion: @escaping ([Service]?, Error?) -> Void) {
        FirestoreManager.shared.db.collection("Services").getDocuments { (querySnapshot, error) in
            if let error = error {
                self.logger.error("Error fetching services from Firestore: \(error.localizedDescription)")
                completion(nil, error)
                return
            }
            
            var services: [Service] = []
            
            for document in querySnapshot!.documents {
                let data = document.data()
                let serviceName = document.documentID
                let serviceType = data["Type"] as? String ?? ""
                
                let service = Service(serviceName: serviceName, serviceType: serviceType)
                services.append(service)
            }
            
            self.logger.info("Successfully fetched \(services.count) services from Firestore.")
            completion(services, nil)
        }
    }
    
// MARK: - SwiftData
    
    /// Saves an array of Service models to SwiftData.
    func saveServicesToSwiftData(services: [Service], context: ModelContext) {
        for service in services {
            context.insert(service)
        }
        
        do {
            try context.save()
            self.logger.info("Services have been successfully saved to SwiftData.")
        } catch {
            self.logger.error("Failed to save services to SwiftData: \(error.localizedDescription)")
        }
    }
  
}
