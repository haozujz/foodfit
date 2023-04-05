//
//  PlannerModel.swift
//  CloudRecipes
//
//  Created by Joseph Zhu on 1/2/2023.
//

import Foundation
import SwiftUI
import Amplify

final class PlannerModel: ObservableObject {
    @Published var selectedDate = Date.now
    @Published var totalKcalEaten: Int = 0
    @Published var totalKcalBurned: Int = 0
    @Published var totalProtein: Int = 0
    @Published var totalCarbs: Int = 0
    @Published var totalFat: Int = 0
    @Published var breakfastItems: [Recipe] = []
    @Published var lunchItems: [Recipe] = []
    @Published var dinnerItems: [Recipe] = []
    @Published var otherItems: [Recipe] = []
    @Published var exerciseItems: [Exercise] = []
    
    var currentMealType: String = ""
    
    func interpretPlan(date: Date, plans: [Plan], recipes: [Recipe]) {
        totalKcalEaten = 0
        totalKcalBurned = 0
        totalProtein = 0
        totalCarbs = 0
        totalFat = 0
        breakfastItems = []
        lunchItems = []
        dinnerItems = []
        otherItems = []
        exerciseItems = []
        
        guard let p = plans.first(where:{ $0.date == Temporal.Date(date) }) else {return}
        
        var newBreakFastItems: [Recipe] = []
        var newLunchItems: [Recipe] = []
        var newDinnerItems: [Recipe] = []
        var newOtherItems: [Recipe] = []
        let meals = [(p.breakfastItems, 0), (p.lunchItems, 1), (p.dinnerItems, 2), (p.otherItems, 3)]
        
        meals.forEach { ids, i in
            ids.forEach { id in
                guard let r = recipes.first(where:{ $0.id == id }) else {return}
            
                if i == 0 { newBreakFastItems.append(r) }
                else if i == 1 { newLunchItems.append(r) }
                else if i == 2 { newDinnerItems.append(r) }
                else if i == 3 { newOtherItems.append(r) }
                totalKcalEaten += r.calories
                totalProtein += r.protein
                totalCarbs += r.carbs
                totalFat += r.fat
            }
        }
        
        var newExerciseItems: [Exercise] = []
        
        p.exerciseItems.enumerated().forEach { i, e in
            let base = Double(exercises[e] ?? 0)
            let multiplier: Double = p.exerciseMultipliers[i]
            let total = Int(base * multiplier)
            newExerciseItems.append(Exercise(name: e, kcal: total))
            totalKcalBurned += total
        }
        
        breakfastItems = newBreakFastItems
        lunchItems = newLunchItems
        dinnerItems = newDinnerItems
        otherItems = newOtherItems
        exerciseItems = newExerciseItems
    }
}
