import SwiftUI
import FirebaseAuth

struct LoginView: View {
    
    @EnvironmentObject var appState: AppState
    
    @State private var email: String = ""
    @State private var password: String = ""
    
    @ObservedObject var userAuthVM = AuthenticationViewModel()
    
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            backgroundView
            
            VStack (){
                appLogoView
                labelLogin
                emailField
                passwordField
                loginButton
                loginFeedback
                Spacer()
            }
        }
    }
    
    
    // MARK: - Subviews
    
    private var emailField: some View {
        TextField("label_email", text: $email)
            .padding()
            .background()
            .cornerRadius(8)
            .shadow(radius: 5)
            .keyboardType(.emailAddress)
            .autocapitalization(.none)
            .frame(width: UIScreen.main.bounds.width*0.85)
    }
    
    private var passwordField: some View {
        SecureField("label_password", text: $password)
            .padding()
            .background()
            .cornerRadius(8)
            .shadow(radius: 5)
            .frame(width: UIScreen.main.bounds.width*0.85)
    }
    
    private var loginFeedback: some View {
        VStack {
            if let error = userAuthVM.loginError {
                Text(error)
                    .foregroundColor(.black.opacity(0.9))
                    .padding()
                    .background(Color.red.opacity(0.60))
                    .cornerRadius(8)
                    .padding(.bottom, 10)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            userAuthVM.loginError = nil
                        }
                    }
            }
            if userAuthVM.loginSuccess {
                Text("text_login_successful")
                    .foregroundColor(.black.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.green.opacity(0.60))
                    .cornerRadius(8)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
                            self.appState.updateLoginStatus(isLogged: true)
                        }
                    }
            }
        }
        .frame(width: UIScreen.main.bounds.width*0.75)
        .animation(.easeInOut, value: userAuthVM.loginSuccess || userAuthVM.loginError != nil)
    }
    
    private var loginButton: some View {
        Button(action: login) {
            Text("button_login")
                .frame(width: UIScreen.main.bounds.width * 0.75)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .font(.headline)
                .shadow(color: .blue.opacity(0.3), radius: 5)
        }
        .padding()
        .disabled(userAuthVM.isLoggingIn)
    }
    
    private var appLogoView: some View {
        Image("hesapp")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: UIScreen.main.bounds.height * 0.14)
            .padding(.top, 15)
            .padding(.bottom, 10)
    }
    
    private var labelLogin: some View {
        Text("label_login")
            .font(.system(size: 30, weight: .bold))
            .foregroundStyle(.iconBlue)
            .shadow(color: .white.opacity(0.4), radius: 5)
            .padding()
    }
    
    private var backgroundView: some View {
        Group {
            if colorScheme == .dark {
                GradientBGforDarkTheme()
            } else {
                GradientBackground()
            }
        }
    }
    
    // MARK: - Functions
    
    private func login() {
        userAuthVM.loginUser(email: email, password: password) { success in
            if success {
                userAuthVM.loginSuccess = true
            } else {
                userAuthVM.loginSuccess = false
            }
        }
    }
    
}


#Preview {
    LoginView()
}
