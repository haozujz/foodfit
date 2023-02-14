// swiftlint:disable all
import Amplify
import Foundation

extension Plan {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case date
    case breakfastItems
    case lunchItems
    case dinnerItems
    case otherItems
    case exerciseItems
    case exerciseMultipliers
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let plan = Plan.keys
    
    model.authRules = [
      rule(allow: .owner, ownerField: "owner", identityClaim: "cognito:username", provider: .userPools, operations: [.create, .update, .delete, .read])
    ]
    
    model.pluralName = "Plans"
    
    model.attributes(
      .primaryKey(fields: [plan.id])
    )
    
    model.fields(
      .field(plan.id, is: .required, ofType: .string),
      .field(plan.date, is: .required, ofType: .date),
      .field(plan.breakfastItems, is: .required, ofType: .embeddedCollection(of: String.self)),
      .field(plan.lunchItems, is: .required, ofType: .embeddedCollection(of: String.self)),
      .field(plan.dinnerItems, is: .required, ofType: .embeddedCollection(of: String.self)),
      .field(plan.otherItems, is: .required, ofType: .embeddedCollection(of: String.self)),
      .field(plan.exerciseItems, is: .required, ofType: .embeddedCollection(of: String.self)),
      .field(plan.exerciseMultipliers, is: .required, ofType: .embeddedCollection(of: Double.self)),
      .field(plan.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(plan.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
}

extension Plan: ModelIdentifiable {
  public typealias IdentifierFormat = ModelIdentifierFormat.Default
  public typealias IdentifierProtocol = DefaultModelIdentifier<Self>
}