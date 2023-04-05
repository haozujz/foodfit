//
//  NavTabView.swift
//  CloudRecipes
//
//  Created by Joseph Zhu on 24/12/2022.
//

import SwiftUI

struct NavTabView: View {
    @EnvironmentObject private var authModel: AuthModel
    @EnvironmentObject private var recipesModel: RecipesModel
    @EnvironmentObject private var recipeSheetModel: RecipeSheetModel
    @EnvironmentObject private var plansModel: PlansModel
    
    @State private var currentTab: TabBarItem = .recipes
    
    enum TabBarItem {
        case recipes, planner, tracker, settings
        
        var icon: String {
            switch self {
            case .recipes: return "fork.knife"
            case .planner: return "doc.plaintext.fill"
            case .tracker: return "chart.line.uptrend.xyaxis.circle.fill"
            case .settings: return "person"
            }
        }
    }
    
    init() {
        UITabBar.appearance().backgroundColor = UIColor.white
    }
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
            TabView(selection: $currentTab) {
                RecipesView(isPreviewingForPlanner: false)
                    .tag(.recipes as TabBarItem)
                    .tabItem {
                        Image(systemName: TabBarItem.recipes.icon)
                            .resizable()
                            .renderingMode(.template)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 36, height: 36)
                            .font(.system(size: 36, weight: .bold))
                            .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 3)
                        Text("Recipes")
                    }
                
                PlannerView()
                    .tag(.planner as TabBarItem)
                    .tabItem {
                        Image(systemName: TabBarItem.planner.icon)
                            .resizable()
                            .renderingMode(.template)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40)
                            .font(.system(size: 40, weight: .bold))
                            .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 3)
                        Text("Planner")
                    }
                
                TrackerView()
                    .tag(.tracker as TabBarItem)
                    .tabItem {
                        Image(systemName: TabBarItem.tracker.icon)
                            .resizable()
                            .renderingMode(.template)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40)
                            .font(.system(size: 40, weight: .bold))
                            .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 3)
                        Text("Tracker")
                    }
                      
                SettingsView()
                    .tag(.settings as TabBarItem)
                    .tabItem {
                        Image(systemName: TabBarItem.settings.icon)
                            .resizable()
                            .renderingMode(.template)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40)
                            .font(.system(size: 40, weight: .bold))
                            .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 3)
                        Text("Profile")
                    }
            }
            .accentColor(.green)
        }
    }
}

struct NavTabView_Previews: PreviewProvider {
    static var previews: some View {
        NavTabView()
    }
}
