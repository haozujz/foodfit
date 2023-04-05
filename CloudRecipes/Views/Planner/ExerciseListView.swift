//
//  ExerciseListView.swift
//  CloudRecipes
//
//  Created by Joseph Zhu on 29/1/2023.
//

import SwiftUI
import Amplify

struct ExerciseListView: View {
    @EnvironmentObject private var recipesModel: RecipesModel
    @EnvironmentObject private var plansModel: PlansModel
    @EnvironmentObject private var plannerModel: PlannerModel
    @Binding var items: [Exercise]
    @Binding var showingSelector: Bool
    
    var body: some View {
        VStack {
            HStack {
                Text("Exercises")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: {
                    Task {
                        showingSelector.toggle()
                    }
                }, label: {
                    Image(systemName: "plus")
                        .font(.title2)
                        .padding(2)
                        .foregroundColor(.white)
                        .background(Color("accent1"))
                        .cornerRadius(6)
                        .shadow(radius: 2)
                })
                .padding(.horizontal)
            }
            .padding(.horizontal, 22)
            
            List {
                ForEach(items, id: \.self) { item in
                    ExerciseItem(item: item)
                }
                .onDelete(perform: delete)
            }
            .scrollDisabled(true)
            .listStyle(.plain)
            .frame(height: CGFloat(items.count) * 48)
        }
        .padding(.vertical, 12)
    }
        
    func delete(at offsets: IndexSet) {
        guard var existingP = plansModel.plans.first(where:{ $0.date == Temporal.Date(plannerModel.selectedDate) }) else {return}

        existingP.exerciseItems.remove(atOffsets: offsets)
        existingP.exerciseMultipliers.remove(atOffsets: offsets)

        Task {
            let isEmpty = (existingP.breakfastItems.isEmpty &&
                           existingP.lunchItems.isEmpty &&
                           existingP.dinnerItems.isEmpty &&
                           existingP.otherItems.isEmpty &&
                           existingP.exerciseItems.isEmpty)
            
            if isEmpty {
                guard let planToBeDeleted = plansModel.plans.first(where:{ $0.date == Temporal.Date(plannerModel.selectedDate) }) else {return}
                await plansModel.deletePlan(plan: planToBeDeleted)
            } else {
                await plansModel.savePlan(plan: existingP)
            }
        }
    }
}

private struct ExerciseItem: View {
    let item: Exercise
    
    var body: some View {
        HStack {
            Text(item.name)
            Spacer()
            Text("\(item.kcal) kcal")
        }
        .padding(.horizontal, 22)
    }
}

