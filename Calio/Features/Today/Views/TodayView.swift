import SwiftUI
import SwiftData

struct TodayView: View {
  @Environment(\.modelContext) private var modelContext
  @State private var viewModel = TodayViewModel()
  
  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: 20) {
          progressSection
          
          quickActionsSection
          
          if !viewModel.recentPresets.isEmpty {
            presetsSection
          }
          
          if let todayLog = viewModel.todayLog, !todayLog.entries.isEmpty {
            entriesSection
          }
        }
        .padding()
      }
      .navigationTitle("Today")
      .navigationBarTitleDisplayMode(.large)
      .background(Color(.systemGroupedBackground))
      .sheet(isPresented: $viewModel.showAddFood) {
        AddFoodView(viewModel: AddFoodViewModel(todayLog: viewModel.todayLog))
          .presentationDetents([.medium, .large])
          .presentationDragIndicator(.visible)
      }
      .onAppear {
        viewModel.configure(with: modelContext)
      }
      .refreshable {
        viewModel.loadTodayData()
      }
    }
  }
  
  private var progressSection: some View {
    VStack(spacing: 16) {
      ZStack {
        MultiRingView(
          caloriesProgress: viewModel.caloriesProgress,
          proteinProgress: viewModel.proteinProgress,
          carbsProgress: viewModel.carbsProgress,
          fatProgress: viewModel.fatProgress
        )
        .frame(width: 220, height: 220)
        
        VStack(spacing: 4) {
          Text("\(viewModel.caloriesUsed)")
            .font(.system(size: 42, weight: .bold, design: .rounded))
            .foregroundColor(.primary)
        }
      }
      
      if viewModel.isOverGoal {
        HStack {
          Image(systemName: "exclamationmark.triangle.fill")
            .foregroundColor(.orange)
          Text("+\(viewModel.overageAmount) kcal over goal")
            .font(.system(size: 14, weight: .medium, design: .rounded))
            .foregroundColor(.orange)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.orange.opacity(0.1))
        .clipShape(Capsule())
      } else {
        HStack {
          Image(systemName: "checkmark.circle.fill")
            .foregroundColor(.green)
          Text("\(viewModel.caloriesRemaining) kcal remaining")
            .font(.system(size: 14, weight: .medium, design: .rounded))
            .foregroundColor(.primary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(.secondarySystemBackground))
        .clipShape(Capsule())
      }
      
      if let goal = viewModel.currentGoal, goal.hasMacros {
        MacroSummaryView(
          todayLog: viewModel.todayLog,
          goal: goal
        )
      }
    }
    .padding(.vertical)
  }
  
  private var quickActionsSection: some View {
    VStack(spacing: 12) {
      QuickAddButton {
        viewModel.showAddFood = true
      }
      
      HStack(spacing: 12) {
        QuickCalorieButton(calories: 100) {
          viewModel.quickAddCalories(100)
        }
        
        QuickCalorieButton(calories: 200) {
          viewModel.quickAddCalories(200)
        }
        
        QuickCalorieButton(calories: 300) {
          viewModel.quickAddCalories(300)
        }
      }
    }
  }
  
  private var presetsSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Quick Add")
        .font(.system(size: 18, weight: .semibold, design: .rounded))
        .foregroundColor(.primary)
      
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 12) {
          ForEach(viewModel.recentPresets) { preset in
            PresetButton(preset: preset) {
              viewModel.addPresetEntry(preset)
            }
          }
        }
      }
    }
  }
  
  private var entriesSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Today's Entries")
        .font(.system(size: 18, weight: .semibold, design: .rounded))
        .foregroundColor(.primary)
      
      VStack(spacing: 8) {
        ForEach(viewModel.todayLog?.entries ?? []) { entry in
          EntryRow(entry: entry) {
            viewModel.deleteEntry(entry)
          }
        }
      }
    }
  }
}

struct QuickCalorieButton: View {
  let calories: Int
  let action: () -> Void
  
  var body: some View {
    Button(action: action) {
      VStack(spacing: 4) {
        Text("\(calories)")
          .font(.system(size: 20, weight: .semibold, design: .rounded))
        Text("kcal")
          .font(.system(size: 12, weight: .regular, design: .rounded))
          .foregroundColor(.secondary)
      }
      .frame(maxWidth: .infinity)
      .padding(.vertical, 16)
      .background(Color(.secondarySystemBackground))
      .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
    .buttonStyle(.plain)
  }
}

struct MacroSummaryView: View {
  let todayLog: DailyLog?
  let goal: Goal
  
  var body: some View {
    HStack(spacing: 24) {
      if let proteinGoal = goal.protein {
        MacroIndicator(
          label: "Protein",
          current: todayLog?.totalProtein ?? 0,
          goal: proteinGoal,
          color: .red
        )
      }
      
      if let carbsGoal = goal.carbs {
        MacroIndicator(
          label: "Carbs",
          current: todayLog?.totalCarbs ?? 0,
          goal: carbsGoal,
          color: .blue
        )
      }
      
      if let fatGoal = goal.fat {
        MacroIndicator(
          label: "Fat",
          current: todayLog?.totalFat ?? 0,
          goal: fatGoal,
          color: .yellow
        )
      }
    }
    .padding(.horizontal)
  }
}

struct MacroIndicator: View {
  let label: String
  let current: Double
  let goal: Double
  let color: Color
  
  private var remaining: Double {
    max(0, goal - current)
  }
  
  var body: some View {
    VStack(spacing: 4) {
      Text(label)
        .font(.system(size: 12, weight: .medium, design: .rounded))
        .foregroundColor(.secondary)
      
      Text("\(Int(current))g")
        .font(.system(size: 16, weight: .semibold, design: .rounded))
        .foregroundColor(color)
      
      Text("\(Int(remaining)) left")
        .font(.system(size: 11, weight: .regular, design: .rounded))
        .foregroundColor(.secondary)
    }
  }
}

struct EntryRow: View {
  let entry: FoodEntry
  let onDelete: () -> Void
  
  var body: some View {
    HStack {
      VStack(alignment: .leading, spacing: 4) {
        Text(entry.name)
          .font(.system(size: 16, weight: .medium, design: .rounded))
          .foregroundColor(.primary)
        
        HStack(spacing: 8) {
          Text("\(entry.calories) kcal")
            .font(.system(size: 14, weight: .regular, design: .rounded))
            .foregroundColor(.secondary)
          
          if entry.weight > 0 {
            Text("• \(Int(entry.weight))g")
              .font(.system(size: 14, weight: .regular, design: .rounded))
              .foregroundColor(.secondary)
          }
          
          if entry.protein > 0 {
            Text("• P: \(Int(entry.protein))g")
              .font(.system(size: 12, weight: .regular, design: .rounded))
              .foregroundColor(.secondary)
          }
        }
        
        Text(entry.timestamp.formatted(date: .omitted, time: .shortened))
          .font(.system(size: 12, weight: .regular, design: .rounded))
          .foregroundColor(Color(.tertiaryLabel))
      }
      
      Spacer()
      
      Button(action: onDelete) {
        Image(systemName: "trash")
          .font(.system(size: 14))
          .foregroundColor(.red)
      }
      .buttonStyle(.plain)
    }
    .padding()
    .background(Color(.secondarySystemBackground))
    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
  }
}

#Preview {
  TodayView()
    .modelContainer(for: [Goal.self, DailyLog.self, FoodEntry.self, Preset.self])
}
