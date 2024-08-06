//
//  ServiceViewModel.swift
//  HesApp-Tracker
//
//  Created by Emir Sansar on 3.08.2024.
//

import Foundation
import FirebaseFirestore

class ServiceViewModel: ObservableObject {
    
    @Published var services = [Service]()

    
    func getServicesFromFirestore(completion: @escaping ([Service]?, Error?) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("Services").getDocuments { (querySnapshot, error) in
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
