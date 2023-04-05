//
//  Recipes+Hashable.swift
//  CloudRecipes
//
//  Created by Joseph Zhu on 22/12/2022.
//

//seperate file to avoid extension being overwritten when backend is updated

import SwiftUI

extension Recipe: Hashable, Identifiable {
    public static func == (lhs: Recipe, rhs: Recipe) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

