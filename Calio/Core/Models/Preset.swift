import Foundation
import SwiftData

@Model
final class Preset {
  var name: String
  var calories: Int
  var protein: Double
  var carbs: Double
  var fat: Double
  var defaultWeight: Double
  var lastUsedAt: Date?
  var useCount: Int
  var order: Int
  
  init(
    name: String,
    calories: Int,
    protein: Double = 0,
    carbs: Double = 0,
    fat: Double = 0,
    defaultWeight: Double = 100,
    order: Int = 0
  ) {
    self.name = name
    self.calories = calories
    self.protein = protein
    self.carbs = carbs
    self.fat = fat
    self.defaultWeight = defaultWeight
    self.lastUsedAt = nil
    self.useCount = 0
    self.order = order
  }
  
  func toFoodEntry(weight: Double? = nil) -> FoodEntry {
    let finalWeight = weight ?? defaultWeight
    let entry = FoodEntry(
      name: name,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      weight: finalWeight
    )
    
    if finalWeight != defaultWeight {
      let scaledMacros = entry.scaledMacros(for: finalWeight)
      entry.calories = entry.scaledCalories(for: finalWeight)
      entry.protein = scaledMacros.protein
      entry.carbs = scaledMacros.carbs
      entry.fat = scaledMacros.fat
    }
    
    return entry
  }
  
  func recordUsage() {
    lastUsedAt = Date()
    useCount += 1
  }
}
