//
//  RecipesView.swift
//  CloudRecipes
//
//  Created by Joseph Zhu on 22/12/2022.
//

import SwiftUI

enum Route: Hashable {
    case category(RecipeType)
    case details(String)
}

struct RecipesView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var authModel: AuthModel
    @EnvironmentObject private var recipesModel: RecipesModel
    @EnvironmentObject private var recipeSheetModel: RecipeSheetModel
    let isPreviewingForPlanner: Bool
    
    @StateObject var uiModel = UIModel()

    // Un-used filtering bar
    //@State private var selectedCategoryIndex: Int = 0
    
    // For grid mode
    private let adaptiveColumns = [
        GridItem(.adaptive(minimum: 140))
    ]
    
    var body: some View {
        ZStack(alignment: .top) {
            NavigationStack(path: $uiModel.path) {
                ZStack {
                    Color("bg")
                        .ignoresSafeArea()
                        .onAppear {
                            uiModel.rootDismiss = dismiss
                            uiModel.isPreviewingForPlanner = isPreviewingForPlanner
                        }
                    
                    VStack(spacing: 20) {
                        if isPreviewingForPlanner {
                            Spacer(minLength: 48)
                        }
                        
                        // Un-used filtering bar
                        //CategoryBarView(selectedCategoryIndex: $selectedCategoryIndex, categories: categories)

                        ScrollView(.vertical, showsIndicators: false) {
                            Spacer(minLength: 72)
                                .navigationDestination(for: Route.self) { route in
                                    switch route {
                                    case .details(let recipeId):
                                        RecipeDetail(id: recipeId)
                                    case .category(let category):
                                        RecipesCategoryView(category: category)
                                    }
                                }
                            
                            if recipesModel.isShowingResults {
                                LazyVGrid(columns: adaptiveColumns, spacing: 20) {
                                    ForEach(
                                        recipesModel.filteredRecipes
                                    ) { recipe in
                                        NavigationLink(value: Route.details(recipe.id), label: {RecipeCard(id: recipe.id)})
                                            .buttonStyle(FlatLinkStyle())
                                    }
                                }
                                .padding(.top, 10)
                                .padding(.bottom, 20)
                                
                                Divider()
                                    .frame(height: 1)
                                    .overlay(.black)
                                    .padding(.bottom, 20)
                                    .padding(.horizontal, 100)
                            }
                            
                            ForEach(RecipeType.allCases, id: \.self) { category in
                                CategorySampleRowView(category: category)
                            }
                        }
                    }
                    
                    Button(action: {
                        recipeSheetModel.selectedRecipe = nil
                        recipeSheetModel.showingRecipeSheet.toggle()
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
                    .sheet(isPresented: $recipeSheetModel.showingRecipeSheet) {
                        RecipeSheet(recipe: recipeSheetModel.selectedRecipe)
                    }
                }
                .onTapGesture {
                    hideKeyboard()
                }
            }
            
            HStack {
                Spacer(minLength: uiModel.isHidingBackButton ? 0 : 56)
                SearchAndFilterView()
                    .opacity(uiModel.isHidingDismissButton ? 0 : 1)
                    .animation(.easeOut, value: uiModel.isHidingBackButton)
                    .animation(.spring(response: 0.2), value: uiModel.isHidingDismissButton)
            }
            .padding(.top, -2)
            .padding(.top, isPreviewingForPlanner ? 68 : 0)


            
            if isPreviewingForPlanner {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundColor(.gray)
                    .opacity(uiModel.isHidingDismissButton ? 0 : 1)
                    .padding(.bottom, 21)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .onTapGesture {
                        dismiss()
                    }
                    .padding()
                    .padding(.bottom, -40)
            }
        }
        .environmentObject(uiModel)
    }
}

private struct CategorySampleRowView: View {
    @EnvironmentObject private var recipesModel: RecipesModel
    let category: RecipeType

    var body: some View {
        VStack {
            HStack {
                Text(category.rawValue.lowercased().capitalized)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                NavigationLink(value: Route.category(category), label: {
                    HStack {
                        Text("More")
                            .font(.title3)
                            .fontWeight(.semibold)
                        Image(systemName: "chevron.forward")
                    }
                    .padding(6)
                    .foregroundColor(.black)
                    .background(Color.white)
                    .cornerRadius(8)
                })
            }
            .padding(.horizontal, 22)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(recipesModel.filteredRecipes.filter{ $0.recipeType == category }.shuffled().prefix(5)) { recipe in
                        NavigationLink(value: Route.details(recipe.id), label: {RecipeCard(id: recipe.id)})
                            .buttonStyle(FlatLinkStyle())
                    }
                    .padding(.trailing)
                }
                .padding(.leading)
            }
        }
        .padding(.bottom, 8)
    }
}

final class UIModel: ObservableObject {
    @EnvironmentObject private var recipesModel: RecipesModel
    
    @Published var isHidingBackButton = true
    @Published var isHidingDismissButton = false
    var rootDismiss: DismissAction?
    var isPreviewingForPlanner: Bool = false
    
    @Published var path: [Route] = []
}

//struct CategoryBarView: View {
//    @Binding var selectedCategoryIndex: Int
//    let categories: [String]
//
//    var body: some View {
//        ScrollView(.horizontal, showsIndicators: false) {
//            HStack {
//                ForEach(0 ..< Int(categories.count), id: \.self) { i in
//                    CategoryView(isSelected: selectedCategoryIndex == i, category: categories[i])
//                        .onTapGesture {
//                            selectedCategoryIndex = i
//                        }
//                }
//            }
//            .padding()
//        }
//        .padding(.horizontal)
//    }
//
//    struct CategoryView: View {
//        let isSelected: Bool
//        let category: String
//
//        var body: some View {
//            VStack(alignment: .leading, spacing: 0) {
//                Text(category)
//                    .font(.system(size: 18))
//                    .fontWeight(.medium)
//                    .foregroundColor(isSelected ? Color("accent3") : .black.opacity(0.6))
//
//                if (isSelected) {
//                    Color("accent3")
//                        .frame(width: 15, height: 2)
//                        .clipShape(Capsule())
//                }
//            }
//            .padding(.trailing)
//        }
//    }
//}
