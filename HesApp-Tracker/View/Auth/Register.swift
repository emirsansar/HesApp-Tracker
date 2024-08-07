//
//  Register.swift
//  HesApp-Tracker
//
//  Created by Emir Sansar on 2.08.2024.
//

import SwiftUI

struct Register: View {
    
    @Binding var selectedTab: Int
    
    @State private var email: String = ""
    @State private var name: String = ""
    @State private var surname: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    
    @ObservedObject var userAuthVM = UserAuthAndDetailsViewModel()
    
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
        .background(GradientBackground())
        .edgesIgnoringSafeArea(.all)
        
    }
    
    
    // MARK: - Subviews
    
    private var nameFields: some View {
        HStack {
            TextField("Name", text: $name)
                .padding()
                .background(Color.white)
                .cornerRadius(8)
                .shadow(radius: 5)
                .autocapitalization(.none)
            
            TextField("Surname", text: $surname)
                .padding()
                .background(Color.white)
                .cornerRadius(8)
                .shadow(radius: 5)
                .autocapitalization(.none)
        }.frame(width: UIScreen.main.bounds.width*0.88)
    }
    
    private var emailField: some View {
        TextField("Email", text: $email)
            .padding()
            .keyboardType(.emailAddress)
            .background(Color.white)
            .cornerRadius(8)
            .shadow(radius: 5)
            .autocapitalization(.none)
            .frame(width: UIScreen.main.bounds.width*0.88)
    }
    
    private var passwordField: some View {
        SecureField("Password", text: $password)
            .padding()
            .background(Color.white)
            .cornerRadius(8)
            .shadow(radius: 5)
            .autocapitalization(.none)
            .frame(width: UIScreen.main.bounds.width*0.88)
    }
    
    private var confirmPasswordField: some View {
        SecureField("Confirm Password", text: $confirmPassword)
            .padding()
            .background(Color.white)
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
                .frame(width: UIScreen.main.bounds.width * 0.80)
                .padding()
                .background(Color.blue)
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
            .shadow(radius: 10)
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
    Register(selectedTab: .constant(1))
}
