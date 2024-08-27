import SwiftUI

struct AppSideMenuView: View {
    
    @Binding var showSideMenu: Bool
    @Binding var showingLogoutAlert: Bool
    
    @Binding var showSelectLanguageSheetView: Bool
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(alignment: .leading) {
            settingsTitle
            dividerView
            toggleDarkModeView
            languageToggleView
            logOutButton
            Spacer()
        }
        .padding()
        .frame(maxWidth: 290)
        .background(Color(.systemGray3))
        .shadow(color: .black.opacity(0.2), radius: 5, x: 5, y: 0)
    }
    
    private var settingsTitle: some View {
        Text("label_settings")
            .font(.system(size: 21, weight: .regular))
            .padding(.top, 10)
            .padding(.horizontal)
    }
    
    private var dividerView: some View {
        Divider()
            .frame(width: 250, height: 2)
            .background(Color(.systemGray))
            .padding(.bottom, 15)
            .padding(.horizontal, 3)
    }
    
    private var logOutButton: some View {
        Button(action: {
            self.showingLogoutAlert = true
            withAnimation {
                showSideMenu.toggle()
            }
        }) {
            HStack {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(.red).opacity(0.9)
                
                Text("label_log_out")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
            }
        }
        .padding(.leading, 11)
    }
    
    private var toggleDarkModeView: some View {
        HStack {
            Image(systemName: appState.isDarkMode ? "moon.fill" : "sun.max.fill")
                .foregroundColor(appState.isDarkMode ? .yellow : .blue)
                .font(.body)
            
            Text(appState.isDarkMode ? "label_dark_mode" : "label_light_mode")
                .font(.system(size: 18, weight: .regular))

            toggleDarkModeButton
        }
        .padding(.vertical)
        .padding(.leading, 10)
    }
    
    private var toggleDarkModeButton: some View {
        Toggle(isOn: $appState.isDarkMode) {}
        .   scaleEffect(0.8)
    }
    
    private var languageToggleView: some View {
        HStack {
            Image(systemName: "globe")
                .foregroundColor(.blue)
                .font(.system(size: 18, weight: .regular))
            
            Button(action: {
                self.showSideMenu = false
                self.showSelectLanguageSheetView = true
            }) {
                Text("label_change_language")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .padding(.leading, 2)
            }
        }
        .padding(.bottom, 20)
        .padding(.leading, 10)
    }
    
    private func toggleLanguage() {
        appState.selectedLanguage = (appState.selectedLanguage == "tr") ? "en" : "tr"
    }
    
}

#Preview {
    AppSideMenuView(showSideMenu: .constant(true), showingLogoutAlert: .constant(false), showSelectLanguageSheetView: .constant(false))
        .environmentObject(AppState())
}
