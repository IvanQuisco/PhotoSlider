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
    
    var imageDataSource: [URL] = []
    
    var currentUser: Firebase.User?
    
    var isPickerViewPresented: Bool = false
    
    var selectedImageData: Data?
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
    case uploadResponse(Result<HasableVoid, StorageError>)
    
    //DownloadImages
    case getImages
    case imagesDataReceived(Result<[URL], StorageError>)
    case cancelImagesSubscription
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
    struct ImagesSubscriptionID: Hashable {}
    struct UploadSubscriptionID: Hashable {}
    
    switch action {
    
    case .onAppear:
        state.currentUser = environment.firebaseManager.getCurrentUser()
        return Effect(value: .getImages)
        
    case .getImages:
        return environment
            .firebaseManager
            .downloadImages()
            .catchToEffect()
            .map(SliderAction.imagesDataReceived)
            .cancellable(id: ImagesSubscriptionID())
        
    case let .imagesDataReceived(result):
        switch  result {
        case let .success(data):
            state.imageDataSource = data
        default:
            break
        }
        return .none
        
    case .cancelImagesSubscription:
    
    return Effect.cancel(id: ImagesSubscriptionID())
        
    case .logOut:
        return environment
            .firebaseManager
            .logOut()
            .publisher
            .catchToEffect()
            .map(SliderAction.logOutResult)
        
    case let .logOutResult(result):
        switch result {
        case .success:
            state.imageDataSource = []
        default:
            break
        }
        return .none
        
    case let .presentPickerButtonTapped(value):
        state.isPickerViewPresented = value
        return .none
        
    case .uploadPhotoButtonTapped:
        guard let data = state.selectedImageData else {
            return .none
        }
        
        return environment
            .firebaseManager
            .uploadImage(data: data)
            .convertToVoidSignal()
            .catchToEffect()
            .map(SliderAction.uploadResponse)
            .cancellable(id: UploadSubscriptionID())
        
    case let .uploadResponse(result):
        switch result {
        case .success:
            state.selectedImageData = nil
            return Effect(value: .getImages)
            
        case .failure:
            return .none
        }
        
    case .cancelButtonTapped:
        state.selectedImageData = nil
        return .none
        
    case let .imageData(data):
        state.selectedImageData = data
        return .none
    }
}
