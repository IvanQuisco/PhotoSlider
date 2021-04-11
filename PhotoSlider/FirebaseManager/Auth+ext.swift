//
//  Auth+ext.swift
//  PhotoSlider
//
//  Created by Ivan Quintana on 20/03/21.
//

import Foundation
import Firebase
import Combine

public enum FireError: Error, Equatable {
    case callError
    case noConnection
    case unknown
    case logOutError
    
    init(_ error: Error) {
        self = .unknown
    }
}

public enum FireResponse: Equatable {
    case loginSuccess(AuthDataResult)
    case userCreated(AuthDataResult)
    case logOut
}

extension Auth {
    public func signIn(email: String, password: String) -> AnyPublisher<FireResponse, FireError> {
        Future<FireResponse, FireError> { [weak self] promise in
            self?.signIn(withEmail: email, password: password, completion: { (auth, error) in
                if let error = error {
                    promise(.failure(.init(error)))
                } else if let auth = auth {
                    promise(.success(.loginSuccess(auth)))
                }
            })
        }.eraseToAnyPublisher()
    }
    
    public func createUser(email: String, password: String) -> AnyPublisher<FireResponse, FireError> {
        Future<FireResponse, FireError> { [weak self] promise in
            self?.createUser(withEmail: email, password: password, completion: { (auth, error) in
                if let error = error {
                    promise(.failure(.init(error)))
                } else if let auth = auth {
                    promise(.success(.userCreated(auth)))
                }
            })
            
        }.eraseToAnyPublisher()
    }
}
