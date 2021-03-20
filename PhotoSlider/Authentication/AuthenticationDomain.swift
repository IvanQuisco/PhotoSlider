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

extension User {
    var validCretentials: Bool {
        !email.isEmpty && !password.isEmpty
    }
}

struct AuthState: Equatable {
    var loginUser: User = User()
    var newUser: User = User()
    var passwordConfirmation: String = ""
    var signUpMatchingPasswords: Bool = false
    
    var isSignUpButtonEnabled: Bool {
        newUser.validCretentials && signUpMatchingPasswords
    }
    
    var isLogInButtonEnabled: Bool {
        loginUser.validCretentials
    }
}

enum AuthAction: Equatable {    
    case loginEmail(String)
    case loginPassword(String)
    case loginButtonTapped
    
    case signUpEmail(String)
    case signUpPassword(String)
    case signUpPasswordConfirmation(String)
    case signUpButtonTapped
    case createNewUser
    
    case authResponse(Result<FireResponse, FireError>)
}

struct AuthEnvironment {
    var firebaseManager: FirebaseManager
}

typealias AuthReducer = Reducer<AuthState, AuthAction, AuthEnvironment>

let authReducer = AuthReducer { state, action, environment in
    switch action {
        
    // MARK: - Log in
    
    case let .loginEmail(text):
        state.loginUser.email = text
        return .none
        
    case let .loginPassword(text):
        state.loginUser.password = text
        return .none
        
    case .loginButtonTapped:
        return environment
            .firebaseManager
            .login(userRequest: state.loginUser)
            .catchToEffect()
            .map(AuthAction.authResponse)

    // MARK: -  Sign up
        
    case let .signUpEmail(text):
        state.newUser.email = text
        return .none
        
    case let .signUpPassword(text):
        state.newUser.password = text
        state.signUpMatchingPasswords = text == state.passwordConfirmation
        return .none
        
    case let .signUpPasswordConfirmation(text):
        state.passwordConfirmation = text
        state.signUpMatchingPasswords = text == state.newUser.password
        return .none
        
    case .signUpButtonTapped:
        return environment
            .firebaseManager
            .createUser(userRequest: state.newUser)
            .catchToEffect()
            .map(AuthAction.authResponse)
        
    case .createNewUser:
        return .none
        
    // MARK: - Firebase task Response
    
    case let .authResponse(result):
        switch result {
        case let .success(.loginSuccess(data)):
            state.loginUser.password = ""
            
        case let .success(.userCreated(data)):
            state.newUser = User()
            state.loginUser = User(email: data.user.email ?? "", password: "")
            state.passwordConfirmation = ""
            
        case let .failure(error):
            // User feedback
            print(error)
            
        default:
            break
        }
        
        return .none
    }
}
