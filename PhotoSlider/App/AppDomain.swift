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
    case validateUser
}

struct AppEnvironment {}

let appReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action, environment in
    switch action {
    case .loginUser:
        return .none
    case .registerUser:
        return .none
    case .userAuthenticated:
        return .none
    case .validateUser:
        return .none
    }
}
