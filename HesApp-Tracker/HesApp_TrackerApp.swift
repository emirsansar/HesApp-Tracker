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
    
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if appState.isUserLoggedIn {
                    AppMainView()
                        .transition(.move(edge: .trailing))
                        .environment(\.colorScheme, isDarkMode ? .dark : .light)
                } else {
                    AuthView()
                        .transition(.move(edge: .leading))
                        .environment(\.colorScheme, isDarkMode ? .dark : .light)
                }
            }
            .onAppear {
                applyTheme()
            }
            .animation(.easeInOut(duration: 0.5), value: appState.isUserLoggedIn)
        }
        .environmentObject(appState)
        .modelContainer(for: [Service.self, User.self, UserSubscription.self])
    }
    
    
    private func applyTheme() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if let window = windowScene.windows.first {
                window.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
            }
        }
    }
    
}
