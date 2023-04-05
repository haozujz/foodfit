//
//  RecipeDetail.swift
//  CloudRecipes
//
//  Created by Joseph Zhu on 27/1/2023.
//

import SwiftUI
import Amplify

struct RecipeDetail: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var recipesModel: RecipesModel
    @EnvironmentObject private var recipeSheetModel: RecipeSheetModel
    @EnvironmentObject private var imagesModel: ImagesModel
    @EnvironmentObject private var plansModel: PlansModel
    @EnvironmentObject private var plannerModel: PlannerModel
    @EnvironmentObject private var uiModel: UIModel
    let id: String

    @State private var selectedDetail: SelectedDetail = .nutrition
    enum SelectedDetail: String, CaseIterable {
        case nutrition = "Nutrition"
        case ingredients = "Ingredients"
        case method = "Method"
    }
    
    var body: some View {
        VStack {
            ZStack(alignment: .top) {
                Color("bg")
                    .ignoresSafeArea()
                
                CachedAsyncImage(key: fetchRecipe().image) { phase in  
                         switch phase {
                         case .empty:
                             ZStack{
                                 ProgressView()
                                     .scaleEffect(4)
                                     .opacity(0.4)
                                 
                                 Image(systemName: "fork.knife")
                                     .foregroundColor(.gray)
                                     .font(.system(size: 100))
                                     .scaledToFill()
                             }
                             .padding(.top, 100)
                         case.success(let image):
                             VStack(spacing: 0) {
                                 image
                                     .resizable()
                                     .scaledToFill()
                                     .frame(height: 360)
                                 Rectangle()
                                     .background(.black)
                                     .frame(height: 200)
                             }
                             .frame(maxHeight: .infinity, alignment: .top)

                         default:
                             Image(systemName: "fork.knife")
                                 .foregroundColor(.gray)
                                 .font(.system(size: 100))
                                 .padding(20)
                                 .scaledToFill()
                         }
                 }
                .frame(width: UIScreen.main.bounds.size.width)
                .clipped()
                
                ScrollView(.vertical, showsIndicators: false) {
                    Spacer(minLength: 300)
                    
                    VStack(spacing: 20) {
                        Text(fetchRecipe().name)
                            .font(.title)
                            .fontWeight(.semibold)
                            .frame(height: 10)
                        
                        HStack() {
                            Text("\(fetchRecipe().servingSize) servings")
                                .padding(.trailing)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                            
                            Divider()
                                .frame(width: 2)
                            
                            Text("\(fetchRecipe().cookingTime) min")
                                .padding(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(height: 20)
                        
                        Picker("Choose details", selection: $selectedDetail) {
                            ForEach(SelectedDetail.allCases, id: \.self) { detail in
                                Text(detail.rawValue)
                            }
                        }
                        .pickerStyle(.segmented)
                        
                        ZStack {
                            switch selectedDetail {
                            case .nutrition:
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack {
                                        Text("Calories")
                                            .foregroundColor(.gray)
                                        Spacer()
                                        Text("\(fetchRecipe().calories)")
                                        Text("kcal")
                                            .foregroundColor(.gray)
                                    }
                                    HStack {
                                        Text("Protein")
                                            .foregroundColor(.gray)
                                        Spacer()
                                        Text("\(fetchRecipe().protein)")
                                        Text("g")
                                            .foregroundColor(.gray)
                                    }
                                    HStack {
                                        Text("Carbs")
                                            .foregroundColor(.gray)
                                        Spacer()
                                        Text("\(fetchRecipe().carbs)")
                                        Text("g")
                                            .foregroundColor(.gray)
                                    }
                                    HStack {
                                        Text("Fat")
                                            .foregroundColor(.gray)
                                        Spacer()
                                        Text("\(fetchRecipe().fat)")
                                        Text("g")
                                            .foregroundColor(.gray)
                                    }
                                    HStack {
                                        Text("Food group")
                                            .foregroundColor(.gray)
                                        Spacer()
                                        Text("\(fetchRecipe().recipeType.rawValue.lowercased().capitalized)")
                                    }
                                    Spacer()
                                }
                                .frame(minHeight: 500)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 48)
                            case .ingredients:
                                VStack(alignment: .leading) {
                                    ForEach(fetchRecipe().ingredients.indices, id: \.self) { i in
                                        HStack {
                                            Circle()
                                                .foregroundColor(.gray)
                                                .frame(width: 10, height: 10)
                                            Text(fetchRecipe().ingredients[i])
                                                .padding(.leading, 20)
                                        }
                                    }
                                    Spacer()
                                }
                                .frame(minHeight: 500)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 48)
                            case .method:
                                VStack(alignment: .leading, spacing: 18) {
                                    ForEach(fetchRecipe().methodSteps.indices, id: \.self) { i in
                                        HStack {
                                            Text("\(i + 1)")
                                                .font(.title3)
                                                .foregroundColor(.gray)
                                            Text(fetchRecipe().methodSteps[i])
                                                .padding(.leading, 20)
                                        }
                                    }
                                    Spacer()
                                }
                                .frame(minHeight: 500)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 24)
                            }
                        }
                    }
                    .padding()
                    .padding(.top)
                    .frame(maxWidth: .infinity)
                    .background(Color("bg"))
                    .cornerRadius(40, corners: [.topLeft, .topRight])
                    .shadow(color: .black.opacity(0.1), radius: 3, y: -6)
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
                            uiModel.isHidingDismissButton = false
                            dismiss()
                        }
                    
                    Spacer()
                    
                    Menu {
                        Button {
                            let r: Recipe? = recipesModel.recipes.first(where: {$0.id == id})
                            recipeSheetModel.selectedRecipe = r
                            recipeSheetModel.showingRecipeSheet.toggle()
                        } label: {
                            Label("Edit", systemImage: "square.and.pencil")
                        }
                        
                        Button(role: .destructive) {
                            Task {
                                // Remove the recipe from plans
                                var plansToBeEditted: [Plan] = []
                                
                                plansModel.plans.forEach { plan in
                                    if plan.breakfastItems.contains(id) ||
                                        plan.lunchItems.contains(id) ||
                                        plan.dinnerItems.contains(id) ||
                                        plan.otherItems.contains(id) {
                                        plansToBeEditted.append(plan)
                                    }
                                }
                                
                                plansToBeEditted.enumerated().forEach { i, _ in
                                    plansToBeEditted[i].breakfastItems = plansToBeEditted[i].breakfastItems.filter{ $0 != id }
                                    plansToBeEditted[i].lunchItems = plansToBeEditted[i].lunchItems.filter{ $0 != id }
                                    plansToBeEditted[i].dinnerItems = plansToBeEditted[i].dinnerItems.filter{ $0 != id }
                                    plansToBeEditted[i].otherItems = plansToBeEditted[i].otherItems.filter{ $0 != id }
                                }
                                
                                for plan in plansToBeEditted {
                                    async let _ = await plansModel.savePlan(plan: plan)
                                }
                                
                                // Delete recipe and the associated image
                                async let _ = await imagesModel.deleteImage(key: fetchRecipe().image)
                                // Can also delete image cache here, implement error handling
                                await recipesModel.deleteRecipe(recipe: fetchRecipe())
                                
                                uiModel.isHidingDismissButton = false
                                dismiss()
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(.black)
                            .rotationEffect(Angle(degrees: 90), anchor: .center)
                            .shadow(radius: 2)
                            .frame(minHeight: 50)
                            .background(Color.clear)
                    }
                    .padding(.trailing, 12)
                }
                .padding(.top, uiModel.isPreviewingForPlanner ? 8 : 48)
                
                if uiModel.isPreviewingForPlanner {
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
                        
                        switch plannerModel.currentMealType {
                        case "Breakfast": validP.breakfastItems.append(id)
                        case "Lunch": validP.lunchItems.append(id)
                        case "Dinner": validP.dinnerItems.append(id)
                        case "Other": validP.otherItems.append(id)
                        default: return
                        }
                        
                        Task {
                            await plansModel.savePlan(plan: validP)
                            uiModel.isHidingDismissButton = false
                            
                            guard let rootDismiss: DismissAction = uiModel.rootDismiss else {return}
                            rootDismiss()
                        }
                    }, label: {
                        Text("Add to Meal Plan")
                            .padding()
                            .padding(.horizontal)
                            .foregroundColor(.white)
                            .background(Color("accent1"))
                            .cornerRadius(40.0, corners: [.topLeft])
                    })
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    .shadow(radius: 4)
                    .ignoresSafeArea()
                }
            }
        }
        .onAppear {
            uiModel.isHidingDismissButton = true
        }
        .onDisappear {
            uiModel.isHidingDismissButton = false
        }
        .ignoresSafeArea(.all, edges: [.top])
        .navigationBarBackButtonHidden(true)
