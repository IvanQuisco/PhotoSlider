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
    
    func uploadImage(data: Data) -> AnyPublisher<Void, StorageError> {
        storage.uploadImage(data: data)
    }
    
    func downloadImages() -> AnyPublisher<[IdentifiableData], StorageError> {
        let path = "images/profile/"
        return storage.getImagesData(for: path)
    }
}


public enum StorageError: Error {
    case queryError
    case translationError
    case timeoutError
    case taskError
}


extension Storage {
    
    public func uploadImage(data: Data, name: String = UUID().uuidString) -> AnyPublisher<Void, StorageError> {
        Future<Void, StorageError> { [weak self] promise in
            
            let ref = self?.reference().child("images").child("profile").child(name)
            
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpeg"
            
            ref?.putData(data, metadata: metaData, completion: { (data, error) in
                if error != nil {
                    promise(.failure(.taskError))
                } else {
                    promise(.success(()))
                }
            })
            
        }.eraseToAnyPublisher()
    }
    
    public func getImagesData(for path: String) -> AnyPublisher<[IdentifiableData], StorageError> {
        Future<[IdentifiableData], StorageError> { promise in
            let ref  = self.reference().child(path)
            ref.listAll { (list, error) in
                if error != nil {
                    promise(.failure(.queryError))
                } else {
                    let expected = list.items.count
                    var count = 0
                    var dataSource: [IdentifiableData] = []
                    for item in list.items {
                        let itemRef = self.reference().child("\(path)\(item.name)")
                        itemRef.getData(maxSize: 1024*1024) { (data, dataError) in
                            count += 1
                            if let url = data {
                                dataSource.append(IdentifiableData(id: item.name, data: url))
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
