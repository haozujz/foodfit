//
//  TrackerModel.swift
//  CloudRecipes
//
//  Created by Joseph Zhu on 1/2/2023.
//

import Foundation
import SwiftUI
import Amplify

final class TrackerModel: ObservableObject {
    @Published var activeCaloriesValues: [Int] = []
    @Published  var proteinValues: [Int] = []
    @Published  var carbsValues: [Int] = []
    @Published  var fatValues: [Int] = []
    
    func getValuesForGraph(plans: [Plan], recipes: [Recipe]) {
        guard var tmpDate = Calendar.current.date(byAdding: .month, value: -6, to: Date.now) else {return}

        var dates: [Date] = []
        while tmpDate <= Date.now {
            dates.append(tmpDate)
            guard let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: tmpDate) else {break}
            tmpDate = nextDate
        }
        
        var tmpActiveCalories: [Int] = Array(repeating: 0, count: dates.count)
        var tmpProtein: [Int] = Array(repeating: 0, count: dates.count)
        var tmpCarbs: [Int] = Array(repeating: 0, count: dates.count)
        var tmpFat: [Int] = Array(repeating: 0, count: dates.count)
        
        dates.enumerated().forEach { i, date in
            var dayActiveCalories: Int = 0
            var dayProtein: Int = 0
            var dayCarbs: Int = 0
            var dayFat: Int = 0
            
            if let dayPlan: Plan = plans.first(where:{ $0.date == Temporal.Date(date) }) {
                let foodItems: [String] = dayPlan.breakfastItems + dayPlan.lunchItems + dayPlan.dinnerItems + dayPlan.otherItems
                
                foodItems.forEach { id in
                    guard let r = recipes.first(where:{ $0.id == id }) else {return}
                    dayActiveCalories -= r.calories
                    dayProtein += r.protein
                    dayCarbs += r.carbs
                    dayFat += r.fat
                }
                
                dayPlan.exerciseItems.enumerated().forEach { i, e in
                    let base = Double(exercises[e] ?? 0)
                    let multiplier: Double = dayPlan.exerciseMultipliers[i]
                    let total = Int(base * multiplier)
                    dayActiveCalories += total
                }
            } else {
                if i > 0 {
                    dayActiveCalories = tmpActiveCalories[i - 1]
                    dayProtein = tmpProtein[i - 1]
                    dayCarbs = tmpCarbs[i - 1]
                    dayFat = tmpFat[i - 1]
                }
            }
            
            tmpActiveCalories[i] = dayActiveCalories
            tmpProtein[i] = dayProtein
            tmpCarbs[i] = dayCarbs
            tmpFat[i] = dayFat
        }
        
        activeCaloriesValues = tmpActiveCalories
        proteinValues = tmpProtein
        carbsValues = tmpCarbs
        fatValues = tmpFat
    }
}

