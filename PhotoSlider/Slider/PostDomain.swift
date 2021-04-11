//
//  PostDomain.swift
//  PhotoSlider
//
//  Created by Ivan Quintana on 10/04/21.
//

import Foundation
import ComposableArchitecture

enum PostAction: Equatable {
    case evaluateLikes
    case userLiked
    case userDisliked
}

struct PostEnvironment {}

typealias PostReducer = Reducer<FormattedPost, PostAction, PostEnvironment>

let postReducer = PostReducer { state, action, enviroment in
    switch action {
    
    ///These methodos are mostly to trigger a pullback in the father domain.
    
    case .evaluateLikes:
        return Effect(value: state.likedByUser ? .userDisliked : .userLiked)
        
    case .userLiked:
        return .none
        
    case .userDisliked:
        return .none
    }
}
