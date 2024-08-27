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
    
    @ObservedObject var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if appState.isUserLoggedIn {
                    AppMainView()
                        .transition(.move(edge: .trailing))
                        .environment(\.locale, .init(identifier: appState.selectedLanguage))
                } else {
                    AuthView()
                        .transition(.move(edge: .leading))
                        .environment(\.locale, .init(identifier: appState.selectedLanguage))
                }
            }
            .onAppear {
                appState.applyTheme()
            }
            .animation(.easeInOut(duration: 0.5), value: appState.isUserLoggedIn)
        }
        .environmentObject(appState)
        .modelContainer(for: [Service.self, User.self, UserSubscription.self])
    }
    
}
