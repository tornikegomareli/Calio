import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(AppState.self) private var appState
    @State private var isOnboardingComplete = UserDefaults.standard.bool(forKey: "isOnboardingComplete")
    
    var body: some View {
        if !isOnboardingComplete {
            OnboardingView()
                .transition(.opacity)
                .onReceive(NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)) { _ in
                    isOnboardingComplete = UserDefaults.standard.bool(forKey: "isOnboardingComplete")
                }
        } else {
            @Bindable var appState = appState
            TabView(selection: $appState.selectedTab) {
                TodayView()
                    .tabItem {
                        Label("Today", systemImage: "sun.max.fill")
                    }
                    .tag(AppState.Tab.today)
                
                WeeklyView()
                    .tabItem {
                        Label("Weekly", systemImage: "calendar")
                    }
                    .tag(AppState.Tab.weekly)
                
                PresetsView()
                    .tabItem {
                        Label("Presets", systemImage: "star.fill")
                    }
                    .tag(AppState.Tab.presets)
                
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
                    .tag(AppState.Tab.settings)
            }
            .tint(.accentColor)
        }
    }
}

#Preview {
    ContentView()
        .environment(AppState())
        .modelContainer(for: [Goal.self, DailyLog.self, FoodEntry.self, Preset.self])
}
