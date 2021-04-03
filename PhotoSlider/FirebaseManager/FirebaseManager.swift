//
//  FirebaseManager.swift
//  PhotoSlider
//
//  Created by Ivan Quintana on 15/03/21.
//

import Foundation
import Combine
import Firebase

class FirebaseManager {
    let auth = Auth.auth()
    
    let storage = Storage.storage()
    
    var isUserLoggedIn: Bool {
        auth.currentUser != nil
    }
    
    func login(userRequest: User) -> AnyPublisher<FireResponse, FireError> {
        auth.signIn(email: userRequest.email, password: userRequest.password)
    }
    
    func logOut() -> Result<FireResponse, FireError> {
        do {
            try auth.signOut()
            return .success(.logOut)
        } catch {
            return .failure(.logOutError)
        }
    }
    
    func createUser(userRequest: User) -> AnyPublisher<FireResponse, FireError> {
        auth.createUser(email: userRequest.email, password: userRequest.password)
    }
    
    func getCurrentUser() -> Firebase.User? {
        return auth.currentUser
    }
    
    //TODOD - make it combine and TCA friendly
    func upload(imageData: Data) {
        let imageRef = storage.reference().child("images").child("profile").child("algo.jpg")
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        imageRef.putData(imageData, metadata: metaData) { (metaData, error) in
            //todo
        }
    }
    
    func downloadImages() -> AnyPublisher<[Data], StorageError> {
        let path = "images/profile/"
        return storage.getImagesData(for: path)
    }
}


public enum StorageError: Error {
    case queryError
    case translationError
    case timeoutError
}


extension Storage {
    
    public func getImagesData(for path: String) -> AnyPublisher<[Data], StorageError> {
        Future<[Data], StorageError> { promise in
            let ref  = self.reference().child(path)
            ref.listAll { (list, error) in
                if error != nil {
                    promise(.failure(.queryError))
                } else {
                    let expected = list.items.count
                    var count = 0
                    var dataSource: [Data?] = []
                    for item in list.items {
                        let itemRef = self.reference().child("\(path)\(item.name)")
                        itemRef.getData(maxSize: 1024*1024) { (data, dataError) in
                            count += 1
                            if let url = data {
                                dataSource.append(url)
                                if expected == count {
                                    promise(.success(dataSource.compactMap { $0 }))
                                }
                            } else if dataError != nil {
                                promise(.failure(.translationError))
                            } else {
                                promise(.failure(.timeoutError))
                            }
                        }
                    }
                }
            }
        }.eraseToAnyPublisher()
    }
    
}
