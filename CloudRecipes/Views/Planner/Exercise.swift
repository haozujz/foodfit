//
//  Exercise.swift
//  CloudRecipes
//
//  Created by Joseph Zhu on 29/1/2023.
//

import SwiftUI

struct Exercise: Hashable, Identifiable {
    let id = UUID().uuidString
    let name: String
    let kcal: Int
}
