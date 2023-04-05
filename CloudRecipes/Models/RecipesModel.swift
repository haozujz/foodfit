//
//  RecipesViewModel.swift
//  CloudRecipes
//
//  Created by Joseph Zhu on 22/12/2022.
//

import Foundation
import SwiftUI
import Amplify
import Combine

@MainActor
final class RecipesModel: ObservableObject {
    @Published var recipes: [Recipe] = []
    @Published var updateCounter: Int = 0
    
    @Published var searchTerm: String = ""
    @Published var searchResult: [Recipe] = []
    @Published var isSearching = false
    @Published var isShowingResults = false
    
    @Published var maxCalories: Int = 0
    @Published var maxProtein: Int = 0
    @Published var maxCarbs: Int = 0
    @Published var maxFat: Int = 0
    var filteredRecipes: [Recipe] {
        return searchResult
                .filter{ maxCalories != 0 ? $0.calories <= maxCalories : true }
                .filter{ maxProtein != 0 ? $0.protein <= maxProtein : true }
                .filter{ maxCarbs != 0 ? $0.carbs <= maxCarbs : true }
                .filter{ maxFat != 0 ? $0.fat <= maxFat : true }
    }
    
    private var recipesSubscription: AnyCancellable?
    private var cancellables: AnyCancellable? 
    
    init() {
        subscribeToRecipes()
        
        $searchTerm
            .debounce(for: 0.2, scheduler: DispatchQueue.main)
            .removeDuplicates()
            .handleEvents(receiveOutput: { output in
                if output == "" {
                    //self.searchResult = self.recipes
                    self.isShowingResults = false
                }
                else { self.isShowingResults = true }
            })
            //.filter { $0 != "" }
            .handleEvents(receiveOutput: { output in
                self.isSearching = true
            })
            .flatMap { value in
                Future { promise in
                    Task {
                        let result = await self.searchRecipes(matching: value.lowercased().trimmingCharacters(in: .whitespacesAndNewlines))
                        promise(.success(result))
                    }
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
            .handleEvents(receiveOutput: { output in
                self.isSearching = false
            })
            .assign(to: &$searchResult)
    }
    
    private func searchRecipes(matching searchTerm: String) async -> [Recipe] {
        return recipes.filter{ $0.name.lowercased().hasPrefix(searchTerm) }
    }
    
    func getRecipes() async {
        do {
            let result = try await Amplify.DataStore.query(Recipe.self)
            
            DispatchQueue.main.async {
                self.recipes = result
                print(self.recipes.count, "recipes retrieved successfully")
                
                Task {
                    self.searchResult = await self.searchRecipes(matching: self.searchTerm.lowercased().trimmingCharacters(in: .whitespacesAndNewlines))
                }
                print(self.recipes.count, "recipes retrieved successfully")
            }
        } catch let error as DataStoreError {
            print("Error retrieving recipes: \(error)")
        } catch {
            print("Unexpected error: \(error)")
        }
    }
    
    func addRecipe(recipe: Recipe) async {
        do {
            try await Amplify.DataStore.save(recipe)
            print("Created a new recipe successfully")
        } catch let error as DataStoreError {
            print("Error creating recipe: \(error)")
        } catch {
            print("Unexpected error: \(error)")
        }
    }
    
    func editRecipe(newDetails: Recipe) async {
        DispatchQueue.main.async {
            let i = self.recipes.firstIndex(where: {$0.id == newDetails.id})
            self.recipes[i!] = newDetails
        }
        
        do {
            try await Amplify.DataStore.save(newDetails)
            print("Editted a recipe successfully")
        } catch let error as DataStoreError {
            print("Error creating recipe: \(error)")
        } catch {
            print("Unexpected error: \(error)")
        }
    }
    
    func deleteRecipe(recipe: Recipe) async {
        do {
            try await Amplify.DataStore.delete(recipe)
            print("Recipe deleted")
        } catch let error as DataStoreError {
            print("Error deleting recipe: \(error)")
        } catch {
            print("Unexpected error: \(error)")
        }
    }
    
    func subscribeToRecipes() {
        recipesSubscription = Amplify.Publisher.create(Amplify.DataStore.observe(Recipe.self))
        .sink {
            if case let .failure(error) = $0 {
                print("Subscription received error - \(error)")
            }
        }
        receiveValue: { changes in
            print("Subscription received mutation: \(changes)")
            
            Task {
                await self.getRecipes()
                DispatchQueue.main.async {
                    self.updateCounter += 1
                }
            }
        }
    }

    func unsubscribeFromRecipes() {
        recipesSubscription?.cancel()
    }
}
