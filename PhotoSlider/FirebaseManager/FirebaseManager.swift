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
}
