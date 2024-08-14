import SwiftUI
import SwiftData

struct Services: View {
    
    @State private var serviceList: [Service] = [Service]()
    
    @ObservedObject var serviceVM = ServiceViewModel()
    
    @EnvironmentObject var appState: AppState
    @Environment(\.modelContext) var context

    @Query(sort: \Service.serviceName, order: .forward) private var servicesFromSWData: [Service]
    
    init() {
        prepareNavBarStyle()
    }
    
    var body: some View {
        
        NavigationView {
            VStack {
                List {
                    AddNewServiceSection()
                    
                    AvailableServicesSection(services: $serviceList)
                }
                .background(GradientBackground())
                .listStyle(InsetGroupedListStyle())
                .navigationTitle("Services")
            }
        }
        .onAppear(perform: loadServices)
        .padding(.top, -40)
        
    }

    // MARK: - Functions
    
    /// Loads services from Firestore if they haven't been loaded yet and updates SwiftData with any new services. 
    /// If services have already been loaded, it simply retrieves them from SwiftData.
    private func loadServices() {
        if !appState.areServicesLoaded {
            serviceVM.fetchServicesFromFirestore { fetchedServices, error in
                DispatchQueue.main.async {
                    guard let fetchedServices = fetchedServices else {
                        print("Error fetching services: \(error?.localizedDescription ?? "Unknown error")")
                        return
                    }
                    
                    processAddingServicesToSwiftData(fetchedServices: fetchedServices)
                    
                    self.serviceList = fetchedServices
                    appState.areServicesLoaded = true
                }
            }
        } else {
            DispatchQueue.main.async {
                self.serviceList = servicesFromSWData
            }
        }
    }
    
    /// Processes and adds new services to SwiftData.
    private func processAddingServicesToSwiftData (fetchedServices: [Service]) {
        let existingServiceNames = Set(servicesFromSWData.map { $0.serviceName })
        let newServices = fetchedServices.filter { !existingServiceNames.contains($0.serviceName) }
        
        if !newServices.isEmpty {
            serviceVM.saveServicesToSwiftData(services: newServices, context: context)
        }
    }
    
    /// Configures the navigation bar appearance.
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
