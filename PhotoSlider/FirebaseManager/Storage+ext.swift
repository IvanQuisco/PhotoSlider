//
//  Storage+ext.swift
//  PhotoSlider
//
//  Created by Ivan Quintana on 07/04/21.
//

import Foundation
import Combine
import Firebase

public enum StorageError: Error {
    case queryError
    case translationError
    case timeoutError
    case taskError
    case invalidUser
    
    case firestoreError
    case invalidPost
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

