//
//  Login.swift
//  HesApp-Tracker
//
//  Created by Emir Sansar on 2.08.2024.
//

import SwiftUI
import FirebaseAuth

struct Login: View {
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoggingIn: Bool = false
    @State private var loginError: String?
    @State private var loginSuccess: Bool = false
    @Binding var isUserLoggedIn: Bool

    var body: some View {
        
        VStack {
            titleView
            emailField
            passwordField
            loginFeedback
            loginButton
            Spacer()
        }
        .padding()
        
    }
    
    private var titleView: some View {
        Text("Login")
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
    
    private var loginFeedback: some View {
        VStack {
            if let error = loginError {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            }
            if loginSuccess {
                Text("Giriş başarılı!")
                    .foregroundColor(.green)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            isUserLoggedIn = true
                        }
                    }
                Text("Uygulamaya yönlendiriliyorsunuz.")
                    .foregroundColor(.green)
            }
        }
    }
    
    private var loginButton: some View {
        Button(action: login) {
            Text("Login")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
        .padding()
        .disabled(isLoggingIn)
    }
    
    
    
    private func login() {
        isLoggingIn = true
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if error != nil {
                loginError = error?.localizedDescription
                isLoggingIn = false
                return
            } else {
                loginSuccess = true
            }
            isLoggingIn = false
        }
        
    }
    
}

#Preview {
    Login(isUserLoggedIn: .constant(false))
}
