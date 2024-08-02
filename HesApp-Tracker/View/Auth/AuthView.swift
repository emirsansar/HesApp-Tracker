//
//  ContentView.swift
//  HesApp-Tracker
//
//  Created by Emir Sansar on 2.08.2024.
//

import SwiftUI
import FirebaseAuth

struct AuthView: View {
        
    @State private var isUserLoggedIn: Bool = Auth.auth().currentUser != nil
        
    var body: some View {
        if isUserLoggedIn {
            AppMainView(isUserLoggedIn: $isUserLoggedIn)
        } else {
            content
        }
    }
    
    var content: some View {
        TabView {
            Login(isUserLoggedIn: $isUserLoggedIn)
                .tabItem() {
                    Image(systemName: "person.text.rectangle")
                    Text("Log In")
                }
            Register(selectedTab: .constant(1))
                .tabItem() {
                    Image(systemName: "pencil.line")
                    Text("Register")
                }
        }
    }
    
}

#Preview {
    AuthView()
}



/*
 
 //
 //  ContentView.swift
 //  HesApp-Tracker
 //
 //  Created by Emir Sansar on 2.08.2024.
 //

 import SwiftUI
 import FirebaseAuth

 struct AuthView: View {
     
     @State var selectedTab = 0
     var user: FirebaseAuth.User? = nil
     
     init () {
         user = Auth.auth().currentUser
     }
     
     var body: some View {
         
         if user != nil {
             AppMainView()
         } else {
             TabView {
                 Login()
                     .tabItem() {
                         Image(systemName: "person.text.rectangle")
                         Text("Log In")
                     }
                 Register(selectedTab: .constant(1))
                     .tabItem() {
                         Image(systemName: "pencil.line")
                         Text("Register")
                     }
             }
         }
         
     }
     
 }

 #Preview {
     AuthView()
 }

*/
