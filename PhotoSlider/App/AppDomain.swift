//
//  AppDomain.swift
//  PhotoSlider
//
//  Created by Ivan Quintana on 15/03/21.
//

import Foundation
import ComposableArchitecture

enum UIState: Hashable {
    case auth
    case home
}

struct AppState: Equatable {
    var uiState: UIState = .auth
    var authState: AuthState = .init()
    var sliderState: SliderState = .init()
}

enum AppAction: Equatable {
    case loginUser
    case registerUser
    case userAuthenticated
    case validateSession
    case authAction(AuthAction)
    case sliderAction(SliderAction)
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
    sliderReducer.pullback(
        state: \.sliderState,
        action: /AppAction.sliderAction,
        environment: { env -> SliderEnvironmnet in
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
            state.uiState = .home
            return .none
            
        case .validateSession:
            if environment.firebaseManager.isUserLoggedIn {
                return Effect(value: .userAuthenticated)
            }
            return .none
            
        case let .authAction(action):
            switch action {
            case .authResponse(.success(.loginSuccess(_))):
                state.uiState = .home
            default:
                break
            }
            return .none
            
        case let .sliderAction(action):
            switch action {
            case .logOutResult(.success(_)):
                state.uiState = .auth
            default:
                break
            }
            return .none
        }
    }

)
