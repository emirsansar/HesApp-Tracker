//
//  Register.swift
//  HesApp-Tracker
//
//  Created by Emir Sansar on 2.08.2024.
//

import SwiftUI
import FirebaseAuth

struct Register: View {
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isRegistering: Bool = false
    @State private var registrationError: String?
    @State private var registrationSuccess: Bool = false
    @Binding var selectedTab: Int
    

    var body: some View {
        
        VStack {
            titleView
            emailField
            passwordField
            confirmPasswordField
            registrationFeedback
            registerButton
            Spacer()
        }
        .padding()
        
    }
    
    private var titleView: some View {
        Text("Register")
            .font(.largeTitle)
            .padding(.top, 40)
    }
    
    private var emailField: some View {
        TextField("Email", text: $email)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()
            .keyboardType(.emailAddress)
            .autocapitalization(.none)
    }
    
    private var passwordField: some View {
        SecureField("Password", text: $password)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()
    }
    
    private var confirmPasswordField: some View {
        SecureField("Confirm Password", text: $confirmPassword)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()
    }
    
    private var registrationFeedback: some View {
        VStack {
            if let error = registrationError {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            }
            if registrationSuccess {
                Text("Kayıt başarılı!")
                    .foregroundColor(.green)
                    .padding()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            selectedTab = 0
                        }
                    }
                Text("Giriş sayfasına yönlendiriliyorsunuz.")
                    .foregroundColor(.green)
            }
        }
    }
    
    private var registerButton: some View {
        Button(action: register) {
            Text("Register")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
        .padding()
        .disabled(isRegistering)
    }
    
    
    private func register() {
        isRegistering = true
        registrationError = nil
        
        if password != confirmPassword {
            registrationError = "Passwords do not match."
            isRegistering = false
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async {
                if let error = error {
                    registrationError = error.localizedDescription
                    registrationSuccess = false
                } else {
                    registrationSuccess = true
                }
                isRegistering = false
            }
        }
        
    }
    
}

#Preview {
    Register(selectedTab: .constant(1))
}
