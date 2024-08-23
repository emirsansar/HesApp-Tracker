import SwiftUI

struct RegisterView: View {
    
    @State private var email: String = ""
    @State private var name: String = ""
    @State private var surname: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    
    @Binding var authTabBarSelection: Int
    
    @ObservedObject var userAuthVM = AuthenticationViewModel()
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        
        VStack {
            appLogoView
            registerLogoView
            nameFields
            emailField
            passwordField
            confirmPasswordField
            registerButton
            registrationFeedback
            Spacer()
        }
        .padding(.horizontal, 30)
        .background(backgroundView)
        .edgesIgnoringSafeArea(.all)
        
    }
    
    
    // MARK: - Subviews
    
    private var nameFields: some View {
        HStack {
            TextField("Name", text: $name)
                .padding()
                .background()
                .cornerRadius(8)
                .shadow(radius: 5)
                .autocapitalization(.none)
            
            TextField("Surname", text: $surname)
                .padding()
                .background()
                .cornerRadius(8)
                .shadow(radius: 5)
                .autocapitalization(.none)
        }.frame(width: UIScreen.main.bounds.width*0.88)
    }
    
    private var emailField: some View {
        TextField("Email", text: $email)
            .padding()
            .keyboardType(.emailAddress)
            .background()
            .cornerRadius(8)
            .shadow(radius: 5)
            .autocapitalization(.none)
            .frame(width: UIScreen.main.bounds.width*0.88)
    }
    
    private var passwordField: some View {
        SecureField("Password", text: $password)
            .padding()
            .background()
            .cornerRadius(8)
            .shadow(radius: 5)
            .autocapitalization(.none)
            .frame(width: UIScreen.main.bounds.width*0.88)
    }
    
    private var confirmPasswordField: some View {
        SecureField("Confirm Password", text: $confirmPassword)
            .padding()
            .background()
            .cornerRadius(8)
            .shadow(radius: 5)
            .autocapitalization(.none)
            .frame(width: UIScreen.main.bounds.width*0.88)
    }
    
    private var registrationFeedback: some View {
        VStack {
            if let error = userAuthVM.registrationError {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            }
            if userAuthVM.registrationSuccess {
                Text("Registration successful!")
                    .foregroundColor(.green)
                    .padding()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now()+1.5) {
                            self.authTabBarSelection = 1
                        }
                    }
            }
        }
    }
    
    private var registerButton: some View {
        Button(action: register) {
            Text("Register")
                .frame(width: UIScreen.main.bounds.width * 0.80)
                .padding()
                .background(.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .font(.headline)
                .shadow(color: .blue.opacity(0.3), radius: 5)
        }
        .padding(.top, 15)
        .disabled(userAuthVM.isRegistering)
    }
    
    private var appLogoView: some View {
        Image("hesapp")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: UIScreen.main.bounds.height * 0.12)
            .padding(.top, 70)
    }
    
    private var registerLogoView: some View {
        Image("register")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: UIScreen.main.bounds.height * 0.10)
            .padding(.top, 40)
            .padding(.bottom, 15)
            .padding(.leading,15)
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
    
    private func register() {
        if password != confirmPassword {
            userAuthVM.registrationError = "Passwords do not match."
            return
        }
        
        userAuthVM.registerUserToFirebaseAuth(email: email, password: password, name: name, surname: surname) { success in
            if success {
                userAuthVM.registrationSuccess = true
            } else {
                userAuthVM.registrationSuccess = false
            }
        }
    }
    
}


#Preview {
    RegisterView(authTabBarSelection: .constant(2))
}
