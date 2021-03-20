//
//  SliderDomain.swift
//  PhotoSlider
//
//  Created by Ivan Quintana on 20/03/21.
//

import Foundation
import ComposableArchitecture

struct SliderState: Equatable {
    var imageDataSource: [String] = Array(1...10).map { "item \($0)" }
}

enum SliderAction: Equatable {
    case logOut
}

struct SliderEnvironmnet {
    var firebaseManager: FirebaseManager
}

typealias SliderReducer = Reducer<SliderState, SliderAction, SliderEnvironmnet>

let sliderReducer = SliderReducer { state, action, environment in
    switch action {
    case .logOut:
        print("TODO: perform log out")
        return .none
    }
}
