import Foundation
import FirebaseFirestore

class FirestoreManager {
    
    static var shared = FirestoreManager()
    
    let db: Firestore
    
    private init () {
        db = Firestore.firestore()
    }
    
}
