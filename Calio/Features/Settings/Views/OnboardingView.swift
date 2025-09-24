import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var currentStep = 0
    @State private var animateElements = false
    
    // User inputs
    @State private var userName = ""
    @State private var caloriesGoal = 2000
    @State private var selectedGoalType: GoalType = .maintain
    @State private var enableMacros = false
    @State private var proteinGoal = 150
    @State private var carbsGoal = 250
    @State private var fatGoal = 65
    
    // Animations
    @State private var showEmoji = false
    @State private var bounceValue: CGFloat = 1.0
    @State private var rotationAngle: Double = 0
    
    enum GoalType: String, CaseIterable {
        case lose = "Lose Weight"
        case maintain = "Stay Healthy"
        case gain = "Build Muscle"
        
        var emoji: String {
            switch self {
            case .lose: return "🎯"
            case .maintain: return "⚡"
            case .gain: return "💪"
            }
        }
        
        var suggestedCalories: Int {
            switch self {
            case .lose: return 1800
            case .maintain: return 2000
            case .gain: return 2500
            }
        }
        
        var color: Color {
            switch self {
            case .lose: return Color(hex: "FF6B6B")
            case .maintain: return Color(hex: "4ECDC4")
            case .gain: return Color(hex: "95E1D3")
            }
        }
    }
    
    var body: some View {
        ZStack {
            // Animated background
            backgroundGradient
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 1.0), value: currentStep)
            
            VStack {
                // Progress dots
                HStack(spacing: 6) {
                    ForEach(0..<4) { index in
                        Circle()
                            .fill(index <= currentStep ? Color.white : Color.white.opacity(0.3))
                            .frame(width: index == currentStep ? 24 : 6, height: 6)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentStep)
                    }
                }
                .padding(.top, 60)
                .padding(.bottom, 40)
                
                // Content
                ZStack {
                    // Step views
                    Group {
                        if currentStep == 0 {
                            nameStepView
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .leading).combined(with: .opacity)
                                ))
                        } else if currentStep == 1 {
                            goalTypeStepView
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .leading).combined(with: .opacity)
                                ))
                        } else if currentStep == 2 {
                            caloriesStepView
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .leading).combined(with: .opacity)
                                ))
                        } else if currentStep == 3 {
                            macrosStepView
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .leading).combined(with: .opacity)
                                ))
                        }
                    }
                }
                .frame(maxHeight: .infinity)
                
                // Bottom action
                bottomActionButton
                    .padding(.horizontal, 30)
                    .padding(.bottom, 50)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
                animateElements = true
                showEmoji = true
            }
        }
        .onChange(of: currentStep) { _, _ in
            animateElements = false
            withAnimation(.easeOut(duration: 0.5).delay(0.1)) {
                animateElements = true
            }
            HapticManager.selection()
        }
    }
    
    private var backgroundGradient: LinearGradient {
        let colors: [Color] = {
            switch currentStep {
            case 0:
                return [Color(hex: "667EEA"), Color(hex: "764BA2")]
            case 1:
                return [Color(hex: "FA709A"), Color(hex: "FEE140")]
            case 2:
                return [Color(hex: "30CED7"), Color(hex: "3D94F6")]
            case 3:
                return [Color(hex: "F093FB"), Color(hex: "F5576C")]
            default:
                return [Color(hex: "667EEA"), Color(hex: "764BA2")]
            }
        }()
        
        return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    
    // MARK: - Step 1: Name
    private var nameStepView: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Animated emoji
            Text("👋")
                .font(.system(size: 100))
                .rotationEffect(.degrees(showEmoji ? 0 : -30))
                .scaleEffect(showEmoji ? 1.0 : 0.5)
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showEmoji)
            
            VStack(spacing: 24) {
                Text("What's your name?")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .opacity(animateElements ? 1 : 0)
                    .offset(y: animateElements ? 0 : 20)
                    .animation(.easeOut(duration: 0.6), value: animateElements)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 60)
                    
                    TextField("", text: $userName)
                        .placeholder(when: userName.isEmpty) {
                            Text("Enter your name")
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                .frame(width: 280)
                .opacity(animateElements ? 1 : 0)
                .scaleEffect(animateElements ? 1 : 0.9)
                .animation(.easeOut(duration: 0.6).delay(0.1), value: animateElements)
            }
            
            Spacer()
            Spacer()
        }
    }
    
    // MARK: - Step 2: Goal Type
    private var goalTypeStepView: some View {
        VStack(spacing: 40) {
            Spacer()
            
            VStack(spacing: 20) {
                Text("Hey \(userName.isEmpty ? "there" : userName)! 🎉")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .opacity(animateElements ? 1 : 0)
                    .offset(y: animateElements ? 0 : 20)
                    .animation(.easeOut(duration: 0.6), value: animateElements)
                
                Text("What's your goal?")
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                    .opacity(animateElements ? 1 : 0)
                    .offset(y: animateElements ? 0 : 20)
                    .animation(.easeOut(duration: 0.6).delay(0.1), value: animateElements)
            }
            
            VStack(spacing: 16) {
                ForEach(Array(GoalType.allCases.enumerated()), id: \.offset) { index, goal in
                    GoalTypeCard(
                        goalType: goal,
                        isSelected: selectedGoalType == goal,
                        action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedGoalType = goal
                                caloriesGoal = goal.suggestedCalories
                            }
                            HapticManager.impact(.light)
                        }
                    )
                    .opacity(animateElements ? 1 : 0)
                    .scaleEffect(animateElements ? 1 : 0.8)
                    .animation(
                        .spring(response: 0.4, dampingFraction: 0.7)
                        .delay(Double(index) * 0.1),
                        value: animateElements
                    )
                }
            }
            .padding(.horizontal, 30)
            
            Spacer()
            Spacer()
        }
    }
    
    // MARK: - Step 3: Calories
    private var caloriesStepView: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Animated fire emoji
            Text("🔥")
                .font(.system(size: 80))
                .rotationEffect(.degrees(rotationAngle))
                .scaleEffect(bounceValue)
                .onAppear {
                    withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                        rotationAngle = 360
                    }
                    withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                        bounceValue = 1.2
                    }
                }
            
            VStack(spacing: 24) {
                Text("Daily Calorie Goal")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .opacity(animateElements ? 1 : 0)
                    .offset(y: animateElements ? 0 : 20)
                    .animation(.easeOut(duration: 0.6), value: animateElements)
                
                // Calorie display
                VStack(spacing: 16) {
                    Text("\(caloriesGoal)")
                        .font(.system(size: 72, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .contentTransition(.numericText())
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: caloriesGoal)
                    
                    Text("kcal / day")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                }
                .opacity(animateElements ? 1 : 0)
                .scaleEffect(animateElements ? 1 : 0.8)
                .animation(.easeOut(duration: 0.6).delay(0.1), value: animateElements)
                
                // Slider
                VStack(spacing: 8) {
                    Slider(value: Binding(
                        get: { Double(caloriesGoal) },
                        set: { caloriesGoal = Int($0) }
                    ), in: 1200...4000, step: 50)
                    .accentColor(.white)
                    .padding(.horizontal, 40)
                    
                    HStack {
                        Text("1200")
                        Spacer()
                        Text("4000")
                    }
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.horizontal, 40)
                }
                .opacity(animateElements ? 1 : 0)
                .animation(.easeOut(duration: 0.6).delay(0.2), value: animateElements)
            }
            
            Spacer()
            Spacer()
        }
    }
    
    // MARK: - Step 4: Macros
    private var macrosStepView: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Animated emoji
            Text("🎯")
                .font(.system(size: 80))
                .scaleEffect(showEmoji ? 1.0 : 0.5)
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showEmoji)
            
            VStack(spacing: 24) {
                Text("Track Macros?")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .opacity(animateElements ? 1 : 0)
                    .offset(y: animateElements ? 0 : 20)
                    .animation(.easeOut(duration: 0.6), value: animateElements)
                
                Text("Optional but helpful for balanced nutrition")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                    .opacity(animateElements ? 1 : 0)
                    .offset(y: animateElements ? 0 : 20)
                    .animation(.easeOut(duration: 0.6).delay(0.1), value: animateElements)
                
                // Toggle card
                MacroToggleCard(
                    isEnabled: $enableMacros,
                    proteinGoal: $proteinGoal,
                    carbsGoal: $carbsGoal,
                    fatGoal: $fatGoal
                )
                .opacity(animateElements ? 1 : 0)
                .scaleEffect(animateElements ? 1 : 0.9)
                .animation(.easeOut(duration: 0.6).delay(0.2), value: animateElements)
            }
            
            Spacer()
            Spacer()
        }
    }
    
    // MARK: - Bottom Button
    private var bottomActionButton: some View {
        Button(action: {
            if currentStep < 3 {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    currentStep += 1
                }
            } else {
                completeOnboarding()
            }
        }) {
            Text(currentStep == 3 ? "Let's Go! 🚀" : "Continue")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(buttonTextColor)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(
                    Capsule()
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                )
        }
        .disabled(currentStep == 0 && userName.isEmpty)
        .opacity((currentStep == 0 && userName.isEmpty) ? 0.6 : 1.0)
        .scaleEffect(animateElements ? 1 : 0.9)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: animateElements)
    }
    
    private var buttonTextColor: Color {
        switch currentStep {
        case 0: return Color(hex: "764BA2")
        case 1: return Color(hex: "FA709A")
        case 2: return Color(hex: "3D94F6")
        case 3: return Color(hex: "F5576C")
        default: return .black
        }
    }
    
    private func completeOnboarding() {
        let goal = Goal(
            calories: caloriesGoal,
            protein: enableMacros ? Double(proteinGoal) : nil,
            carbs: enableMacros ? Double(carbsGoal) : nil,
            fat: enableMacros ? Double(fatGoal) : nil
        )
        
        modelContext.insert(goal)
        try? modelContext.save()
        
        UserDefaults.standard.set(userName, forKey: "userName")
        UserDefaults.standard.set(true, forKey: "isOnboardingComplete")
        
        HapticManager.notification(.success)
    }
}

