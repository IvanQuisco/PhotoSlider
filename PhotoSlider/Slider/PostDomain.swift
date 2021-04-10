//
//  PostDomain.swift
//  PhotoSlider
//
//  Created by Ivan Quintana on 10/04/21.
//

import Foundation
import ComposableArchitecture

enum PostAction: Equatable {
    case likePost
}

struct PostEnvironment {}

typealias PostReducer = Reducer<Post, PostAction, PostEnvironment>

let postReducer = PostReducer { state, action, enviroment in
    switch action {
    case .likePost:
        return .none
    }
}
