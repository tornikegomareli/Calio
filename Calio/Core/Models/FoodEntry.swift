import Foundation
import SwiftData

@Model
final class FoodEntry {
    var name: String
    var calories: Int
    var protein: Double
    var carbs: Double
    var fat: Double
    var weight: Double
    var timestamp: Date
    var isQuickAdd: Bool
    
    @Relationship(deleteRule: .nullify)
    var dailyLog: DailyLog?
    
    init(
        name: String,
        calories: Int,
        protein: Double = 0,
        carbs: Double = 0,
        fat: Double = 0,
        weight: Double = 0,
        isQuickAdd: Bool = false
    ) {
        self.name = name
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.weight = weight
        self.timestamp = Date()
        self.isQuickAdd = isQuickAdd
    }
    
    func scaledCalories(for newWeight: Double) -> Int {
        guard weight > 0 else { return calories }
        return Int(Double(calories) * (newWeight / weight))
    }
    
    func scaledMacros(for newWeight: Double) -> (protein: Double, carbs: Double, fat: Double) {
        guard weight > 0 else { return (protein, carbs, fat) }
        let scale = newWeight / weight
        return (protein * scale, carbs * scale, fat * scale)
    }
}