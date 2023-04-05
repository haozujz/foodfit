//
//  SearchAndFilterView.swift
//  CloudRecipes
//
//  Created by Joseph Zhu on 27/1/2023.
//

import SwiftUI

struct SearchAndFilterView: View {
    @EnvironmentObject private var recipesModel: RecipesModel
     
    @FocusState private var isSearchBarFocussed: Bool
    @State private var showingFilterSheet = false

    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .padding(.vertical)
                    .padding(.horizontal, 10)
                
                TextField("Search Recipes", text: $recipesModel.searchTerm)
                    .focused($isSearchBarFocussed)
                    //.onSubmit {}
                    
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundColor(.gray)
                    .padding(.vertical)
                    .padding(.horizontal, 12)
                    .opacity(!recipesModel.searchTerm.isEmpty && isSearchBarFocussed ? 1.0 : 0.0)
                    .onTapGesture {
                        recipesModel.searchTerm = ""
                        isSearchBarFocussed = false
                    }
            }
            .background(Color.white)
            .cornerRadius(10.0)
            .shadow(radius: 4)
            .padding(.horizontal)
            
            Image(systemName: "line.3.horizontal.decrease")
                .font(.system(size: 26))
                .padding()
                .foregroundColor(.white)
                .background(Color("accent3"))
                .cornerRadius(10.0)
                .shadow(radius: 4)
                .padding(.leading, -8)
                .padding(.trailing, 12)
                .sheet(isPresented: $showingFilterSheet) {
                    FilterSheet(maxCalories: $recipesModel.maxCalories, maxProtein: $recipesModel.maxProtein, maxCarbs: $recipesModel.maxCarbs, maxFat: $recipesModel.maxFat)
                }
                .onTapGesture {
                    showingFilterSheet.toggle()
                }
        }
    }
    
    private struct FilterSheet: View {
        @Environment(\.dismiss) var dismiss
        @EnvironmentObject private var recipesModel: RecipesModel
        
        @Binding var maxCalories: Int
        @Binding var maxProtein: Int
        @Binding var maxCarbs: Int
        @Binding var maxFat: Int
        
        var body: some View {
            ZStack {
                Form {
                    Section(header: Text("Nutrition").frame(maxWidth: .infinity, alignment: .center)) {
                        HStack {
                            Text("Maximum Calories")
                            Spacer()
                            Menu {
                                ForEach([50,100,150], id: \.self) { val in
                                    Button{ recipesModel.maxCalories = val }label:{ Text("\(val)") }
                                }
                                Button{ recipesModel.maxCalories = 0 }label:{ Text("No maximum") }
                            } label: {
                                RoundedRectangle(cornerRadius: 6.0)
                                    .foregroundColor(.gray.opacity(0.16))
                                    .frame(width: 60, height: 40)
                                    .overlay {
                                        Text(recipesModel.maxCalories == 0 ? "No" : "\(recipesModel.maxCalories)")
                                    }
                            }
                        }
                        HStack {
                            Text("Maximum Protein")
                            Spacer()
                            Menu {
                                ForEach([50,100,150], id: \.self) { val in
                                    Button{ recipesModel.maxProtein = val }label:{ Text("\(val)") }
                                }
                                Button{ recipesModel.maxProtein = 0 }label:{ Text("No maximum") }
                            } label: {
                                RoundedRectangle(cornerRadius: 6.0)
                                    .foregroundColor(.gray.opacity(0.16))
                                    .frame(width: 60, height: 40)
                                    .overlay {
                                        Text(recipesModel.maxProtein == 0 ? "No" : "\(recipesModel.maxProtein)")
                                    }
                            }
                        }
                        HStack {
                            Text("Maximum Carbs")
                            Spacer()
                            Menu {
                                ForEach([50,100,150], id: \.self) { val in
                                    Button{ recipesModel.maxCarbs = val }label:{ Text("\(val)") }
                                }
                                Button{ recipesModel.maxCarbs = 0 }label:{ Text("No maximum") }
                            } label: {
                                RoundedRectangle(cornerRadius: 6.0)
                                    .foregroundColor(.gray.opacity(0.16))
                                    .frame(width: 60, height: 40)
                                    .overlay {
                                        Text(recipesModel.maxCarbs == 0 ? "No" : "\(recipesModel.maxCarbs)")
                                    }
                            }
                        }
                        HStack {
                            Text("Maximum Fat")
                            Spacer()
                            Menu {
                                ForEach([50,100,150], id: \.self) { val in
                                    Button{ recipesModel.maxFat = val }label:{ Text("\(val)") }
                                }
                                Button{ recipesModel.maxFat = 0 }label:{ Text("No maximum") }
                            } label: {
                                RoundedRectangle(cornerRadius: 6.0)
                                    .foregroundColor(.gray.opacity(0.16))
                                    .frame(width: 60, height: 40)
                                    .overlay {
                                        Text(recipesModel.maxFat == 0 ? "No" : "\(recipesModel.maxFat)")
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
        }
    }
}


