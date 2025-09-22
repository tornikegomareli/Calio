import Foundation
import SwiftData

@Model
final class DailyLog {
    var date: Date
    
    @Relationship(deleteRule: .cascade, inverse: \FoodEntry.dailyLog)
    var entries: [FoodEntry] = []
    
    var totalCalories: Int {
        entries.reduce(0) { $0 + $1.calories }
    }
    
    var totalProtein: Double {
        entries.reduce(0) { $0 + $1.protein }
    }
    
    var totalCarbs: Double {
        entries.reduce(0) { $0 + $1.carbs }
    }
    
    var totalFat: Double {
        entries.reduce(0) { $0 + $1.fat }
    }
    
    init(date: Date = Date()) {
        self.date = Calendar.current.startOfDay(for: date)
    }
    
    func progress(for goal: Goal) -> (calories: Double, protein: Double, carbs: Double, fat: Double) {
        let caloriesProgress = goal.calories > 0 ? Double(totalCalories) / Double(goal.calories) : 0
        let proteinProgress = (goal.protein ?? 0) > 0 ? totalProtein / goal.protein! : 0
        let carbsProgress = (goal.carbs ?? 0) > 0 ? totalCarbs / goal.carbs! : 0
        let fatProgress = (goal.fat ?? 0) > 0 ? totalFat / goal.fat! : 0
        
        return (caloriesProgress, proteinProgress, carbsProgress, fatProgress)
    }
    
    func remaining(for goal: Goal) -> (calories: Int, protein: Double?, carbs: Double?, fat: Double?) {
        let caloriesRemaining = max(0, goal.calories - totalCalories)
        let proteinRemaining = goal.protein.map { max(0, $0 - totalProtein) }
        let carbsRemaining = goal.carbs.map { max(0, $0 - totalCarbs) }
        let fatRemaining = goal.fat.map { max(0, $0 - totalFat) }
        
        return (caloriesRemaining, proteinRemaining, carbsRemaining, fatRemaining)
    }
}