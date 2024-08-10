import Foundation

class ServiceViewModel: ObservableObject {
    
    @Published var services = [Service]()

    /// Fetchs all services from 'Services' collection in Firestore.
    func fetchServicesFromFirestore(completion: @escaping ([Service]?, Error?) -> Void) {
        
        FirestoreManager.shared.db.collection("Services").getDocuments { (querySnapshot, error) in
            if let error = error {
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
            
            completion(services, nil)
        }
        
    }
    
}
