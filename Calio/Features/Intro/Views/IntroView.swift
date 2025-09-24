import SwiftUI
import UserNotifications

struct IntroView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var currentPage = 0
    @State private var animateElements = false
    @State private var showContent = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: backgroundColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.8), value: currentPage)
            
            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    Button(action: completeIntro) {
                        Text("Skip")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                    }
                }
                .padding(.top, 60)
                .opacity(currentPage < 2 ? 1 : 0)
                
                // Page content
                TabView(selection: $currentPage) {
                    IntroPage1(animateElements: $animateElements)
                        .tag(0)
                    
                    IntroPage2(animateElements: $animateElements)
                        .tag(1)
                    
                    IntroPage3(animateElements: $animateElements, completeIntro: completeIntro)
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentPage)
                
                // Custom page indicator
                HStack(spacing: 8) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(index == currentPage ? Color.white : Color.white.opacity(0.3))
                            .frame(width: index == currentPage ? 28 : 8, height: 8)
                            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: currentPage)
                    }
                }
                .padding(.bottom, 30)
                
                // Next button (not on last page)
                if currentPage < 2 {
                    Button(action: {
                        withAnimation {
                            currentPage += 1
                        }
                    }) {
                        HStack(spacing: 8) {
                            Text("Next")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                            
                            Image(systemName: "arrow.right")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(buttonTextColor)
                        .frame(width: 200, height: 56)
                        .background(
                            Capsule()
                                .fill(Color.white)
                        )
                        .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                    }
                    .padding(.bottom, 50)
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                animateElements = true
                showContent = true
            }
        }
        .onChange(of: currentPage) { _, _ in
            animateElements = false
            withAnimation(.easeOut(duration: 0.5).delay(0.1)) {
                animateElements = true
            }
            
            HapticManager.selection()
        }
    }
    
    private var backgroundColors: [Color] {
        switch currentPage {
        case 0:
            return [Color(hex: "667EEA"), Color(hex: "764BA2")]
        case 1:
            return [Color(hex: "F093FB"), Color(hex: "F5576C")]
        case 2:
            return [Color(hex: "4FACFE"), Color(hex: "00F2FE")]
        default:
            return [Color(hex: "667EEA"), Color(hex: "764BA2")]
        }
    }
    
    private var buttonTextColor: Color {
        switch currentPage {
        case 0:
            return Color(hex: "764BA2")
        case 1:
            return Color(hex: "F5576C")
        case 2:
            return Color(hex: "4FACFE")
        default:
            return .black
        }
    }
    
    private func completeIntro() {
        UserDefaults.standard.set(true, forKey: "hasSeenIntro")
        UserDefaults.standard.set(false, forKey: "isOnboardingComplete")
        HapticManager.notification(.success)
    }
}

struct IntroPage1: View {
    @Binding var animateElements: Bool
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Animated icon
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 200, height: 200)
                    .scaleEffect(animateElements ? 1.0 : 0.5)
                    .opacity(animateElements ? 1 : 0)
                
                Circle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 160, height: 160)
                    .scaleEffect(animateElements ? 1.0 : 0.5)
                    .opacity(animateElements ? 1 : 0)
                    .animation(.easeOut(duration: 0.8).delay(0.1), value: animateElements)
                
                Image(systemName: "bolt.fill")
                    .font(.system(size: 80, weight: .bold))
                    .foregroundColor(.white)
                    .scaleEffect(animateElements ? 1.0 : 0.5)
                    .opacity(animateElements ? 1 : 0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.2), value: animateElements)
            }
            
            VStack(spacing: 20) {
                Text("Lightning Fast")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .opacity(animateElements ? 1 : 0)
                    .offset(y: animateElements ? 0 : 20)
                    .animation(.easeOut(duration: 0.6).delay(0.3), value: animateElements)
                
                Text("Log your meals in just 3 taps.\nNo endless searching, no complicated forms.")
                    .font(.system(size: 18, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .opacity(animateElements ? 1 : 0)
                    .offset(y: animateElements ? 0 : 20)
                    .animation(.easeOut(duration: 0.6).delay(0.4), value: animateElements)
            }
            
            Spacer()
            Spacer()
        }
    }
}

struct IntroPage2: View {
    @Binding var animateElements: Bool
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Animated rings
            ZStack {
                ForEach(0..<3) { index in
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.6), .white.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 20
                        )
                        .frame(
                            width: CGFloat(200 - index * 50),
                            height: CGFloat(200 - index * 50)
                        )
                        .rotationEffect(.degrees(animateElements ? Double(index * 120) : 0))
                        .scaleEffect(animateElements ? 1.0 : 0.5)
                        .opacity(animateElements ? 1 : 0)
                        .animation(
                            .easeOut(duration: 0.8)
                            .delay(Double(index) * 0.1),
                            value: animateElements
                        )
                }
                
                VStack(spacing: 8) {
                    Text("75%")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Daily Goal")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                }
                .scaleEffect(animateElements ? 1.0 : 0.5)
                .opacity(animateElements ? 1 : 0)
                .animation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.3), value: animateElements)
            }
            
            VStack(spacing: 20) {
                Text("Visual Progress")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .opacity(animateElements ? 1 : 0)
                    .offset(y: animateElements ? 0 : 20)
                    .animation(.easeOut(duration: 0.6).delay(0.3), value: animateElements)
                
                Text("Beautiful charts show your progress at a glance.\nStay motivated with clear, visual feedback.")
                    .font(.system(size: 18, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .opacity(animateElements ? 1 : 0)
                    .offset(y: animateElements ? 0 : 20)
                    .animation(.easeOut(duration: 0.6).delay(0.4), value: animateElements)
            }
            
            Spacer()
            Spacer()
        }
    }
}

