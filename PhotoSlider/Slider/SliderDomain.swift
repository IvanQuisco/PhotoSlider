//
//  SliderDomain.swift
//  PhotoSlider
//
//  Created by Ivan Quintana on 20/03/21.
//

import Foundation
import ComposableArchitecture
import Firebase

enum PhotosPresentation {
    case all
    case user
}

struct SliderState: Equatable {

    var postsDataSource: [FormattedPost] = []
    
    var currentUser: Firebase.User?
    
    var isPickerViewPresented: Bool = false
    
    var selectedImageData: Data?
    
    var isActivityPresented: Bool = true
    
    var photosPresented: PhotosPresentation = .all
    
    var filteredPosts: [FormattedPost] {
        if photosPresented == .user {
            return postsDataSource.filter {
                $0.post.user == self.currentUser?.email
            }
        }
        return postsDataSource
    }
}

enum SliderAction: Equatable {
    
    //LifeCycle
    case onAppear
    
    //Logout
    case logOut
    case logOutResult(Result<FireResponse, FireError>)
    
    //UploadImages
    case presentPickerButtonTapped(Bool)
    case uploadPhotoButtonTapped
    case cancelButtonTapped
    case imageData(Data?)
    case uploadImageResponse(Result<URL, StorageError>)
    
    case uploadNewPost(URL)
    case uploadPostResponse(Result<HashableVoid, StorageError>)
    
    case updatePost(Post)
    case updatePostResponse(Result<HashableVoid, StorageError>)
    
    //DownloadImages
    case getPosts
    case postsReceived(Result<[Post], StorageError>)
    case cancelImagesSubscription
    
    case stopActivity
    
    case switchPhotosPresentation
    
    case post(index: Int, action: PostAction)
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

let sliderReducer = SliderReducer.combine(
    postReducer.forEach(
        state: \SliderState.postsDataSource,
        action: /SliderAction.post(index:action:),
        environment: { _ in PostEnvironment() }
    ),
    .init{ state, action, environment in
        struct GetPostsSubscriptionID: Hashable {}
        struct UploadSubscriptionID: Hashable {}
        struct UploadNewPostSubscriptionID: Hashable {}
        
        switch action {
        
        case .onAppear:
            state.currentUser = environment.firebaseManager.getCurrentUser()
            return Effect(value: .getPosts)
            
        case .getPosts:
            return environment
                .firebaseManager
                .getPosts()
                .catchToEffect()
                .map(SliderAction.postsReceived)
                .cancellable(id: GetPostsSubscriptionID())
            
        case let .postsReceived(result):
            switch  result {
            case let .success(data):
                state.isActivityPresented = false
                state.postsDataSource = data.map {
                    environment.firebaseManager.getFormattedPost(for: $0)
                }
            default:
                break
            }
            return .none
            
        case .cancelImagesSubscription:
        
        return Effect.cancel(id: GetPostsSubscriptionID())
            
        case .logOut:
            state.isActivityPresented = true
            return environment
                .firebaseManager
                .logOut()
                .publisher
                .catchToEffect()
                .map(SliderAction.logOutResult)
            
        case let .logOutResult(result):
            switch result {
            case .success:
                state.isActivityPresented = false
                state.postsDataSource = []
            default:
                break
            }
            return .none
            
        case let .presentPickerButtonTapped(value):
            state.isPickerViewPresented = value
            return .none
            
        case .uploadPhotoButtonTapped:
            state.isActivityPresented = true
            guard let data = state.selectedImageData else {
                state.isActivityPresented = false
                return .none
            }
            
            return environment
                .firebaseManager
                .uploadImage(data: data)
                .catchToEffect()
                .map(SliderAction.uploadImageResponse)
                .cancellable(id: UploadSubscriptionID())
            
        case let .uploadImageResponse(result):
            switch result {
            case let .success(url):
                return Effect(value: .uploadNewPost(url))
            case .failure:
                return .none
            }
            
        case let .uploadNewPost(url):
            return environment
                .firebaseManager
                .uploadNewPost(imageURL: url)
                .convertToVoidSignal()
                .catchToEffect()
                .map(SliderAction.uploadPostResponse)
                .cancellable(id: UploadNewPostSubscriptionID())
            
        case let .uploadPostResponse(result):
            switch result {
            case .success:
                state.selectedImageData = nil
                return Effect(value: .getPosts)
            case .failure:
                return .none
            }
            
        case .cancelButtonTapped:
            state.selectedImageData = nil
            return .none
            
        case let .imageData(data):
            state.selectedImageData = data
            return .none
            
        case .stopActivity:
            return .none
            
        case .switchPhotosPresentation:
            let current = state.photosPresented
            state.photosPresented = current == .all ? .user : .all
            return .none
            
        case .post(index: let index, action: .userLiked):
            var post = state.postsDataSource[index].post
            
            guard let user = state.currentUser?.email,
                  post.user != user else {
                return .none
            }

            post.likes.append(user)
            
            return Effect(value: .updatePost(post))
            
        case .post(index: let index, action: .userDisliked):
            var post = state.postsDataSource[index].post
            
            guard let user = state.currentUser?.email,
                  post.user != user,
                  let index = post.likes.firstIndex(of: user) else {
                return .none
            }
            
            post.likes.remove(at: index)
            
            return Effect(value: .updatePost(post))
            
        case let .updatePost(post):
            return environment
                .firebaseManager
                .updatePost(post: post)
                .convertToVoidSignal()
                .catchToEffect()
                .map(SliderAction.updatePostResponse)
                .cancellable(id: UploadNewPostSubscriptionID())
                
            
        case .updatePostResponse(_):
            //TODO: handle update error
            return Effect(value: .getPosts)
            
        case .post(index: let index, action: let action):
            return .none
            
        }
    }

)
