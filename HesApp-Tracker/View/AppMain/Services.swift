//
//  Services.swift
//  HesApp-Tracker
//
//  Created by Emir Sansar on 3.08.2024.
//

import SwiftUI

struct Services: View {
    
    @ObservedObject var serviceVM = ServiceViewModel()
    
    init() {
        prepareNavBarStyle()
    }
    
    var body: some View {
        
        NavigationView {
            VStack {
                servicesList
                    .task {
                        getServices()
                    }
                    .background(GradientBackground())
                    .navigationTitle("Services")
            }
        }
        .padding(.top, -40)
    }

    
    // MARK: - Subviews
    
    private var servicesList: some View {
        List {
            ForEach(Array(serviceVM.services.enumerated()), id: \.element.serviceName) { index, service in
                NavigationLink(destination: ServicePlans(chosenService: service)) {
                    Text(service.serviceName)
                        .font(.system(size: 20, weight: .regular))
                }
                .listRowBackground(index % 2 == 0 ? Color.white : Color(UIColor.systemGray5))
            }
            
        }
        .background(Color.clear)
        .scrollContentBackground(.hidden)
        
    }
    
    
    // MARK: - Functions
    
    private func getServices() {
        serviceVM.getServicesFromFirestore { services, error in
            serviceVM.services = services ?? []
        }
    }
    
    private func prepareNavBarStyle() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor(Color(.mainBlue).opacity(0.90))
        appearance.titleTextAttributes = [
                    .foregroundColor: UIColor.black,
                    .font: UIFont.systemFont(ofSize: 19, weight: .semibold)
                ]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
}

#Preview {
    Services()
}
