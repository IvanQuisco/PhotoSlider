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
    
    let db = Firestore.firestore()
    
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
    
    func uploadNewPost(imageURL: URL) -> AnyPublisher<Void, StorageError> {
        let post = Post(
            id: UUID().uuidString,
            user: (auth.currentUser?.email)!,
            description: "not supported",
            timestamp: Date().timeIntervalSince1970,
            imageURL: imageURL.absoluteString,
            likes: []
        )
        return self.db.uploadPost(post: post)
    }
    
    func updatePost(post: Post) -> AnyPublisher<Void, StorageError>  {
        //TODO: check logic here
        self.db.uploadPost(post: post)
    }
}
