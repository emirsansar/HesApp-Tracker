import SwiftUI
import FirebaseAuth

struct Login: View {
    
    @Binding var isUserLoggedIn: Bool
    
    @State private var email: String = ""
    @State private var password: String = ""
    
    @ObservedObject var userAuthVM = UserAuthAndDetailsViewModel()

    var body: some View {
        
        VStack (){
            appLogoView
            loginLogoView
            emailField
            passwordField
            loginButton
            loginFeedback
            Spacer()
        }
        .padding(.horizontal)
        .background(GradientBackground())
        .edgesIgnoringSafeArea(.all)
        
    }
    
    
    // MARK: - Subviews
    
    private var emailField: some View {
        TextField("Email", text: $email)
            .padding()
            .background(Color.white)
            .cornerRadius(8)
            .shadow(radius: 5)
            .keyboardType(.emailAddress)
            .autocapitalization(.none)
            .frame(width: UIScreen.main.bounds.width*0.88)
    }
    
    private var passwordField: some View {
        SecureField("Password", text: $password)
            .padding()
            .background(Color.white)
            .cornerRadius(8)
            .shadow(radius: 5)
            .frame(width: UIScreen.main.bounds.width*0.88)
    }
    
    private var loginFeedback: some View {
        VStack {
            if let error = userAuthVM.loginError {
                Text(error)
                    .foregroundColor(.black.opacity(0.85))
                    .padding()
                    .background(Color.red.opacity(0.20))
                    .cornerRadius(8)
                    .padding(.bottom, 10)
            }
            if userAuthVM.loginSuccess {
                Text("Login successful!\nYou are being redirected to the app.")
                    .foregroundColor(.black.opacity(0.85))
                    .padding()
                    .background(Color.green.opacity(0.20))
                    .cornerRadius(8)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            isUserLoggedIn = true
                        }
                    }
            }
        }
    }
    
    private var loginButton: some View {
        Button(action: login) {
            Text("Login")
                .frame(width: UIScreen.main.bounds.width * 0.80)
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
            .frame(height: UIScreen.main.bounds.height * 0.12)
            .padding(.top, 70)
            .shadow(radius: 10)
    }
    
    private var loginLogoView: some View {
        Image("login")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: UIScreen.main.bounds.height * 0.10)
            .padding(.top, 40)
            .padding(.bottom, 20)
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
    Login(isUserLoggedIn: .constant(false))
}