// MARK: - Supporting Views

struct GoalTypeCard: View {
    let goalType: OnboardingView.GoalType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 20) {
                Text(goalType.emoji)
                    .font(.system(size: 40))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(goalType.rawValue)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(isSelected ? .white : .white.opacity(0.9))
                    
                    Text("\(goalType.suggestedCalories) kcal/day")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(isSelected ? .white.opacity(0.9) : .white.opacity(0.7))
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? Color.white.opacity(0.3) : Color.white.opacity(0.15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(isSelected ? Color.white.opacity(0.5) : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

struct MacroToggleCard: View {
    @Binding var isEnabled: Bool
    @Binding var proteinGoal: Int
    @Binding var carbsGoal: Int
    @Binding var fatGoal: Int
    
    var body: some View {
        VStack(spacing: 20) {
            // Toggle
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isEnabled.toggle()
                }
                HapticManager.impact(.light)
            }) {
                HStack {
                    Text("Enable Macro Tracking")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    ZStack {
                        Capsule()
                            .fill(isEnabled ? Color.white.opacity(0.3) : Color.white.opacity(0.15))
                            .frame(width: 60, height: 32)
                        
                        Circle()
                            .fill(Color.white)
                            .frame(width: 28, height: 28)
                            .offset(x: isEnabled ? 14 : -14)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isEnabled)
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.2))
                )
            }
            .buttonStyle(.plain)
            
            // Macro inputs (shown when enabled)
            if isEnabled {
                VStack(spacing: 16) {
                    MacroInputRow(value: $proteinGoal, label: "Protein", color: .red, suffix: "g")
                    MacroInputRow(value: $carbsGoal, label: "Carbs", color: .blue, suffix: "g")
                    MacroInputRow(value: $fatGoal, label: "Fat", color: .yellow, suffix: "g")
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.15))
                )
                .transition(.asymmetric(
                    insertion: .scale.combined(with: .opacity),
                    removal: .scale.combined(with: .opacity)
                ))
            }
        }
        .padding(.horizontal, 30)
    }
}

struct MacroInputRow: View {
    @Binding var value: Int
    let label: String
    let color: Color
    let suffix: String
    
    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            
            Text(label)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.white)
            
            Spacer()
            
            HStack(spacing: 8) {
                Button(action: {
                    if value > 0 {
                        value -= 5
                        HapticManager.impact(.light)
                    }
                }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Text("\(value)")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(minWidth: 40)
                    .contentTransition(.numericText())
                    .animation(.spring(response: 0.2, dampingFraction: 0.8), value: value)
                
                Text(suffix)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                
                Button(action: {
                    value += 5
                    HapticManager.impact(.light)
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
    }
}

// Extension for placeholder
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

#Preview {
    OnboardingView()
        .modelContainer(for: [Goal.self])
}