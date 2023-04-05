//
//  PlansModel.swift
//  CloudRecipes
//
//  Created by Joseph Zhu on 1/2/2023.
//

import Foundation
import SwiftUI
import Amplify
import Combine

final class PlansModel: ObservableObject {
    @Published var updateCounter: Int = 0
    
    var plans: [Plan] = []
    private var plansSubscription: AnyCancellable?
    
    init () {
        subscribeToPlans()
    }
    
    func getPlans() async {
        do {
            let result = try await Amplify.DataStore.query(Plan.self)
            DispatchQueue.main.async {
                self.plans = result
                print(self.plans.count, "plans retrieved successfully")
            }
        } catch let error as DataStoreError {
            print("Error retrieving plans: \(error)")
        } catch {
            print("Unexpected error: \(error)")
        }
    }
    
    func savePlan(plan: Plan) async {
        do {
            try await Amplify.DataStore.save(plan)
            print("Created a new plan successfully")
        } catch let error as DataStoreError {
            print("Error creating plan: \(error)")
        } catch {
            print("Unexpected error: \(error)")
        }
    }
    
    func deletePlan(plan: Plan) async {
        do {
            try await Amplify.DataStore.delete(plan)
            print("Plan deleted")
        } catch let error as DataStoreError {
            print("Error deleting plan: \(error)")
        } catch {
            print("Unexpected error: \(error)")
        }
    }
    
    func subscribeToPlans() {
        plansSubscription = Amplify.Publisher.create(Amplify.DataStore.observe(Plan.self))
        .sink {
            if case let .failure(error) = $0 {
                print("Subscription received error - \(error)")
            }
        }
        receiveValue: { changes in
            print("Subscription received mutation: \(changes)")
            
            Task {
                await self.getPlans()
                DispatchQueue.main.async {
                    self.updateCounter += 1
                }
            }
        }
    }
    
    func unsubscribeFromPlans() {
        plansSubscription?.cancel()
    }
}
