//
//  AuthView.swift
//  HesApp-Tracker
//
//  Created by Emir Sansar on 2.08.2024.
//

import SwiftUI

struct AppMainView: View {
    
    @Binding var isUserLoggedIn: Bool
    
    var body: some View {
        TabView {
            Home(isUserLoggedIn: $isUserLoggedIn)
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
                .tag(0)
            
            Services()
                .tabItem {
                    Image(systemName: "text.badge.plus")
                    Text("Services")
                }
                .tag(1)
            
            UsersSubscriptions()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Subs")
                }
                .tag(2)
        }
    }
}

#Preview {
    AppMainView(isUserLoggedIn: .constant(true))
}
