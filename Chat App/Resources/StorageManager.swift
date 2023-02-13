//
//  StorageManager.swift
//  Chat App
//
//  Created by Developer on 10/02/2023.
//

import Foundation
import FirebaseCore
import FirebaseStorage

final class StorageManager {
    public static let shared = StorageManager()
    private let storageRef = Storage.storage().reference()
    
    public typealias UploadPictureCompletion = (Result<String, Error>) -> Void

    
    public func uploadImage(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion) {
        
        let userRef = storageRef.child("images\(fileName).png")
        
        let uploadTask = userRef.putData(data, metadata: nil) { (metadata, error) in
          guard let metadata = metadata else {
            // Uh-oh, an error occurred!
            return
          }
          // Metadata contains file metadata such as size, content-type.
          let size = metadata.size
          // You can also access to download URL after upload.
            userRef.downloadURL { (url, error) in
            guard let downloadURL = url else {

              return
            }
                
                print(downloadURL)
          }
        }
    }
}
