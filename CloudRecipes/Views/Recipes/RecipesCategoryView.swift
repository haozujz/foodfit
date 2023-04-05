//
//  RecipesCategoryView.swift
//  scrap
//
//  Created by Joseph Zhu on 9/1/2023.
//

import SwiftUI

struct RecipesCategoryView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var recipesModel: RecipesModel
    @EnvironmentObject private var recipeSheetModel: RecipeSheetModel
    @EnvironmentObject private var uiModel: UIModel
    let category: RecipeType
    
    // For grid
    private let adaptiveColumns = [
        GridItem(.adaptive(minimum: 140))
    ]
    
    var body: some View {
        ZStack(alignment: .top) {
            Color("bg")
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                if uiModel.isPreviewingForPlanner {
                    Spacer(minLength: 48)
                }
                
                ScrollView(.vertical, showsIndicators: false) {
                    Spacer(minLength: 82)
                    
                    LazyVGrid(columns: adaptiveColumns, spacing: 20) {
                        ForEach(recipesModel.filteredRecipes.filter{ $0.recipeType == category }) { recipe in
                            NavigationLink(value: Route.details(recipe.id), label: {RecipeCard(id: recipe.id)})
                                .buttonStyle(FlatLinkStyle())
                        }
                    }
                }
            }
            
            HStack {
                Image(systemName: "chevron.backward")
                    .font(.system(size: 20))
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(radius: 2)
                    .padding(.leading, 10)
                    .padding(.trailing, -8)
                    .onTapGesture {
                        uiModel.isHidingBackButton = true
                        dismiss()
                    }
                
                Spacer(minLength: 200)
            }
            .padding(.top, uiModel.isPreviewingForPlanner ? 68 : 0)
        
            Button(action: {
                Task {
                    recipeSheetModel.selectedRecipe = nil
                    recipeSheetModel.showingRecipeSheet.toggle()
                }
            }, label: {
                Image(systemName: "plus")
                    .font(.largeTitle)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color("accent1"))
                    .clipShape(Circle())
                    .shadow(color: Color("accent1").opacity(0.2), radius: 6.0)
                    .padding()
            })
            .frame(width: 40, height: 40)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            .padding(.trailing, 32)
            .padding(.bottom, 24)
        }
        .onTapGesture {
            hideKeyboard()
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            uiModel.isHidingBackButton = false
        }
    }
}


