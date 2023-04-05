//
//  RecipeSheetModel.swift
//  CloudRecipes
//
//  Created by Joseph Zhu on 5/2/2023.
//

import Foundation
import SwiftUI

final class RecipeSheetModel: ObservableObject {
    @Published var showingRecipeSheet = false
    var selectedRecipe: Recipe?
}
