//
//  AppDomain.swift
//  PhotoSlider
//
//  Created by Ivan Quintana on 15/03/21.
//

import Foundation
import ComposableArchitecture

struct User {
    let email: String
    let password: String
}

enum UIState: Hashable {
    case login
    case registration
    case slider
}

struct AppState: Equatable {
    var uiState: UIState = .login
}

enum AppAction: Equatable {
    case loginUser
    case registerUser
    case userAuthenticated
    case validateSession
}

struct AppEnvironment {
    let firebaseManager = FirebaseManager()
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action, environment in
    switch action {
    
    case .loginUser:
        return .none
        
    case .registerUser:
        return .none
        
    case .userAuthenticated:
        state.uiState = .slider
        return .none
        
    case .validateSession:
        if environment.firebaseManager.validateSession {
            return Effect(value: .userAuthenticated)
        }
        return .none
    }
}
