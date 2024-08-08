import SwiftUI
import FirebaseAuth

struct AuthView: View {
    
    @State private var isUserLoggedIn: Bool = AuthManager.shared.currentUserEmail != nil
    
    @State var authTabBarSelection: Int = 1
    
    var body: some View {
        if isUserLoggedIn {
            AppMainView(isUserLoggedIn: $isUserLoggedIn)
        } else {
            content
        }
    }
    
    var content: some View {
        
        VStack {
            if authTabBarSelection == 1 {
                Login(isUserLoggedIn: $isUserLoggedIn)
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
