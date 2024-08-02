//
//  Home.swift
//  HesApp-Tracker
//
//  Created by Emir Sansar on 2.08.2024.
//

import SwiftUI
import FirebaseAuth

struct Home: View {
    
    @Binding var isUserLoggedIn: Bool
    
    var body: some View {
        
        VStack (){
            appLogo
            greeting
            userInfos
            logOutButton
        }
        .padding()
        .frame(maxHeight: .infinity, alignment: .top)
        
    }
    
    private var appLogo: some View {
        Image("hesapp")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: UIScreen.main.bounds.height * 0.10)
            .padding(.top, 20)
    }
    
    private var greeting: some View {
        VStack{
            HStack {
                Image(systemName: "hand.wave")
                    .resizable()
                    .frame(width: 25, height: 25)
                Text("Welcome,")
                    .font(.title)
            }
            Text(Auth.auth().currentUser?.email ?? "email")
                .font(/*@START_MENU_TOKEN@*/.body/*@END_MENU_TOKEN@*/)
                .padding(.bottom, 20)
        }
    }
    
    private var userInfos: some View {
        VStack(alignment: .leading) {
            userSubsCount
            userMonthlySpend
            userAnnualySpend
        }
        .frame(width: UIScreen.main.bounds.width*0.55)
    }
    
    private var userSubsCount: some View {
        infoRow(label: "Total sub count:", value: "0")
    }
    
    private var userMonthlySpend: some View {
        infoRow(label: "Monthly spending:", value: "00")
    }
    
    private var userAnnualySpend: some View {
        infoRow(label: "Annualy spend:", value: "0000")
    }
    
    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .frame(alignment: .leading)
            Spacer()
            Text(value)
                .frame(alignment: .trailing)
        }
    }
    
    private var logOutButton: some View {
        Button(action: logOut) {
            Text("Log Out")
                .frame(maxWidth: UIScreen.main.bounds.width*0.3 )
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
        .padding()
    }
    
    private func logOut() {
        do {
            try Auth.auth().signOut()
            isUserLoggedIn = false
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
}

#Preview {
    Home(isUserLoggedIn: .constant(true))
}
