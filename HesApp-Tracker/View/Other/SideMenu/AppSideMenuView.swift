import SwiftUI

struct AppSideMenuView: View {
    
    @Binding var showSideMenu: Bool
    @Binding var showingLogoutAlert: Bool
    
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    var body: some View {
        
        VStack (alignment: .leading) {
            settingsTitle
            dividerView
            toggleDarkModeView
            logOutButton
            Spacer()
        }
        .padding()
        .frame(maxWidth: 275)
        .background(Color(.systemGray3))
        .shadow(color: .black.opacity(0.2), radius: 5, x: 5, y: 0)
        
    }
    
    private var settingsTitle: some View {
        Text("Settings")
            .font(.system(size: 23, weight: .regular))
            .padding(.top, 10)
            .padding(.horizontal)
    }
    
    private var dividerView: some View {
        Divider()
            .frame(width: 230, height: 2)
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
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(.red).opacity(0.9)
                
                Text("Log Out")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
            }
        }
        .padding(.leading, 20)
    }
    
    private var toggleDarkModeView: some View {
        HStack {
            Image(systemName: isDarkMode ? "moon.fill" : "sun.max.fill")
                .foregroundColor(isDarkMode ? .yellow : .blue)
                .font(.body)
            
            Text(isDarkMode ? "Dark Mode" : "Light Mode")
                .font(.system(size: 18, weight: .regular))

            toggleDarkModeButton
        }
        .padding(.vertical)
        .padding(.leading, 20)
    }
    
    private var toggleDarkModeButton: some View {
        Toggle(isOn: $isDarkMode) {}
        .onChange(of: isDarkMode) {
            applyTheme()
        }
        .scaleEffect(0.8)
    }
    
    
    private func applyTheme() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if let window = windowScene.windows.first {
                window.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
            }
        }
    }
    
}

#Preview {
    AppSideMenuView(showSideMenu: .constant(true), showingLogoutAlert: .constant(false))
}
