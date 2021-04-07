//
//  Firestore+ext.swift
//  PhotoSlider
//
//  Created by Ivan Quintana on 07/04/21.
//

import Foundation
import Combine
import Firebase

struct Post: Codable {
    var id: String
    var user: String
    var description: String
    var timestamp: TimeInterval
    var imageURL: String
    var likes: [String]
}

extension Firestore {
    func uploadPost(post: Post) -> AnyPublisher<Void, StorageError> {
        Future<Void, StorageError> { promise in
            do {
                let data = try JSONEncoder().encode(post)
                
                guard let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
                    return promise(.failure(.invalidPost))
                }
    
                self.collection("posts").document(post.id).setData(json) { error in
                    if error != nil {
                        
                        promise(.failure(.firestoreError))
                        
                    } else {
                        
                        promise(.success(()))
                        
                    }
                }
            } catch {
                
                promise(.failure(.invalidPost))
                
            }
        }.eraseToAnyPublisher()
    }
}
