import SwiftUI
//import FirebaseAuth

struct AuthView: View {
    
    @State var isUserLoggedIn: Bool = AuthManager.shared.auth.currentUser != nil
    @State private var authTabBarSelection: Int = 1
    
    var body: some View {
        ZStack {
            if isUserLoggedIn {
                AppMainView(isUserLoggedIn: $isUserLoggedIn)
                    .transition(.move(edge: .trailing)) // Görünüm geçiş efekti
            } else {
                content
                    .transition(.move(edge: .leading)) // Görünüm geçiş efekti
            }
        }
        .animation(.easeInOut, value: isUserLoggedIn)
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
