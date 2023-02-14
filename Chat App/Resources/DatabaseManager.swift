//
//  DatabaseManager.swift
//  Chat App
//
//  Created by Developer on 06/02/2023.
//

import Foundation
import FirebaseFirestore
import FirebaseCore
import FirebaseAuth

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
        db.collection("users").whereField("email", isEqualTo: path).limit(to: 1).getDocuments { querySnapshot, error in
            
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
    
    public func insertUser(with user: User, completion: @escaping (Bool, String) -> Void) {
        var ref: DocumentReference? = nil
        ref = db.collection("users").addDocument(data: [
            "firstname": user.firstname,
            "lastname": user.lastname,
            "email": user.email,
            "photoUrl": "",
        ]) { error in
            if let _ = error {
                completion(false, "")
                return
            }
            completion(true, ref!.documentID)
        }
    }
    
    public func setPhotoUser(with documentID: String, photoURL: String) {
        var ref: DocumentReference? = nil
        ref = db.collection("users").document(documentID)
        ref?.updateData(["photoUrl": photoURL])
    }
    
    public func searchUser(with user: String, completion: @escaping ([User]) -> Void) {
        let currentEmail = Auth.auth().currentUser?.email
        db.collection("users")
            .whereField("email", isGreaterThanOrEqualTo: user.lowercased())
            .whereField("email", isNotEqualTo: currentEmail)
                .limit(to: 5)
        .getDocuments { querySnapshot, error in
            guard let querySnapshot = querySnapshot  else {
                print("Khong ton tai")
                return
            }
            
            var result = [User]()
            let decoder = JSONDecoder()
            for document in querySnapshot.documents {
                let data = document.data()
                let firstname = data["firstname"] as? String ?? ""
                let lastname = data["lastname"] as? String ?? ""
                let email = data["email"] as? String ?? ""
                let photoURL = data["photoUrl"] as? String ?? ""
                
                let user = User(firstname: firstname, lastname: lastname, email: email, photoUrl: photoURL)
                
                result.append(user)
            }
            
            completion(result)
        }
    }
    
    public func checkContactsExist(with receiveEmail: String, completion: @escaping (Result<Bool, Error>) -> Void ) -> Void {
        guard let currentEmail = Auth.auth().currentUser?.email else {
            completion(.failure(MyError.getCurrentEmailError))
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: currentEmail)
        db.collection("contacts")
        .whereField("user_email", isEqualTo: currentEmail)
        .whereField("contact_email", isEqualTo: receiveEmail)
        .getDocuments { querySnapshot, error in
            guard let querySnapshot = querySnapshot else {
                completion(.failure(MyError.querySnapshotError))
                return
            }
            
            if(querySnapshot.isEmpty) {
                completion(.success(false))
                return
            }
            
            completion(.success(true))
        }
        
    }
    
    public func createConversattion(conversation: Conversation, completion: @escaping (Result<String, Error>) -> Void)
    {
        var ref: DocumentReference? = nil
        ref = db.collection("conversations").addDocument(data: [
            "userOne": conversation.userOne,
            "userTwo": conversation.userTwo,
            "createdAt": Date()
        ]){ error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
            completion(.success(ref!.documentID))
        }
    }
    
    public func createContact(data contact: Contact) {
        db.collection("contacts").addDocument(data: [
            "email": contact.email,
            "contactEmail": contact.contactEmail
        ])
    }
}
