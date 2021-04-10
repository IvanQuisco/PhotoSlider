//
//  Post.swift
//  PhotoSlider
//
//  Created by Ivan Quintana on 07/04/21.
//

import Foundation

struct Post: Codable, Equatable, Hashable, Identifiable {
    var id: String
    var user: String
    var description: String
    var timestamp: TimeInterval
    var imageURL: String
    var likes: [String]
}
