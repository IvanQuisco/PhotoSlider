//
//  Firestore+ext.swift
//  PhotoSlider
//
//  Created by Ivan Quintana on 07/04/21.
//

import Foundation
import Combine
import Firebase

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
    
    func getAllPosts() -> AnyPublisher<[Post], StorageError> {
        Future<[Post], StorageError> { promise in
            self.collection("posts").getDocuments { (snapshot, error) in
                if error != nil {
                    
                    promise(.failure(.taskError))
                    
                } else if let snapshot = snapshot {
                    do  {
                        
                        let posts = try snapshot.documents.map { doc -> Post in
                            return try JSONDecoder()
                                .decode(
                                    Post.self,
                                    from: try JSONSerialization.data(
                                        withJSONObject: doc.data(),
                                        options: .fragmentsAllowed
                                    )
                                )
                        }.sorted(by: { $0.timestamp > $1.timestamp })
                        
                        promise(.success(posts))
                        
                    } catch {
                        
                        promise(.failure(.firestoreError))
                    }
                    
                }else {
                    
                    promise(.failure(.taskError))
                }
            }
        
        }.eraseToAnyPublisher()
    }
}
