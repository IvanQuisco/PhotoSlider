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
    
    var isActivityPresented: Bool = false
}

enum AppAction: Equatable {
    case loginUser
    case registerUser
    case userAuthenticated
    case validateSession
    case authAction(AuthAction)
    case sliderAction(SliderAction)
    
    case stopActivity
}

struct AppEnvironment {
    var firebaseManager: FirebaseManager
    var mainQueue: AnySchedulerOf<DispatchQueue>
}

extension AppEnvironment {
    static let `default` = Self.init(
        firebaseManager: FirebaseManager(),
        mainQueue: DispatchQueue.main.eraseToAnyScheduler()
    )
}

typealias AppReducer = Reducer<AppState, AppAction, AppEnvironment>

let appReducer = AppReducer.combine(
    authReducer.pullback(
        state: \.authState,
        action: /AppAction.authAction,
        environment: { env -> AuthEnvironment in
            .init(
                firebaseManager: env.firebaseManager,
                mainQueue: env.mainQueue
            )
        }
    ),
    sliderReducer.pullback(
        state: \.sliderState,
        action: /AppAction.sliderAction,
        environment: { env -> SliderEnvironmnet in
            .init(
                firebaseManager: env.firebaseManager,
                mainQueue: env.mainQueue
            )
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
                state.authState.loginUser.email = environment.firebaseManager.getCurrentUser()?.email ?? ""
                return Effect(value: .userAuthenticated)
            }
            return .none
            
        case let .authAction(action):
            switch action {
            case .loginButtonTapped, .signUpButtonTapped:
                state.isActivityPresented = true
            case let .authResponse(.success(.loginSuccess(data))):
                state.isActivityPresented = false
                state.sliderState.currentUser = data.user
                state.uiState = .home
            case let .authResponse(.success(.userCreated(data))):
                state.isActivityPresented = false
                state.sliderState.currentUser = data.user
                state.uiState = .home
            case let .authResponse(.failure(error)):
                print(error)
                state.isActivityPresented = false
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
            
        case .stopActivity:
            return .none
        }
    }

)
