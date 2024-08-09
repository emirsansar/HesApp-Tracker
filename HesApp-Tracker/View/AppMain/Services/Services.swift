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
                List {
                    AddNewServiceSection()
                    
                    AvailableServicesSection(services: $serviceVM.services)
                }
                .task {
                    getServices()
                }
                .background(GradientBackground())
                .listStyle(InsetGroupedListStyle())
                .navigationTitle("Services")
            }
        }
        .padding(.top, -40)
        
    }


    // MARK: - Functions
    
    private func getServices() {
        serviceVM.fetchServicesFromFirestore { services, error in
            DispatchQueue.main.async {
                serviceVM.services = services ?? []
            }
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


    // MARK: - Structs for Subviews

/// Subview to navigate CustomService to create a service
struct AddNewServiceSection: View {
    var body: some View {
        Section(header: Text("Add New Service")) {
            NavigationLink(destination: CustomService()) {
                Text("Custom Service")
                    .font(.system(size: 20, weight: .regular))
            }
        }
    }
}

/// Subview for the 'Available Services' section
struct AvailableServicesSection: View {
    @Binding var services: [Service]
    
    var body: some View {
        Section(header: Text("Available Services")) {
            ForEach(Array(services.enumerated()), id: \.element.id) { index, service in
                NavigationLink(destination: ServicePlans(chosenService: service)) {
                    Text(service.serviceName)
                        .font(.system(size: 20, weight: .regular))
                }
                .listRowBackground(index % 2 == 0 ? Color.white : Color(UIColor.systemGray5))
            }
        }
    }
}


#Preview {
    Services()
}
