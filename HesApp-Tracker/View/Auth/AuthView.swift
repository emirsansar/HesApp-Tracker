import SwiftUI

struct AuthView: View {
    
    @EnvironmentObject var appState: AppState

    @State private var authTabBarSelection: Int = 1
    
    var body: some View {
        ZStack {
            if appState.isUserLoggedIn {
                AppMainView()
                    .transition(.move(edge: .trailing))
            } else {
                content
                    .transition(.move(edge: .leading))
            }
        }
        .animation(.easeInOut, value: appState.isUserLoggedIn)
    }
    
    var content: some View {
        VStack {
            if authTabBarSelection == 1 {
                Login()
            } else {
                Register()
            }
            
            AuthTabView(authTabBarSelection: $authTabBarSelection)
                .foregroundColor(Color(.systemGray4).opacity(0.7))
                .padding(.top, -10)
        }
        .edgesIgnoringSafeArea(.bottom)
    }
    
}


#Preview {
    AuthView()
}
