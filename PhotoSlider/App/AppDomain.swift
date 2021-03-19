//
//  AppDomain.swift
//  PhotoSlider
//
//  Created by Ivan Quintana on 15/03/21.
//

import Foundation
import ComposableArchitecture

enum UIState: Hashable {
    case login
    case registration
    case slider
}

struct AppState: Equatable {
    var uiState: UIState = .login
    var authState: AuthState = .init()
}

enum AppAction: Equatable {
    case loginUser
    case registerUser
    case userAuthenticated
    case validateSession
    case authAction(AuthAction)
}

struct AppEnvironment {
    var firebaseManager = FirebaseManager()
}

typealias AppReducer = Reducer<AppState, AppAction, AppEnvironment>

let appReducer = AppReducer.combine(
    authReducer.pullback(
        state: \.authState,
        action: /AppAction.authAction,
        environment: { env -> AuthEnvironment in
            .init(firebaseManager: env.firebaseManager)
        }
    ),
    .init { state, action, environment in
        switch action {
        
        case .loginUser:
            return .none
            
        case .registerUser:
            return .none
            
        case .userAuthenticated:
            state.uiState = .slider
            return .none
            
        case .validateSession:
            if environment.firebaseManager.isUserLoggedIn {
                return Effect(value: .userAuthenticated)
            }
            return .none
            
        case .authAction(_):
            return .none
        }
    }

)
