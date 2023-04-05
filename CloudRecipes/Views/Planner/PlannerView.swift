//
//  PlannerView.swift
//  scrap
//
//  Created by Joseph Zhu on 10/1/2023.
//

import Foundation
import SwiftUI

struct PlannerView: View {
    @EnvironmentObject private var recipesModel: RecipesModel
    @EnvironmentObject private var plansModel: PlansModel
    @EnvironmentObject private var plannerModel: PlannerModel
    
    @State private var showingDateSelector = false
    @State private var showingRecipeSelector = false
    @State private var showingExerciseSelector = false
    
    var body: some View {
        ZStack(alignment: .top) {
            Color("bg")
                .ignoresSafeArea()
                .onTapGesture {
                    hideKeyboard()
                }
            
            ZStack {
                ScrollView(.vertical, showsIndicators: false) {
                    Spacer(minLength: 64)
                    
                    SummaryView(totalKcalEaten: $plannerModel.totalKcalEaten, totalKcalBurned: $plannerModel.totalKcalBurned, totalProtein: $plannerModel.totalProtein, totalCarbs: $plannerModel.totalCarbs, totalFat: $plannerModel.totalFat)
                    
                    MealListView(title: "Breakfast", items: $plannerModel.breakfastItems, showingSelector: $showingRecipeSelector)
                    MealListView(title: "Lunch", items: $plannerModel.lunchItems, showingSelector: $showingRecipeSelector)
                    MealListView(title: "Dinner", items: $plannerModel.dinnerItems, showingSelector: $showingRecipeSelector)
                    MealListView(title: "Other", items: $plannerModel.otherItems, showingSelector: $showingRecipeSelector)
                        .sheet(isPresented: $showingRecipeSelector) {
                            RecipesView(isPreviewingForPlanner: true)
                        }
                    ExerciseListView(items: $plannerModel.exerciseItems, showingSelector: $showingExerciseSelector)
                        .sheet(isPresented: $showingExerciseSelector) {
                            ExerciseSelector()
                        }
                }
                
                HStack {
                    Button(action: {
                        changeDateBy(days: -1)
                    }, label: {
                        Image(systemName: "chevron.backward")
                            .font(.title2.weight(.semibold))
                            .padding(12)
                            .background(Color.white)
                            .cornerRadius(8)
                            .shadow(radius: 2)
                    })
                    
                    Text(plannerModel.selectedDate, format: .dateTime.day().month().year())
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(12)
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(radius: 2)
                        .onTapGesture {
                            showingDateSelector.toggle()
                        }
                        .sheet(isPresented: $showingDateSelector) {
                            DateSelector(selectedDate: $plannerModel.selectedDate)
                        }
                    
                    Button(action: {
                        changeDateBy(days: 1)
                    }, label: {
                        Image(systemName: "chevron.forward")
                            .font(.title2.weight(.semibold))
                            .padding(12)
                            .background(Color.white)
                            .cornerRadius(8)
                            .shadow(radius: 2)
                    })
                }
                .accentColor(.black)
                .frame(maxHeight: .infinity, alignment: .top)
            }
            .onChange(of: [plansModel.updateCounter, recipesModel.updateCounter]) { _ in
                plannerModel.interpretPlan(date: plannerModel.selectedDate, plans: plansModel.plans, recipes: recipesModel.recipes)
            }
        }
        .onChange(of: plannerModel.selectedDate) { date in
            plannerModel.interpretPlan(date: plannerModel.selectedDate, plans: plansModel.plans, recipes: recipesModel.recipes)
        }
    }
    
    private func changeDateBy(days: Int) {
        if let date = Calendar.current.date(byAdding: .day, value: days, to: plannerModel.selectedDate) {
            plannerModel.selectedDate = date
        }
    }
}

private struct DateSelector: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedDate: Date
    
    var body: some View {
        ZStack {
            Image(systemName: "xmark.circle.fill")
                .font(.title)
                .foregroundColor(.gray)
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .onTapGesture {
                    dismiss()
                }
            
            DatePicker("Select a date", selection: $selectedDate, displayedComponents: [.date])
                .datePickerStyle(GraphicalDatePickerStyle())
        }
    }
}

//struct PlannerView_Previews: PreviewProvider {
//    static var previews: some View {
//        PlannerView(totalKcalEaten: <#Int#>, totalKcalBurned: <#Int#>, totalProtein: <#Int#>, totalCarbs: <#Int#>, totalFat: <#Int#>, breakfastItems: <#[Int]#>, lunchItems: <#[Int]#>, dinnerItems: <#[Int]#>, otherItems: <#[Int]#>, exerciseItems: <#[Int]#>)
//    }
//}

