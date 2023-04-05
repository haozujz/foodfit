//
//  ExerciseSelector.swift
//  CloudRecipes
//
//  Created by Joseph Zhu on 1/2/2023.
//

import SwiftUI
import Amplify

struct ExerciseSelector: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var recipesModel: RecipesModel
    @EnvironmentObject private var plansModel: PlansModel
    @EnvironmentObject private var plannerModel: PlannerModel
    
    @State var duration: Int = 30
    var multiplier: Double {
        Double(CGFloat(duration) / CGFloat(30.0))
    }
    
    var body: some View {
        ZStack {
            Form {
                Section(header: Text("Exercise duration").frame(maxWidth: .infinity, alignment: .center)) {
                    HStack {
                        TextField("", value: $duration, formatter: NumberFormatter())
                            .font(.title3)
                            .keyboardType(.numberPad)
                        
                        Text("min")
                            .foregroundColor(.gray)
                    }
                }
                
                ForEach(Array("A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z".components(separatedBy: ",")), id: \.self) { letter in
                    Section(header: Text(letter)) {
                        ForEach(exercises.keys.filter{ $0.hasPrefix(letter) }, id: \.self) { e in
                            ZStack {
                                Button(action: {
                                    var p: Plan? = nil
    
                                    if let existingPlan = plansModel.plans.first(where:{ $0.date == Temporal.Date(plannerModel.selectedDate) }) {
                                        p = existingPlan
                                    } else {
                                        let newPlan = Plan(
                                            id: UUID().uuidString,
                                            date: Temporal.Date(plannerModel.selectedDate)
                                        )
                                        p = newPlan
                                    }
                                    
                                    guard var validP = p else {return}
                                    
                                    validP.exerciseItems.append(e)
                                    validP.exerciseMultipliers.append(multiplier)
                                    
                                    Task {
                                        await plansModel.savePlan(plan: validP)
                                        dismiss()
                                    }
                                }, label: {
                                    HStack {
                                        Text(e)
                                        Spacer()
                                        Text("\(Int(CGFloat(exercises[e] ?? 0) * multiplier)) kcal")
                                    }
                                })
                            }
                        }
                    }
                }
            }
            .accentColor(.black)
            
            Image(systemName: "xmark.circle.fill")
                .font(.title)
                .foregroundColor(.gray)
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .offset(x: -10, y: -12)
                .onTapGesture {
                    dismiss()
                }
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
}

