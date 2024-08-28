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
            .textFieldStyle()
            .keyboardType(.emailAddress)
    }
    
    private var passwordField: some View {
        SecureField("label_password", text: $password)
            .textFieldStyle()
    }
    
    private var loginFeedback: some View {
        VStack {
            if let error = userAuthVM.loginError {
                Text(error)
                    .errorFeedbackTextStyle()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            userAuthVM.loginError = nil
                        }
                    }
            }
            if userAuthVM.loginSuccess {
                Text("text_login_successful")
                    .successFeedbackTextStyle()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
                            self.appState.updateLoginStatus(isLogged: true)
                        }
                    }
            }
        }
        .frame(width: UIScreen.main.bounds.width*0.80)
        .animation(.easeInOut, value: userAuthVM.loginSuccess || userAuthVM.loginError != nil)
    }
    
    private var loginButton: some View {
        Button(action: login) {
            Text("button_login")
                .frame(width: UIScreen.main.bounds.width * 0.75)
                .buttonStyle()
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
