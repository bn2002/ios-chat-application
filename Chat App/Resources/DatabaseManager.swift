//
//  DatabaseManager.swift
//  Chat App
//
//  Created by Developer on 06/02/2023.
//

import Foundation
import FirebaseFirestore
import FirebaseCore

final class DatabaseManager {
    
    public static let shared = DatabaseManager()
    
    private let db = Firestore.firestore()
    
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
    
    public func isUserExist(email: String, completion: @escaping (Bool) -> Void ) {
        db.collection("users").whereField("email", isEqualTo: email).limit(to: 1).getDocuments { querySnapshot, error in
            
            if let snapshot = querySnapshot {
                completion(snapshot.documents.count > 0)
                return
            }
            
            completion(false)
            
        }
    }
    
    public func insertUser(with user: User, completion: @escaping (Bool) -> Void) {
        db.collection("users").addDocument(data: [
            "firstname": user.firstname,
            "lastname": user.lastname,
            "email": user.email,
            "photoUrl": "",
        ]) { error in
            if let _ = error {
                completion(false)
                return
            }
            
            completion(true)
        }
    }
}
