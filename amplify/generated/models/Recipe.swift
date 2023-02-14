// swiftlint:disable all
import Amplify
import Foundation

public struct Recipe: Model {
  public let id: String
  public var name: String
  public var image: String
  public var servingSize: Int
  public var cookingTime: Int
  public var calories: Int
  public var protein: Int
  public var carbs: Int
  public var fat: Int
  public var ingredients: [String]
  public var methodSteps: [String]
  public var recipeType: RecipeType
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      name: String,
      image: String,
      servingSize: Int,
      cookingTime: Int,
      calories: Int,
      protein: Int,
      carbs: Int,
      fat: Int,
      ingredients: [String] = [],
      methodSteps: [String] = [],
      recipeType: RecipeType) {
    self.init(id: id,
      name: name,
      image: image,
      servingSize: servingSize,
      cookingTime: cookingTime,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      ingredients: ingredients,
      methodSteps: methodSteps,
      recipeType: recipeType,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      name: String,
      image: String,
      servingSize: Int,
      cookingTime: Int,
      calories: Int,
      protein: Int,
      carbs: Int,
      fat: Int,
      ingredients: [String] = [],
      methodSteps: [String] = [],
      recipeType: RecipeType,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.name = name
      self.image = image
      self.servingSize = servingSize
      self.cookingTime = cookingTime
      self.calories = calories
      self.protein = protein
      self.carbs = carbs
      self.fat = fat
      self.ingredients = ingredients
      self.methodSteps = methodSteps
      self.recipeType = recipeType
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}
