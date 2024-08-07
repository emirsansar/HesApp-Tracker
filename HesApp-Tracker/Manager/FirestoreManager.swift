//
//  FirestoreManager.swift
//  HesApp-Tracker
//
//  Created by Emir Sansar on 7.08.2024.
//

import Foundation
import FirebaseFirestore

class FirestoreManager {
    
    static var shared = FirestoreManager()
    
    let db: Firestore
    
    private init () {
        db = Firestore.firestore()
    }
    
}
