import SwiftUI
import SwiftData

@main
struct CalioApp: App {
  @State private var appState = AppState()
  
  var sharedModelContainer: ModelContainer = {
    let schema = Schema([
      Goal.self,
      FoodEntry.self,
      Preset.self,
      DailyLog.self
    ])
    let modelConfiguration = ModelConfiguration(
      schema: schema,
      isStoredInMemoryOnly: false,
      cloudKitDatabase: .automatic
    )
    
    do {
      return try ModelContainer(for: schema, configurations: [modelConfiguration])
    } catch {
      fatalError("Could not create ModelContainer: \(error)")
    }
  }()
  
  var body: some Scene {
    WindowGroup {
      ContentView()
        .environment(appState)
    }
    .modelContainer(sharedModelContainer)
  }
}

@MainActor
@Observable
final class AppState {
  var selectedTab: Tab = .today
  var isOnboardingComplete: Bool {
    get {
      UserDefaults.standard.bool(forKey: "isOnboardingComplete")
    }
    set {
      UserDefaults.standard.set(newValue, forKey: "isOnboardingComplete")
    }
  }
  
  enum Tab {
    case today
    case weekly
    case presets
    case settings
  }
}
