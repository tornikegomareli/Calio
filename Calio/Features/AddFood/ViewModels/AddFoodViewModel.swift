import SwiftUI
import Observation
import SwiftData

@MainActor
@Observable
final class AddFoodViewModel {
    weak var todayLog: DailyLog?
    private var modelContext: ModelContext?
    
    var searchText = ""
    var selectedFood: FoodItem?
    
    var calories: String = ""
    var protein: String = ""
    var carbs: String = ""
    var fat: String = ""
    var weight: Double = 100
    var foodName: String = ""
    
    var saveAsPreset = false
    var isQuickAdd = true
    
    var canSave: Bool {
        if isQuickAdd {
            return Int(calories) ?? 0 > 0
        } else {
            return !foodName.isEmpty && Int(calories) ?? 0 > 0
        }
    }
    
    init(todayLog: DailyLog?) {
        self.todayLog = todayLog
    }
    
    func configure(with context: ModelContext) {
        self.modelContext = context
    }
    
    func save(dismiss: () -> Void) {
        guard let context = modelContext, let todayLog = todayLog else { return }
        
        let cal = Int(calories) ?? 0
        let pro = Double(protein) ?? 0
        let carb = Double(carbs) ?? 0
        let ft = Double(fat) ?? 0
        
        let entry = FoodEntry(
            name: isQuickAdd ? "Quick Add" : foodName,
            calories: cal,
            protein: pro,
            carbs: carb,
            fat: ft,
            weight: isQuickAdd ? 0 : weight,
            isQuickAdd: isQuickAdd
        )
        
        todayLog.entries.append(entry)
        
        if saveAsPreset && !isQuickAdd {
            let preset = Preset(
                name: foodName,
                calories: cal,
                protein: pro,
                carbs: carb,
                fat: ft,
                defaultWeight: weight
            )
            context.insert(preset)
        }
        
        try? context.save()
        HapticManager.notification(.success)
        dismiss()
    }
    
    func saveAndAddAnother() {
        guard let context = modelContext, let todayLog = todayLog else { return }
        
        let cal = Int(calories) ?? 0
        let pro = Double(protein) ?? 0
        let carb = Double(carbs) ?? 0
        let ft = Double(fat) ?? 0
        
        let entry = FoodEntry(
            name: isQuickAdd ? "Quick Add" : foodName,
            calories: cal,
            protein: pro,
            carbs: carb,
            fat: ft,
            weight: isQuickAdd ? 0 : weight,
            isQuickAdd: isQuickAdd
        )
        
        todayLog.entries.append(entry)
        
        if saveAsPreset && !isQuickAdd {
            let preset = Preset(
                name: foodName,
                calories: cal,
                protein: pro,
                carbs: carb,
                fat: ft,
                defaultWeight: weight
            )
            context.insert(preset)
        }
        
        try? context.save()
        HapticManager.notification(.success)
        
        calories = ""
        protein = ""
        carbs = ""
        fat = ""
        foodName = ""
        weight = 100
        saveAsPreset = false
    }
    
    func updateCaloriesFromMacros() {
        let pro = Double(protein) ?? 0
        let carb = Double(carbs) ?? 0
        let ft = Double(fat) ?? 0
        
        let totalCalories = Int((pro * 4) + (carb * 4) + (ft * 9))
        if totalCalories > 0 {
            calories = "\(totalCalories)"
        }
    }
}

struct FoodItem: Identifiable {
    let id = UUID()
    let name: String
    let calories: Int
    let protein: Double
    let carbs: Double
    let fat: Double
    let weight: Double
}