//        .toolbar {
//            ToolbarItem(placement: .navigationBarLeading) {
//                Image(systemName: "chevron.backward")
//                    .padding(12)
//                    .padding(.horizontal, 3)
//                    .background(Color.white)
//                    .cornerRadius(8)
//                    .padding(.leading, -4)
//                    .shadow(radius: 2)
//                    .onTapGesture {
//                        recipeSheetModal.isHidingDismissButton = false
//                        dismiss()
//                    }
//            }
//
//            ToolbarItem(placement: .navigationBarTrailing) {
//                Menu {
//                    Button {
//                        recipeSheetModal.selectedRecipe = recipe
//                        recipeSheetModal.showingRecipeSheet.toggle()
//                    } label: {
//                        Label("Edit", systemImage: "square.and.pencil")
//                    }
//
//                    Button(role: .destructive) {
//                        Task {
//                            await recipesModel.deleteRecipe(recipe: recipe)
//                            dismiss()
//                        }
//                    } label: {
//                        Label("Delete", systemImage: "trash")
//                    }
//                } label: {
//                    Image(systemName: "ellipsis")
//                        .font(.system(size: 22, weight: .semibold))
//                        .foregroundColor(.black)
//                        .rotationEffect(Angle(degrees: 90))
//                        .padding(.trailing, -4)
//                        .shadow(radius: 2)
//                }
//            }
//        }
    }
    
    private func fetchRecipe() -> Recipe {
        return recipesModel.recipes.first(where: {$0.id == id}) ?? Recipe(name: "", image: "", servingSize: 0, cookingTime: 0, calories: 0, protein: 0, carbs: 0, fat: 0, recipeType: RecipeType.snack)
    }
}

// Allow independant rounded corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

//struct DetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            RecipeDetail(isPreviewingForPlanner: true, hidingDismissButton: .constant(true))
//        }
//    }
//}

