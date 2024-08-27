import Foundation
import UIKit

class AppState: ObservableObject {
    
    /// When the app is first opened, it's set to false to fetch services from Firestore. Later, it becomes true and services are fetched from SwiftData.
    /// The purpose is to add new services to SwiftData if there are any when the app starts.
    @Published var areServicesLoaded = false
    
    /// This property checks whether the user's name and subscription summary have been fetched from Firestore.
    @Published var isFetchedUserDetails = false
    
    /// This property ensures that the user's summary is refetched when the user adds, removes, or updates a subscription.
    @Published var isUserChangedSubsList = false
    
    /// This property checks whether the user's subscriptions have been fetched from Firestore.
    @Published var isFetchedUserSubscriptions = false
    
    /// Used to show the login screen depending on whether the user is logged in or not.
    @Published var isUserLoggedIn: Bool {
        didSet {
            UserDefaults.standard.set(isUserLoggedIn, forKey: "isUserLoggedIn")
        }
    }
    
    /// This property controls whether the app is in dark mode or light mode. The preference is stored in UserDefaults.
    @Published var isDarkMode: Bool {
        didSet {
            UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
            self.applyTheme()
        }
    }
    
    /// This property stores the selected language of the app and persists it in UserDefaults.
    @Published var selectedLanguage: String {
        didSet {
            UserDefaults.standard.set(selectedLanguage, forKey: "selectedLanguage")
            loadBundle(for: selectedLanguage)
        }
    }
    
    /// The bundle used to load localized strings based on the selected language.
    private var bundle: Bundle?
    
    
    init() {
        self.isUserLoggedIn = UserDefaults.standard.bool(forKey: "isUserLoggedIn")
        
        let defaultDarkMode: Bool
        defaultDarkMode = UIScreen.main.traitCollection.userInterfaceStyle == .dark
        self.isDarkMode = UserDefaults.standard.object(forKey: "isDarkMode") as? Bool ?? defaultDarkMode
        
        let defaultLanguage: String
        let systemLanguage = Locale.current.language.languageCode?.identifier ?? "tr"
        defaultLanguage = (systemLanguage == "tr" || systemLanguage == "en") ? systemLanguage : "tr"

        self.selectedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage") ?? defaultLanguage
        loadBundle(for: selectedLanguage)
    }
    
    
    func updateLoginStatus(isLogged: Bool) {
        self.isUserLoggedIn = isLogged
    }
    
    /// Applies the selected theme (dark or light mode) to the application window.
    func applyTheme() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if let window = windowScene.windows.first {
                window.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
            }
        }
    }
    
    /// Loads the appropriate language bundle based on the selected language.
    private func loadBundle(for language: String) {
        if let path = Bundle.main.path(forResource: language, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            self.bundle = bundle
        } else {
            self.bundle = Bundle.main
        }
    }
    
    /// Retrieves the localized string for a given key from the currently loaded language bundle.
    func localizedString(for key: String) -> String {
        return bundle?.localizedString(forKey: key, value: nil, table: nil) ?? key
    }
    
}
