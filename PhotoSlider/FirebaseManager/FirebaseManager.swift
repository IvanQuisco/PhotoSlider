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
    
    func uploadImage(data: Data) -> AnyPublisher<URL, StorageError> {
        guard let user = auth.currentUser else {
            return Fail(error: StorageError.invalidUser).eraseToAnyPublisher()
        }
        
        return storage.uploadImage(userID: user.uid, imageData: data)
    }
    
    func downloadImages() -> AnyPublisher<[URL], StorageError> {
        guard let user = auth.currentUser else {
            return Fail(error: StorageError.invalidUser).eraseToAnyPublisher()
        }
        let path = "\(user.uid)/photos/"
        return storage.getImagesData(for: path)
    }
}


public enum StorageError: Error {
    case queryError
    case translationError
    case timeoutError
    case taskError
    case invalidUser
}


extension Storage {
    
    public func uploadImage(userID: String, imageData: Data, imageName: String = UUID().uuidString) -> AnyPublisher<URL, StorageError> {
        Future<URL, StorageError> { [weak self] promise in
            
            let uploadRef = self?.reference().child(userID).child("photos").child(imageName)
            
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpeg"
            
            uploadRef?.putData(imageData, metadata: metaData, completion: { (data, error) in
                
                if error != nil {
                    
                    promise(.failure(.taskError))
                    
                } else {
                    
                    uploadRef?.downloadURL { (url, error) in
                        
                        if let url = url {
                            
                            promise(.success(url))
                            
                        } else {
                            
                            promise(.failure(.taskError))
                            
                        }
                    }
                }
            })
            
        }.eraseToAnyPublisher()
    }
    
    public func getImagesData(for path: String) -> AnyPublisher<[URL], StorageError> {
        Future<[URL], StorageError> { promise in
            let ref  = self.reference().child(path)
            ref.listAll { (list, error) in
                if error != nil {
                    promise(.failure(.queryError))
                } else {
                    
                    let expected = list.items.count
                    var count = 0
                    var dataSource: [URL] = []
                    
                    if expected == 0 {
                        promise(.success([]))
                    }
                    
                    for item in list.items {
                        let itemRef = self.reference().child("\(path)\(item.name)")
                        itemRef.downloadURL { (data, dataError) in
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
