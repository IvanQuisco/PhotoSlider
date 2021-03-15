//
//  FirebaseManager.swift
//  PhotoSlider
//
//  Created by Ivan Quintana on 15/03/21.
//

import Foundation
import Combine
import Firebase


struct FirebaseManager {
    let auth = Auth.auth()
    
    var validateSession: Bool {
        auth.currentUser != nil
    }
}
