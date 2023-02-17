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
    
    public func getUser(email: String) async -> User? {
        do {
            let querySnapshot = try await db.collection("users")
                            .whereField("email", isEqualTo: email)
                            .limit(to: 1)
                            .getDocuments()
            let documents = querySnapshot.documents
            if(documents.count < 1) {
                return nil
            }
            
            let data = documents.first?.data()
            guard let data = data else {
                return nil
            }
            
            let firstname = data["firstname"] as? String ?? ""
            let lastname = data["lastname"] as? String ?? ""
            let photoURL = data["photoUrl"] as? String ?? ""
            return User(firstname: firstname, lastname: lastname, email: email, photoUrl: photoURL)
        } catch {
            print(error.localizedDescription)
            
        }
        
        return nil
        
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
    
    public func getPhotoUser(userEmail: String) async -> String{
        var photoURL: String = ""
        do {
            let querySnapshot = try await db.collection("users")
                .whereField("email", isEqualTo: userEmail)
                .getDocuments()
            guard let document = querySnapshot.documents.first else {
                return ""
            }
            
            let userData = document.data()
            photoURL = userData["photoUrl"] as? String ?? ""
        } catch {
            print("Lấy avatar user thất bại")
        }
        
        return photoURL
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
    
    public func fetchContact(email: String) async -> [[String: Any]] {
        var result = [[String: Any]]()
        do {
            let querySnapshot = try await db.collection("contacts").whereField("email", isEqualTo: email).getDocuments()
            let documents = querySnapshot.documents
            for document in documents {
                let data = document.data()
                let contactEmail = data["contactEmail"] as? String ?? ""
                let conversationID = data["conversationID"] as? String ?? ""
                if conversationID.isEmpty {
                    continue
                }
                
                let user = await self.getUser(email: contactEmail)
                guard let user = user else {
                    print("Khong lay duoc user")
                    continue
                }
                let lastMessage = await self.getLasestMessage(conversationID: conversationID)

                let contact: [String : Any] = [
                    "conversationID": conversationID,
                    "contactAvatar": user.photoUrl!,
                    "email": contactEmail,
                    "fullname": user.firstname + " " + user.lastname,
                    "lastMessage": lastMessage
                ]
                print(contact)
                result.append(contact)
            }
        } catch {
            print(error.localizedDescription)
        }
        
        return result
    }
    
    public func checkContactsExist(with receiveEmail: String, completion: @escaping (Result<Bool, Error>) -> Void ) -> Void {
        guard let currentEmail = Auth.auth().currentUser?.email else {
            completion(.failure(MyError.getCurrentEmailError))
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: currentEmail)
        db.collection("contacts")
        .whereField("email", isEqualTo: currentEmail)
        .whereField("contactEmail", isEqualTo: receiveEmail)
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
    
    
    public func createConversattion(conversation: Conversation) -> String {
        let ref = db.collection("conversations").addDocument(data: [
            "createdAt": Date()
        ])
        
        return ref.documentID
    }
    
    public func getConversationID(fromEmail: String, toEmail: String) async -> String {
        do {
            let snapshot = try await db.collection("contacts")
                .whereField("email", isEqualTo: fromEmail)
                .whereField("contactEmail", isEqualTo: toEmail)
                .limit(to: 1)
                .getDocuments()
            if(snapshot.documents.count > 0) {
                for document in snapshot.documents {
                    let data = document.data()
                    return data["conversationID"] as? String ?? ""
                }
            }

        } catch {
            print(error.localizedDescription)
        }
        
        return ""
        
    }
    
    public func createContact(contact: Contact) {
        db.collection("contacts").addDocument(data: [
            "email": contact.email,
            "conversationID": contact.conversationID,
            "contactEmail": contact.contactEmail
        ])
    }
    
    public func createMessage(message: Message) {
        db.collection("messages").addDocument(data: [
            "fromUser": message.fromUser,
            "conversationID": message.conversationID,
            "content": message.content,
            "isSeen": false,
            "createdAt": message.createdAt
        ])
    }
    
    public func fetchMessage(conversationID: String, completion: @escaping (QuerySnapshot?, Error?) -> Void) {
        db.collection("messages")
            .whereField("conversationID", isEqualTo: conversationID)
            .order(by: "createdAt")
            .addSnapshotListener(completion)
    }
    
    public func getLasestMessage(conversationID: String) async -> Message? {
        do {
            let querySnapshot = try await db.collection("messages")
                    .whereField("conversationID", isEqualTo: conversationID)
                    .order(by: "createdAt", descending: true).limit(to: 1)
                    .getDocuments()
            if(querySnapshot.documents.count > 0) {
                let data = querySnapshot.documents.first?.data()
                guard let data = data else {
                    return nil
                }
                let fromUser = data["fromUser"] as? String ?? ""
                let type = data["type"] as? String ?? ""
                let content = data["content"] as? String ?? ""
                let isSeen = data["isSeen"] as? Bool ?? false
                let date = Date()
                
                return Message(conversationID: conversationID, fromUser: fromUser, type: type, content: content, isSeen: isSeen, createdAt: date)
            }
            
            
        } catch{
            print(error.localizedDescription)
        }
        
        return nil
        
    }
}
