//
//  MealCategoryView.swift
//  CloudRecipes
//
//  Created by Joseph Zhu on 29/1/2023.
//

import SwiftUI
import Amplify

struct MealListView: View {
    @EnvironmentObject private var recipesModel: RecipesModel
    @EnvironmentObject private var plansModel: PlansModel
    @EnvironmentObject private var plannerModel: PlannerModel
    let title: String
    @Binding var items: [Recipe]
    @Binding var showingSelector: Bool
    
    var body: some View {
        VStack {
            HStack {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: {
                    plannerModel.currentMealType = title
                    showingSelector.toggle()
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
                ForEach(items, id: \.self) { r in
                    MealItem(name: r.name, kcal: r.calories)
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
        
        switch title {
        case "Breakfast": existingP.breakfastItems.remove(atOffsets: offsets)
        case "Lunch": existingP.lunchItems.remove(atOffsets: offsets)
        case "Dinner": existingP.dinnerItems.remove(atOffsets: offsets)
        case "Other": existingP.otherItems.remove(atOffsets: offsets)
        default: return
        }
        
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

private struct MealItem: View {
    let name: String
    let kcal: Int
    
    var body: some View {
        HStack {
            Text(name)
                .lineLimit(1)
            Spacer()
            Text("\(kcal) kcal")
                .lineLimit(1)
        }
        .padding(.horizontal, 22)
    }
}

//struct MealListView_Previews: PreviewProvider {
//    static var previews: some View {
//        MealListView()
//    }
//}
