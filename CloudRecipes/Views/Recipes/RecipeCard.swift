//
//  RecipeCard.swift
//  CloudRecipes
//
//  Created by Joseph Zhu on 27/1/2023.
//

import SwiftUI

struct RecipeCard: View {
    @EnvironmentObject private var recipesModel: RecipesModel
    @EnvironmentObject private var imagesModel: ImagesModel
    let id: String

    @State private var isImageLoaded = false
    
    var body: some View {
       ZStack(alignment: .bottom) {
           CachedAsyncImage(key: fetchRecipe().image) { phase in
                    switch phase {
                    case .empty:
                        ZStack{
                            ProgressView()
                                .scaleEffect(4)
                                .opacity(0.4)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    case.success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .onAppear {
                                isImageLoaded = true
                            }
                    default:
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundColor(.white)
                            .frame(width: 80, height: 80)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    }
            }
            
           Text(fetchRecipe().name)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .minimumScaleFactor(0.80)
                .lineLimit(2)
                .frame(width: 160, height: 30)
                .background(.ultraThinMaterial)
                .frame(maxHeight: .infinity, alignment: .bottom)
        }
        .background(.white)
        .frame(width: 160, height: 180)
        .cornerRadius(20)
        .allowsHitTesting(isImageLoaded)
        .redacted(reason: !isImageLoaded ? .placeholder : [])
        .onChange(of: recipesModel.updateCounter) { _ in
            isImageLoaded = false
            isImageLoaded = true
        }
    }
    
    private func fetchRecipe() -> Recipe {
        return recipesModel.recipes.first(where: {$0.id == id}) ?? Recipe(name: "", image: "", servingSize: 0, cookingTime: 0, calories: 0, protein: 0, carbs: 0, fat: 0, recipeType: RecipeType.snack)
    }
}

//struct RecipeCard_Previews: PreviewProvider {
//    static var previews: some View {
//        RecipeCard(name: "name", isPreviewingForPlanner: false)
//    }
//}

