import SwiftUI
import FirebaseCore
import SwiftData

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct HesApp_TrackerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            AuthView()
                
        }
        .environmentObject(appState)
        .modelContainer(for: [Service.self, User.self, UserSubscription.self])
    }
}
