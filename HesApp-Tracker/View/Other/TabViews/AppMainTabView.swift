//
//  AppMainTabView.swift
//  HesApp-Tracker
//
//  Created by Emir Sansar on 8.08.2024.
//

import SwiftUI

struct AppMainTabView: View {
    
    @Binding var appMainTabBarSelection: Int
    
    var body: some View {
        
        ZStack{
            TabViewBackground()
            HStack{
                homeButton
                Spacer()
                servicesButton
                Spacer()
                userSubscriptionsButton
            }
        }
        
    }
    
    
    private var homeButton: some View {
        Button(action: {
            appMainTabBarSelection = 1
        }) {
            VStack {
                Image(systemName: "house")
                    .foregroundColor(appMainTabBarSelection == 1 ? .blue : .gray)
                Text("Home")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(appMainTabBarSelection == 1 ? .blue : .gray)

                if appMainTabBarSelection == 1 {
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(.blue)
                        .padding(.top, 2)
                } else {
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(.clear)
                        .padding(.top, 2)
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
    }
    
    private var servicesButton: some View {
        Button(action: {
            appMainTabBarSelection = 2
        }) {
            VStack {
                Image(systemName: "text.badge.plus")
                    .foregroundColor(appMainTabBarSelection == 2 ? .blue : .gray)
                Text("Services")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(appMainTabBarSelection == 2 ? .blue : .gray)

                if appMainTabBarSelection == 2 {
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(.blue)
                        .padding(.top, 2)
                } else {
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(.clear)
                        .padding(.top, 2)
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
    }
    
    private var userSubscriptionsButton: some View {
        Button(action: {
            appMainTabBarSelection = 3
        }) {
            VStack {
                Image(systemName: "list.bullet")
                    .foregroundColor(appMainTabBarSelection == 3 ? .blue : .gray)
                Text("Subscriptions")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(appMainTabBarSelection == 3 ? .blue : .gray)

                if appMainTabBarSelection == 3 {
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(.blue)
                        .padding(.top, 2)
                } else {
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(.clear)
                        .padding(.top, 2)
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
    }
    
}

#Preview {
    AppMainTabView(appMainTabBarSelection: .constant(1))
}
