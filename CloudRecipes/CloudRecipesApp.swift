//
//  CloudRecipesApp.swift
//  CloudRecipes
//
//  Created by Joseph Zhu on 21/12/2022.
//

import SwiftUI
import Amplify
import AWSCognitoAuthPlugin
import AWSAPIPlugin
import AWSDataStorePlugin
import AWSS3StoragePlugin

@main
struct CloudRecipesApp: App {
    @StateObject var authModel = AuthModel()
    @StateObject var recipesModel = RecipesModel()
    @StateObject var recipeSheetModel = RecipeSheetModel()
    @StateObject var imagesModel = ImagesModel()
    @StateObject var plansModel = PlansModel()
    @StateObject var plannerModel = PlannerModel()
    @StateObject var trackerModel = TrackerModel()
    
    
    func configureAmplify() {
        do {
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.add(plugin: AWSS3StoragePlugin())
            let models = AmplifyModels()
            try Amplify.add(plugin: AWSAPIPlugin(modelRegistration: models))
            try Amplify.add(plugin: AWSDataStorePlugin(modelRegistration: models))
            try Amplify.configure()
            print("Amplify configured")
        } catch {
            print("Amplify configuration attempt error: ", error)
        }
    }
    
    init() {
        configureAmplify()
        URLCache.shared.memoryCapacity = 50_000_000 // ~50 MB
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        UINavigationBar.appearance().standardAppearance = appearance
        
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(Color("accent3"))
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(Color.white)], for: .selected)
    }
    
    var body: some Scene {
        WindowGroup {
            if authModel.signedInEmail == "" {
                AuthView()
                    .background(Color("accent1").ignoresSafeArea())
                    .ignoresSafeArea()
                    .environmentObject(authModel)
                    .task {
                        await authModel.checkStatus()
                    }
            } else {
                NavTabView()
                    .transition(.scale)
                    .background(Color("bg"))
                    .ignoresSafeArea()
                    .environmentObject(authModel)
                    .environmentObject(recipesModel)
                    .environmentObject(recipeSheetModel)
                    .environmentObject(imagesModel)
                    .environmentObject(plansModel)
                    .environmentObject(plannerModel)
                    .environmentObject(trackerModel)
                    .task {
                        if authModel.signedInEmail != "" {
                            async let _ = await recipesModel.getRecipes()
                            await plansModel.getPlans()
                            plannerModel.interpretPlan(date: plannerModel.selectedDate, plans: plansModel.plans, recipes: recipesModel.recipes)
                            trackerModel.getValuesForGraph(plans: plansModel.plans, recipes: recipesModel.recipes)
                            
                            do {
                                let url = try await imagesModel.getImageUrl(key: authModel.signedInEmail)
                                imagesModel.avatarURL = url
                            } catch {
                                print("\(error)")
                            }
                        }
                    }
            }
        }
    }

}
