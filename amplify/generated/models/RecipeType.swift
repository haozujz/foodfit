// swiftlint:disable all
import Amplify
import Foundation

public enum RecipeType: String, EnumPersistable, CaseIterable {
  case grain = "GRAIN"
  case meat = "MEAT"
  case vegetable = "VEGETABLE"
  case snack = "SNACK"
  case drink = "DRINK"
}
