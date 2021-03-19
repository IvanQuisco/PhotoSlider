//
//  AuthenticationDomain.swift
//  PhotoSlider
//
//  Created by Ivan Quintana on 19/03/21.
//

import Foundation
import ComposableArchitecture

struct User: Equatable {
    var email: String = ""
    var password: String = ""
}

struct AuthState: Equatable {
    var loginUser: User = User()
    let newUser: User = User()
}

enum AuthAction: Equatable {
    case createNewUser
    case loginEmail(String)
    case loginPassword(String)
    case loginButtonTapped
    case signUpButtonTapped
}

struct AuthEnvironment {
    var firebaseManager: FirebaseManager
}

typealias AuthReducer = Reducer<AuthState, AuthAction, AuthEnvironment>

let authReducer = AuthReducer { state, action, environment in
    switch action {
    case .createNewUser:
        return .none
        
    case let .loginEmail(text):
        state.loginUser.email = text
        return .none
        
    case let .loginPassword(text):
        state.loginUser.password = text
        return .none
    case .loginButtonTapped:
        // TODO firebase login with state.loginUser
        return .none
        
    case .signUpButtonTapped:
        // TODO present sign up screen
        return .none
    }
}
.debug()
