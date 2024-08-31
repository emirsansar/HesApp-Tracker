import SwiftUI

struct RegisterView: View {
    
    @State private var email: String = ""
    @State private var name: String = ""
    @State private var surname: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    
    @Binding var authTabBarSelection: Int
    
    @ObservedObject var authVM = AuthenticationViewModel()
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ZStack {
            backgroundView
            
            VStack {
               appLogoView
               labelCreateAccount
               registerForm
               registerButton
               registrationFeedback
               Spacer()
           }
        }
    }
    
    
    // MARK: - Subviews
    
    private var registerForm: some View {
        VStack {
            nameFields
            emailField
            passwordField
            confirmPasswordField
        }
    }
    
    private var nameFields: some View {
        HStack {
            TextField("label_name", text: $name)
                .smallTextFieldStyle()
                .autocapitalization(.none)
            
            TextField("label_surname", text: $surname)
                .smallTextFieldStyle()
        }.frame(width: UIScreen.main.bounds.width*0.85)
    }
    
    private var emailField: some View {
        TextField("label_email", text: $email)
            .textFieldStyle()
            .keyboardType(.emailAddress)
    }
    
    private var passwordField: some View {
        SecureField("label_password", text: $password)
            .textFieldStyle()
    }
    
    private var confirmPasswordField: some View {
        SecureField("label_confirm_password", text: $confirmPassword)
            .textFieldStyle()
    }
    
    private var registrationFeedback: some View {
        VStack {
            if authVM.registerState == .failure && authVM.registrationError != nil {
                Text(authVM.registrationError!)
                    .errorFeedbackTextStyle()
                    .padding()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now()+1.5) {
                            authVM.registrationError = nil
                        }
                    }
            }
            
            if authVM.registerState == .success {
                Text("text_registeration_succesful")
                    .successFeedbackTextStyle()
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
            Text("button_register")
                .frame(width: UIScreen.main.bounds.width * 0.75)
                .buttonStyle()
        }
        .padding(.top, 15)
        .padding(.bottom, 15)
        .disabled(authVM.registerState == .registering)
    }
    
    private var appLogoView: some View {
        Image("hesapp")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: UIScreen.main.bounds.height * 0.14)
            .padding(.top, 15)
            .padding(.bottom, 10)
    }
    
    private var labelCreateAccount: some View {
        Text("label_create_account")
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
    
    private func register() {
        if password != confirmPassword {
            authVM.registrationError = appState.localizedString(for: "error_password_doesnot_match")
            return
        }
        
        authVM.registerUserToFirebaseAuth(email: email, password: password, name: name, surname: surname)
    }
    
}


#Preview {
    RegisterView(authTabBarSelection: .constant(2))
}
