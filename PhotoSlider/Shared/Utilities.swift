//
//  Utilities.swift
//  PhotoSlider
//
//  Created by Ivan Quintana on 20/03/21.
//

import Foundation
import Combine

struct HashableVoid: Hashable {}

extension Combine.Publisher {
    func convert<T>(to value: T) -> Combine.Publishers.Map<Self,T> {
        return map { _ in value }
    }
    
    func convert() -> Combine.Publishers.Map<Self, Void> {
        return convert(to: ())
    }
    
    func convertToVoidSignal() -> Combine.Publishers.Map<Self, HashableVoid> {
        return convert(to: HashableVoid())
    }
}
