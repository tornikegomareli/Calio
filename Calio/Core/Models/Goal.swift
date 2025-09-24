import Foundation
import SwiftData

@Model
final class Goal {
  var calories: Int
  var protein: Double?
  var carbs: Double?
  var fat: Double?
  var createdAt: Date
  var updatedAt: Date
  
  init(
    calories: Int,
    protein: Double? = nil,
    carbs: Double? = nil,
    fat: Double? = nil
  ) {
    self.calories = calories
    self.protein = protein
    self.carbs = carbs
    self.fat = fat
    self.createdAt = Date()
    self.updatedAt = Date()
  }
  
  var hasProteinGoal: Bool { protein != nil }
  var hasCarbsGoal: Bool { carbs != nil }
  var hasFatGoal: Bool { fat != nil }
  var hasMacros: Bool { hasProteinGoal || hasCarbsGoal || hasFatGoal }
}