struct IntroPage3: View {
    @Binding var animateElements: Bool
    let completeIntro: () -> Void
    @State private var notificationStatus = "unknown"
    @State private var showNotificationPrompt = false
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Notification bell animation
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 200, height: 200)
                    .scaleEffect(animateElements ? 1.0 : 0.5)
                    .opacity(animateElements ? 1 : 0)
                
                // Pulsing circles
                ForEach(0..<3) { index in
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 2)
                        .frame(width: CGFloat(100 + index * 40), height: CGFloat(100 + index * 40))
                        .scaleEffect(animateElements ? 1.2 : 0.8)
                        .opacity(animateElements ? 0 : 0.6)
                        .animation(
                            Animation.easeOut(duration: 2)
                                .repeatForever(autoreverses: false)
                                .delay(Double(index) * 0.3),
                            value: animateElements
                        )
                }
                
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 80, weight: .bold))
                    .foregroundColor(.white)
                    .scaleEffect(animateElements ? 1.0 : 0.5)
                    .opacity(animateElements ? 1 : 0)
                    .rotationEffect(.degrees(animateElements ? 0 : -30))
                    .animation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.2), value: animateElements)
            }
            
            VStack(spacing: 20) {
                Text("Stay on Track")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .opacity(animateElements ? 1 : 0)
                    .offset(y: animateElements ? 0 : 20)
                    .animation(.easeOut(duration: 0.6).delay(0.3), value: animateElements)
                
                Text("Get gentle reminders to log your meals.\nWe'll help you build healthy habits.")
                    .font(.system(size: 18, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .opacity(animateElements ? 1 : 0)
                    .offset(y: animateElements ? 0 : 20)
                    .animation(.easeOut(duration: 0.6).delay(0.4), value: animateElements)
            }
            
            Spacer()
            
            // Notification permission button
            VStack(spacing: 16) {
                Button(action: {
                    requestNotificationPermission()
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 20, weight: .semibold))
                        
                        Text("Enable Reminders")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(Color(hex: "4FACFE"))
                    .frame(width: 280, height: 56)
                    .background(
                        Capsule()
                            .fill(Color.white)
                    )
                    .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.8), lineWidth: 2)
                            .scaleEffect(animateElements && showNotificationPrompt ? 1.05 : 1.0)
                            .opacity(animateElements && showNotificationPrompt ? 0 : 1)
                            .animation(
                                Animation.easeInOut(duration: 1.5)
                                    .repeatForever(autoreverses: false),
                                value: showNotificationPrompt
                            )
                    )
                }
                .scaleEffect(animateElements ? 1.0 : 0.8)
                .opacity(animateElements ? 1 : 0)
                .animation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.5), value: animateElements)
                
                Button(action: {
                    completeIntro()
                }) {
                    Text("Maybe Later")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.vertical, 10)
                }
                .opacity(animateElements ? 1 : 0)
                .animation(.easeOut(duration: 0.6).delay(0.6), value: animateElements)
            }
            .padding(.bottom, 50)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                showNotificationPrompt = true
            }
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            DispatchQueue.main.async {
                if granted {
                    HapticManager.notification(.success)
                    notificationStatus = "granted"
                    scheduleDefaultReminders()
                } else {
                    notificationStatus = "denied"
                }
                completeIntro()
            }
        }
    }
    
    private func scheduleDefaultReminders() {
        let center = UNUserNotificationCenter.current()
        
        // Lunch reminder at 12:30
        let lunchContent = UNMutableNotificationContent()
        lunchContent.title = "Time for lunch! 🥗"
        lunchContent.body = "Don't forget to log your meal"
        lunchContent.sound = .default
        
        var lunchDateComponents = DateComponents()
        lunchDateComponents.hour = 12
        lunchDateComponents.minute = 30
        
        let lunchTrigger = UNCalendarNotificationTrigger(dateMatching: lunchDateComponents, repeats: true)
        let lunchRequest = UNNotificationRequest(identifier: "lunch_reminder", content: lunchContent, trigger: lunchTrigger)
        
        // Dinner reminder at 19:00
        let dinnerContent = UNMutableNotificationContent()
        dinnerContent.title = "Dinner time! 🍽"
        dinnerContent.body = "Log your dinner to stay on track"
        dinnerContent.sound = .default
        
        var dinnerDateComponents = DateComponents()
        dinnerDateComponents.hour = 19
        dinnerDateComponents.minute = 0
        
        let dinnerTrigger = UNCalendarNotificationTrigger(dateMatching: dinnerDateComponents, repeats: true)
        let dinnerRequest = UNNotificationRequest(identifier: "dinner_reminder", content: dinnerContent, trigger: dinnerTrigger)
        
        center.add(lunchRequest)
        center.add(dinnerRequest)
    }
}

// Color extension for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    IntroView()
}