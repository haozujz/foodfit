// swiftlint:disable all
import Amplify
import Foundation

extension Recipe {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case name
    case image
    case servingSize
    case cookingTime
    case calories
    case protein
    case carbs
    case fat
    case ingredients
    case methodSteps
    case recipeType
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let recipe = Recipe.keys
    
    model.authRules = [
      rule(allow: .owner, ownerField: "owner", identityClaim: "cognito:username", provider: .userPools, operations: [.create, .update, .delete, .read])
    ]
    
    model.pluralName = "Recipes"
    
    model.attributes(
      .primaryKey(fields: [recipe.id])
    )
    
    model.fields(
      .field(recipe.id, is: .required, ofType: .string),
      .field(recipe.name, is: .required, ofType: .string),
      .field(recipe.image, is: .required, ofType: .string),
      .field(recipe.servingSize, is: .required, ofType: .int),
      .field(recipe.cookingTime, is: .required, ofType: .int),
      .field(recipe.calories, is: .required, ofType: .int),
      .field(recipe.protein, is: .required, ofType: .int),
      .field(recipe.carbs, is: .required, ofType: .int),
      .field(recipe.fat, is: .required, ofType: .int),
      .field(recipe.ingredients, is: .required, ofType: .embeddedCollection(of: String.self)),
      .field(recipe.methodSteps, is: .required, ofType: .embeddedCollection(of: String.self)),
      .field(recipe.recipeType, is: .required, ofType: .enum(type: RecipeType.self)),
      .field(recipe.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(recipe.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
}

extension Recipe: ModelIdentifiable {
  public typealias IdentifierFormat = ModelIdentifierFormat.Default
  public typealias IdentifierProtocol = DefaultModelIdentifier<Self>
}