import SwiftUI

struct AuthView: View {
    
    @EnvironmentObject var appState: AppState

    @State private var authTabBarSelection: Int = 1
    
    var body: some View {
        VStack {
            if authTabBarSelection == 1 {
                LoginView()
            } else {
                RegisterView(authTabBarSelection: $authTabBarSelection)
            }
            
            AuthTabView(authTabBarSelection: $authTabBarSelection)
                .padding(.top, -10)
        }
        .edgesIgnoringSafeArea(.bottom)
    }
    
}


#Preview {
    AuthView()
}
