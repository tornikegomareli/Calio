import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    
    @State private var calories = "2000"
    @State private var enableProtein = false
    @State private var enableCarbs = false
    @State private var enableFat = false
    @State private var protein = "150"
    @State private var carbs = "250"
    @State private var fat = "65"
    @State private var useHealthKit = false
    @State private var enableNotifications = false
    
    @State private var currentStep = 0
    
    var body: some View {
        VStack(spacing: 0) {
            progressBar
            
            TabView(selection: $currentStep) {
                welcomeView
                    .tag(0)
                
                goalSetupView
                    .tag(1)
                
                macroSetupView
                    .tag(2)
                
                integrationsView
                    .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.3), value: currentStep)
            
            navigationButtons
        }
        .background(Color(.systemBackground))
    }
    
    private var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray5))
                    .frame(height: 4)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.accentColor)
                    .frame(width: geometry.size.width * CGFloat(currentStep + 1) / 4, height: 4)
                    .animation(.easeInOut(duration: 0.3), value: currentStep)
            }
        }
        .frame(height: 4)
        .padding(.horizontal)
        .padding(.top, 60)
        .padding(.bottom, 20)
    }
    
    private var welcomeView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "flame.fill")
                .font(.system(size: 80))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.orange, .red],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            VStack(spacing: 12) {
                Text("Welcome to Calio")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                
                Text("Track calories in seconds,\nnot minutes")
                    .font(.system(size: 18, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .padding()
    }
    
    private var goalSetupView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            VStack(spacing: 12) {
                Text("Set Your Daily Goal")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                
                Text("We'll help you stay on track")
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Text("Daily Calories")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    HStack {
                        TextField("2000", text: $calories)
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)
                            .frame(width: 150)
                        
                        Text("kcal")
                            .font(.system(size: 24, weight: .regular, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                }
                
                HStack(spacing: 12) {
                    QuickGoalButton(label: "Lose", calories: "1500") {
                        calories = "1500"
                    }
                    
                    QuickGoalButton(label: "Maintain", calories: "2000") {
                        calories = "2000"
                    }
                    
                    QuickGoalButton(label: "Gain", calories: "2500") {
                        calories = "2500"
                    }
                }
            }
            
            Spacer()
        }
        .padding()
    }
    
    private var macroSetupView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            VStack(spacing: 12) {
                Text("Track Macros?")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                
                Text("Optional but helpful")
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 16) {
                MacroToggleRow(
                    enabled: $enableProtein,
                    value: $protein,
                    label: "Protein",
                    color: .red,
                    icon: "p.square.fill"
                )
                
                MacroToggleRow(
                    enabled: $enableCarbs,
                    value: $carbs,
                    label: "Carbs",
                    color: .blue,
                    icon: "c.square.fill"
                )
                
                MacroToggleRow(
                    enabled: $enableFat,
                    value: $fat,
                    label: "Fat",
                    color: .yellow,
                    icon: "f.square.fill"
                )
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            
            Spacer()
        }
        .padding()
    }
    
    private var integrationsView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            VStack(spacing: 12) {
                Text("Stay Connected")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                
                Text("Optional features")
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 16) {
                IntegrationToggle(
                    enabled: $useHealthKit,
                    icon: "heart.fill",
                    title: "Sync with Health",
                    description: "Write daily intake to Apple Health",
                    color: .red
                )
                
                IntegrationToggle(
                    enabled: $enableNotifications,
                    icon: "bell.fill",
                    title: "Daily Reminders",
                    description: "Gentle nudges to log your meals",
                    color: .blue
                )
            }
            
            Spacer()
        }
        .padding()
    }
    
    private var navigationButtons: some View {
        HStack(spacing: 16) {
            if currentStep > 0 {
                Button {
                    withAnimation {
                        currentStep -= 1
                    }
                } label: {
                    Text("Back")
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
            
            Button {
                if currentStep < 3 {
                    withAnimation {
                        currentStep += 1
                    }
                } else {
                    completeOnboarding()
                }
            } label: {
                Text(currentStep == 3 ? "Get Started" : "Continue")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
        .padding()
    }
    
    private func completeOnboarding() {
        let goal = Goal(
            calories: Int(calories) ?? 2000,
            protein: enableProtein ? Double(protein) ?? 0 : nil,
            carbs: enableCarbs ? Double(carbs) ?? 0 : nil,
            fat: enableFat ? Double(fat) ?? 0 : nil
        )
        
        modelContext.insert(goal)
        try? modelContext.save()
        
        if enableNotifications {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
        }
        
        // Set the onboarding flag directly in UserDefaults
        UserDefaults.standard.set(true, forKey: "isOnboardingComplete")
        
        HapticManager.notification(.success)
    }
}

struct QuickGoalButton: View {
    let label: String
    let calories: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(label)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                
                Text("\(calories)")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("kcal")
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }
}

struct MacroToggleRow: View {
    @Binding var enabled: Bool
    @Binding var value: String
    let label: String
    let color: Color
    let icon: String
    
    var body: some View {
        HStack {
            Toggle(isOn: $enabled) {
                Label(label, systemImage: icon)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(enabled ? color : .secondary)
            }
            
            if enabled {
                Spacer()
                
                TextField("0", text: $value)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 60)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                
                Text("g")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct IntegrationToggle: View {
    @Binding var enabled: Bool
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        Toggle(isOn: $enabled) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(enabled ? color : .secondary)
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                    
                    Text(description)
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

#Preview {
    OnboardingView()
        .environment(AppState())
        .modelContainer(for: [Goal.self])
}