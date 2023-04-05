//
//  RecipeSheet.swift
//  CloudRecipes
//
//  Created by Joseph Zhu on 5/2/2023.
//

import SwiftUI

struct RecipeSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var recipesModel: RecipesModel
    @EnvironmentObject private var imagesModel: ImagesModel
    @EnvironmentObject private var sheetModel: RecipeSheetModel
    
    let recipe: Recipe?
    
    @State private var name: String = ""
    @State private var image: UIImage?
    @State private var imageKey: String?
    @State private var recipeType: RecipeType = .grain
    @State private var servingSize: Int = 0
    @State private var cookingTime: Int = 0
    @State private var calories: Int = 0
    @State private var protein: Int = 0
    @State private var carbs: Int = 0
    @State private var fat: Int = 0
    @State private var ingredients: [IdentifiableText] = []
    @State private var methodSteps: [IdentifiableText] = []
    
    @State private var showingImagePicker = false
    @State private var isSaving = false
    
    struct IdentifiableText: Hashable, Identifiable {
        let id: UUID = UUID()
        var value: String
    }
    
    init(recipe: Recipe?) {
        self.recipe = recipe
        
        guard let r = recipe else {return}
        _name = State(initialValue: r.name)
        _imageKey = State(initialValue: r.image)
        _recipeType = State(initialValue: r.recipeType)
        _servingSize = State(initialValue: r.servingSize)
        _cookingTime = State(initialValue: r.cookingTime)
        _calories = State(initialValue: r.calories)
        _protein = State(initialValue: r.protein)
        _carbs = State(initialValue: r.carbs)
        _fat = State(initialValue: r.fat)
        _ingredients = State(initialValue: r.ingredients.map {IdentifiableText(value: $0)})
        _methodSteps = State(initialValue: r.methodSteps.map {IdentifiableText(value: $0)})
    }
    
    var body: some View {
        ZStack {
            Color(.gray).opacity(0.2)
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    Button(action: {
                        dismiss()
                    }, label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.gray)
                            .padding(.top, 10)
                            .onTapGesture {
                                dismiss()
                            }
                    })
                    
                    Spacer()
                    
                    Button(action: {
                        var newRecipeIngredients: [String] = []
                        for ingredient in ingredients {
                            newRecipeIngredients.append(ingredient.value)
                        }
                        var newRecipeMethodSteps: [String] = []
                        for methodStep in methodSteps {
                            newRecipeMethodSteps.append(methodStep.value)
                        }
                        Task {
                            isSaving = true
                            
                            var key: String = ""
                            
                            if image != nil {
                                key = UUID().uuidString
                                print("uploading image")
                                await imagesModel.uploadImage(key: key, image: image!)
                                print("uploaded image")
                            }
                            
                            if let r = recipe, let existingRecipe = recipesModel.recipes.first(where: {$0.id == r.id}) {
                                if key != "" {
                                    print("deleting old image")
                                    async let _ = await imagesModel.deleteImage(key: existingRecipe.image)
                                    imagesModel.imageCache[existingRecipe.image] = nil
                                }
                                
                                let newDetails = Recipe(
                                    id: existingRecipe.id,
                                    name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                                    image:  key == "" ? existingRecipe.image : key,
                                    servingSize: servingSize,
                                    cookingTime: cookingTime,
                                    calories: calories,
                                    protein: protein,
                                    carbs: carbs ,
                                    fat: fat,
                                    ingredients: ingredients.compactMap{ $0.value.isEmpty ? nil : $0.value.trimmingCharacters(in: .whitespacesAndNewlines) },
                                    methodSteps: methodSteps.compactMap{ $0.value.isEmpty ? nil : $0.value.trimmingCharacters(in: .whitespacesAndNewlines) },
                                    recipeType: recipeType
                                )
                                
                                print("Editing ", newDetails.name)
                                await recipesModel.editRecipe(newDetails: newDetails)
                            } else {
                                guard key != "" else {return}
                                
                                let newRecipe = Recipe(
                                    name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                                    image: key,
                                    servingSize: servingSize,
                                    cookingTime: cookingTime,
                                    calories: calories,
                                    protein: protein,
                                    carbs: carbs ,
                                    fat: fat,
                                    ingredients: ingredients.compactMap{ $0.value.isEmpty ? nil : $0.value.trimmingCharacters(in: .whitespacesAndNewlines) },
                                    methodSteps: methodSteps.compactMap{ $0.value.isEmpty ? nil : $0.value.trimmingCharacters(in: .whitespacesAndNewlines) },
                                    recipeType: recipeType
                                )

                                print("Adding ", newRecipe.name)
                                await recipesModel.addRecipe(recipe: newRecipe)
                            }
                            // Implement error handling here
                            // isSaving = false
                            dismiss()
                        }
                    }, label: {
                        Text(isSaving ? "Saving ..." : "Save")
                            .foregroundColor(.white)
                            .padding(12)
                            .padding(.horizontal, 8)
                            .background(Color("accent1"))
                            .cornerRadius(8)
                            .shadow(radius: 2)
                            .padding(.top, 12)
                            .opacity(name.isEmpty || image == nil && recipe == nil ? 0.5 : 1.0)
                    })
                    .disabled(name.isEmpty || image == nil && recipe == nil || isSaving)
                }
                .padding(.horizontal)
                
                ScrollView(.vertical, showsIndicators: false) {
                    Group {
                        Text("Recipe Name")
                            .font(.title2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 20)
                            .padding(.leading, 20)

                        CustomTextField2(value: $name, placeholder: "Name")
                            .padding(.horizontal)

                        Text("Image")
                            .font(.title2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 20)
                            .padding(.leading, 20)
                        
                        ZStack {
                            if recipe != nil && image == nil {
                                CachedAsyncImage(key: recipe!.image) { phase in
                                         switch phase {
                                         case .empty:
                                             ZStack{
                                                 ProgressView()
                                                     .scaleEffect(4)
                                                     .opacity(0.4)
                                                 
                                                 Image(systemName: "fork.knife")
                                                     .foregroundColor(.gray)
                                                     .font(.system(size: 100))
                                             }
                                             .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                         case.success(let image):
                                             image
                                                 .resizable()
                                                 .scaledToFill()
                                         default:
                                             Image(systemName: "fork.knife")
                                                 .foregroundColor(.gray)
                                                 .font(.system(size: 100))
                                                 .padding(20)
                                                 .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                         }
                                 }
                                .frame(width: 120, height: 120)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .padding()
                                .shadow(radius: 6)
                            } else if let validImage = image {
                                Image(uiImage: validImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 120)
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                    .padding()
                                    .shadow(radius: 6)
                            } else {
                                Image(systemName: "person.fill")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 50))
                                    .frame(width: 90, height: 90)
                                    .padding(20)
                                    .background(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                    .padding()
                                    .shadow(radius: 6)
                            }
                        }
                        .onTapGesture{
                            showingImagePicker = true
                        }
                        .sheet(isPresented: $showingImagePicker) {
                            ImagePicker(pickedImage: $image)
                        }
                        
                        Text("Type")
                            .font(.title2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 20)
                            .padding(.leading, 20)
                        Picker("Choose type", selection: $recipeType) {
                            ForEach(RecipeType.allCases, id: \.self) { type in
                                Text(type.rawValue.lowercased().capitalized)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)

                        Text("Serving Size")
                            .font(.title2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 20)
                            .padding(.leading, 20)
                        CustomNumberField(value: $servingSize, units: nil)

                        Text("Cooking Time")
                            .font(.title2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 20)
                            .padding(.leading, 20)
                        CustomNumberField(value: $cookingTime, units: "min")
                    }

                    Group {
                        Text("Nutrition")
                            .font(.title2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 20)
                            .padding(.leading, 20)
                        
                        VStack {
                            HStack {
                                Text("Calories")
                                Spacer()
                                CustomNumberField(value: $calories, units: "kcal")
                            }
                            HStack {
                                Text("Protein")
                                Spacer()
                                CustomNumberField(value: $protein, units: "g")
                            }
                            HStack {
                                Text("Carbs")
                                Spacer()
                                CustomNumberField(value: $carbs, units: "g")
                            }
                            HStack {
                                Text("Fat")
                                Spacer()
                                CustomNumberField(value: $fat, units: "g")
                            }
                        }
                        .padding(.horizontal, 40)
                    }

                    HStack {
                        Text("Ingredients")
                            .font(.title2)
                            .padding(.leading, 20)
                        Spacer()
                        Button(action: {
                            ingredients.append(IdentifiableText(value: ""))
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
                    .padding(.top, 20)
                    .padding(.horizontal, 4)
                    
                    List {
                        ForEach($ingredients) { ingredient in
                            CustomTextField2(value: ingredient.value, placeholder: "Ingredient")
                        }
                        .onDelete(perform: deleteIngredients)
                    }
                    .scrollDisabled(true)
                    .listStyle(.plain)
                    .frame(height: CGFloat(ingredients.count) * 62)

                    HStack {
                        Text("Method Steps")
                            .font(.title2)
                            .padding(.leading, 20)
                        Spacer()
                        Button(action: {
                            methodSteps.append(IdentifiableText(value: ""))
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
                    .padding(.top, 20)
                    .padding(.horizontal, 4)
                    
                    List {
                        ForEach($methodSteps) { methodStep in
                            CustomTextField2(value: methodStep.value, placeholder: "Method step")
                        }
                        .onDelete(perform: deleteMethodSteps)
                    }
                    .scrollDisabled(true)
                    .listStyle(.plain)
                    .frame(height: CGFloat(methodSteps.count) * 62)
                }
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
        .allowsHitTesting(!isSaving)
        .interactiveDismissDisabled(isSaving)
    }
    
    func deleteIngredients(at offsets: IndexSet) {
        ingredients.remove(atOffsets: offsets)
    }
    
    func deleteMethodSteps(at offsets: IndexSet) {
        methodSteps.remove(atOffsets: offsets)
    }
}
