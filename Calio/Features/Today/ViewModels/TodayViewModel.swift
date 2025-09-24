import SwiftUI
import SwiftData
import Combine

@MainActor
@Observable
final class TodayViewModel {
  private var modelContext: ModelContext?
  
  var currentGoal: Goal?
  var todayLog: DailyLog?
  var recentPresets: [Preset] = []
  var showAddFood = false
  
  var caloriesUsed: Int {
    todayLog?.totalCalories ?? 0
  }
  
  var caloriesGoal: Int {
    currentGoal?.calories ?? 2000
  }
  
  var caloriesRemaining: Int {
    max(0, caloriesGoal - caloriesUsed)
  }
  
  var caloriesProgress: Double {
    caloriesGoal > 0 ? Double(caloriesUsed) / Double(caloriesGoal) : 0
  }
  
  var proteinProgress: Double? {
    guard let goal = currentGoal?.protein, goal > 0 else { return nil }
    return (todayLog?.totalProtein ?? 0) / goal
  }
  
  var carbsProgress: Double? {
    guard let goal = currentGoal?.carbs, goal > 0 else { return nil }
    return (todayLog?.totalCarbs ?? 0) / goal
  }
  
  var fatProgress: Double? {
    guard let goal = currentGoal?.fat, goal > 0 else { return nil }
    return (todayLog?.totalFat ?? 0) / goal
  }
  
  var isOverGoal: Bool {
    caloriesUsed > caloriesGoal
  }
  
  var overageAmount: Int {
    max(0, caloriesUsed - caloriesGoal)
  }
  
  func configure(with context: ModelContext) {
    self.modelContext = context
    loadTodayData()
  }
  
  func loadTodayData() {
    guard let context = modelContext else { return }
    
    let today = Calendar.current.startOfDay(for: Date())
    
    let goalRequest = FetchDescriptor<Goal>(
      sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
    )
    currentGoal = try? context.fetch(goalRequest).first
    
    let logRequest = FetchDescriptor<DailyLog>(
      predicate: #Predicate { log in
        log.date == today
      }
    )
    
    if let existingLog = try? context.fetch(logRequest).first {
      todayLog = existingLog
    } else {
      let newLog = DailyLog(date: today)
      context.insert(newLog)
      todayLog = newLog
      try? context.save()
    }
    
    loadRecentPresets()
  }
  
  func loadRecentPresets() {
    guard let context = modelContext else { return }
    
    let request = FetchDescriptor<Preset>(
      sortBy: [
        SortDescriptor(\.useCount, order: .reverse),
        SortDescriptor(\.lastUsedAt, order: .reverse)
      ]
    )
    
    if let allPresets = try? context.fetch(request) {
      recentPresets = Array(allPresets.prefix(5))
    }
  }
  
  func addPresetEntry(_ preset: Preset) {
    guard let context = modelContext, let todayLog = todayLog else { return }
    
    let entry = preset.toFoodEntry()
    todayLog.entries.append(entry)
    preset.recordUsage()
    
    try? context.save()
    HapticManager.notification(.success)
    loadTodayData()
  }
  
  func deleteEntry(_ entry: FoodEntry) {
    guard let context = modelContext else { return }
    
    context.delete(entry)
    try? context.save()
    loadTodayData()
  }
  
  func quickAddCalories(_ calories: Int) {
    guard let context = modelContext, let todayLog = todayLog else { return }
    
    let entry = FoodEntry(
      name: "Quick Add",
      calories: calories,
      isQuickAdd: true
    )
    todayLog.entries.append(entry)
    
    try? context.save()
    HapticManager.notification(.success)
    loadTodayData()
  }
}
