// swiftlint:disable all
import Amplify
import Foundation

public struct Plan: Model {
  public let id: String
  public var date: Temporal.Date
  public var breakfastItems: [String]
  public var lunchItems: [String]
  public var dinnerItems: [String]
  public var otherItems: [String]
  public var exerciseItems: [String]
  public var exerciseMultipliers: [Double]
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      date: Temporal.Date,
      breakfastItems: [String] = [],
      lunchItems: [String] = [],
      dinnerItems: [String] = [],
      otherItems: [String] = [],
      exerciseItems: [String] = [],
      exerciseMultipliers: [Double] = []) {
    self.init(id: id,
      date: date,
      breakfastItems: breakfastItems,
      lunchItems: lunchItems,
      dinnerItems: dinnerItems,
      otherItems: otherItems,
      exerciseItems: exerciseItems,
      exerciseMultipliers: exerciseMultipliers,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      date: Temporal.Date,
      breakfastItems: [String] = [],
      lunchItems: [String] = [],
      dinnerItems: [String] = [],
      otherItems: [String] = [],
      exerciseItems: [String] = [],
      exerciseMultipliers: [Double] = [],
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.date = date
      self.breakfastItems = breakfastItems
      self.lunchItems = lunchItems
      self.dinnerItems = dinnerItems
      self.otherItems = otherItems
      self.exerciseItems = exerciseItems
      self.exerciseMultipliers = exerciseMultipliers
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}