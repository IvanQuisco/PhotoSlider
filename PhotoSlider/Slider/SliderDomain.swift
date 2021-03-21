//
//  SliderDomain.swift
//  PhotoSlider
//
//  Created by Ivan Quintana on 20/03/21.
//

import Foundation
import ComposableArchitecture
import Firebase

struct SliderState: Equatable {
    var imageDataSource: [String] = Array(1...10).map { "item \($0)" }
    var currentUser: Firebase.User?
}

enum SliderAction: Equatable {
    case onAppear
    case logOut
    case logOutResult(Result<FireResponse, FireError>)
}

struct SliderEnvironmnet {
    var firebaseManager: FirebaseManager
    var mainQueue: AnySchedulerOf<DispatchQueue>
}

extension SliderEnvironmnet {
    static let `default` = Self.init(
        firebaseManager: FirebaseManager(),
        mainQueue: DispatchQueue.main.eraseToAnyScheduler()
    )
}

typealias SliderReducer = Reducer<SliderState, SliderAction, SliderEnvironmnet>

let sliderReducer = SliderReducer { state, action, environment in
    switch action {
    case .onAppear:
        state.currentUser = environment.firebaseManager.getCurrentUser()
        return .none
    case .logOut:
        return environment
            .firebaseManager
            .logOut()
            .publisher
            .catchToEffect()
            .map(SliderAction.logOutResult)
        
    case let .logOutResult(result):
        return .none
    }
}
