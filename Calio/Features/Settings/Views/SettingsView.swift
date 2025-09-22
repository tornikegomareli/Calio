import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    @State private var currentGoal: Goal?
    @State private var showEditGoal = false
    @State private var useHealthKit = false
    @State private var enableNotifications = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Daily Goal")
                                .font(.system(size: 15, weight: .regular, design: .rounded))
                                .foregroundColor(.primary)
                            
                            if let goal = currentGoal {
                                Text("\(goal.calories) kcal")
                                    .font(.system(size: 13, weight: .regular, design: .rounded))
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        Button("Edit") {
                            showEditGoal = true
                        }
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                    }
                    
                    if let goal = currentGoal, goal.hasMacros {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Macro Goals")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 16) {
                                if let protein = goal.protein {
                                    MacroGoalLabel(label: "Protein", value: protein, color: .red)
                                }
                                if let carbs = goal.carbs {
                                    MacroGoalLabel(label: "Carbs", value: carbs, color: .blue)
                                }
                                if let fat = goal.fat {
                                    MacroGoalLabel(label: "Fat", value: fat, color: .yellow)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                } header: {
                    Text("Nutrition Goals")
                }
                
                Section {
                    Toggle(isOn: $useHealthKit) {
                        Label("Sync with Health", systemImage: "heart.fill")
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                    }
                    .onChange(of: useHealthKit) { _, newValue in
                        if newValue {
                            requestHealthKitPermission()
                        }
                    }
                    
                    Toggle(isOn: $enableNotifications) {
                        Label("Daily Reminders", systemImage: "bell.fill")
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                    }
                    .onChange(of: enableNotifications) { _, newValue in
                        if newValue {
                            requestNotificationPermission()
                        }
                    }
                } header: {
                    Text("Integrations")
                } footer: {
                    Text("Health sync writes your daily calorie intake to Apple Health. Reminders help you log meals on time.")
                        .font(.system(size: 12, design: .rounded))
                }
                
                Section {
                    Button {
                        exportData()
                    } label: {
                        Label("Export Data", systemImage: "square.and.arrow.up")
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                    }
                    
                    Button {
                        clearAllData()
                    } label: {
                        Label("Clear All Data", systemImage: "trash")
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                            .foregroundColor(.red)
                    }
                } header: {
                    Text("Data")
                }
                
                Section {
                    HStack {
                        Text("Version")
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                        Spacer()
                        Text("1.0.0")
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    
                    Link(destination: URL(string: "https://example.com/privacy")!) {
                        HStack {
                            Text("Privacy Policy")
                                .font(.system(size: 15, weight: .regular, design: .rounded))
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Link(destination: URL(string: "https://example.com/terms")!) {
                        HStack {
                            Text("Terms of Service")
                                .font(.system(size: 15, weight: .regular, design: .rounded))
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("About")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                loadGoal()
            }
            .sheet(isPresented: $showEditGoal) {
                EditGoalView(goal: currentGoal)
                    .presentationDetents([.medium])
            }
        }
    }
    
    private func loadGoal() {
        let request = FetchDescriptor<Goal>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        currentGoal = try? modelContext.fetch(request).first
    }
    
    private func requestHealthKitPermission() {
        // HealthKit implementation would go here
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            DispatchQueue.main.async {
                enableNotifications = granted
            }
        }
    }
    
    private func exportData() {
        // Export implementation
    }
    
    private func clearAllData() {
        // Clear data implementation with confirmation
    }
}

struct MacroGoalLabel: View {
    let label: String
    let value: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(color)
            Text("\(Int(value))g")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
        }
    }
}

struct EditGoalView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let goal: Goal?
    @State private var calories: String
    @State private var protein: String
    @State private var carbs: String
    @State private var fat: String
    @State private var enableProtein: Bool
    @State private var enableCarbs: Bool
    @State private var enableFat: Bool
    
    init(goal: Goal?) {
        self.goal = goal
        self._calories = State(initialValue: "\(goal?.calories ?? 2000)")
        self._protein = State(initialValue: "\(Int(goal?.protein ?? 150))")
        self._carbs = State(initialValue: "\(Int(goal?.carbs ?? 250))")
        self._fat = State(initialValue: "\(Int(goal?.fat ?? 65))")
        self._enableProtein = State(initialValue: goal?.hasProteinGoal ?? false)
        self._enableCarbs = State(initialValue: goal?.hasCarbsGoal ?? false)
        self._enableFat = State(initialValue: goal?.hasFatGoal ?? false)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Label("Daily Calories", systemImage: "flame.fill")
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                        Spacer()
                        TextField("2000", text: $calories)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("kcal")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section {
                    Toggle(isOn: $enableProtein) {
                        HStack {
                            Label("Protein", systemImage: "p.square.fill")
                                .foregroundColor(.red)
                            if enableProtein {
                                Spacer()
                                TextField("150", text: $protein)
                                    .keyboardType(.numberPad)
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: 60)
                                Text("g")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    Toggle(isOn: $enableCarbs) {
                        HStack {
                            Label("Carbs", systemImage: "c.square.fill")
                                .foregroundColor(.blue)
                            if enableCarbs {
                                Spacer()
                                TextField("250", text: $carbs)
                                    .keyboardType(.numberPad)
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: 60)
                                Text("g")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    Toggle(isOn: $enableFat) {
                        HStack {
                            Label("Fat", systemImage: "f.square.fill")
                                .foregroundColor(.yellow)
                            if enableFat {
                                Spacer()
                                TextField("65", text: $fat)
                                    .keyboardType(.numberPad)
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: 60)
                                Text("g")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                } header: {
                    Text("Macro Goals (Optional)")
                } footer: {
                    Text("Track specific macronutrients to optimize your nutrition.")
                        .font(.system(size: 12, design: .rounded))
                }
            }
            .navigationTitle("Edit Goals")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveGoal()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func saveGoal() {
        let newGoal = Goal(
            calories: Int(calories) ?? 2000,
            protein: enableProtein ? Double(protein) ?? 0 : nil,
            carbs: enableCarbs ? Double(carbs) ?? 0 : nil,
            fat: enableFat ? Double(fat) ?? 0 : nil
        )
        
        if let existingGoal = goal {
            existingGoal.calories = newGoal.calories
            existingGoal.protein = newGoal.protein
            existingGoal.carbs = newGoal.carbs
            existingGoal.fat = newGoal.fat
            existingGoal.updatedAt = Date()
        } else {
            modelContext.insert(newGoal)
        }
        
        try? modelContext.save()
        HapticManager.notification(.success)
        dismiss()
    }
}

#Preview {
    SettingsView()
        .environment(AppState())
        .modelContainer(for: [Goal.self])
}