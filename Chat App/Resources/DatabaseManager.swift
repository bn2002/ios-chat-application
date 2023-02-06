//
//  DatabaseManager.swift
//  Chat App
//
//  Created by Developer on 06/02/2023.
//

import Foundation
import FirebaseFirestore
import FirebaseDatabase

final class DatabaseManager {
    
    public static let shared = DatabaseManager()
    
    private let db = Firestore.firestore()
    private let database = Database.database().reference()
    
    static func safeEmail(emailAddress: String) -> String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
}

extension DatabaseManager {
    public func getDataFor(path: String, completion: @escaping (Result<Any, Error>) -> Void) {
        db.collection("users").whereField("username", isEqualTo: path).limit(to: 1).getDocuments { querySnapshot, error in
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let querySnapshot = querySnapshot else {
                
                return
            }
            
            if(querySnapshot.isEmpty == true) {
                print("Khong ton tai")
                return
            }
            
            
            for document in querySnapshot.documents {
                completion(.success(document.data()))
            }
            
        }
    }
    
    public func insertUser() {
//        db.collection("users").addDocument(data: [
//            "first_name": "Doanh",
//            "last_name": "Duy",
//            "username": "test12@gmail.com"
//        ]) { error in
//            print("Success")
//        }
        
    }
}
