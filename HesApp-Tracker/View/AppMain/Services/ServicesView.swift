import SwiftUI
import SwiftData

struct ServicesView: View {
    
    @State private var serviceList: [Service] = [Service]() /// Original list of all services.
    @State private var filteredServiceList: [Service] = [Service]() /// List of services after filtering 'servicesList'.
    @State private var filterText: String = ""
    @State private var selectedServiceType: ServiceType = .all
    
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
                    SearchBarSection(filterText: $filterText, filterServiceFunction: filterServices)
                    pickerServiceType
                    AddNewServiceSection()
                    AvailableServicesSection(services: $filteredServiceList)
                }
                .scrollIndicators(.hidden)
                .background(Color.mainBlue)
                .listStyle(InsetGroupedListStyle())
                .navigationTitle("Services")
            }
        }
        .onAppear(perform: loadServices)
        .padding(.top, -40)
        
    }
    
    
    // MARK: - Subviews
    
    private var pickerServiceType: some View {
        Picker("Filter Services by Type", selection: $selectedServiceType) {
            ForEach(ServiceType.allCases) { typeOption in
                Text(typeOption.rawValue)
                    .tag(typeOption)
            }
        }
        .pickerStyle(.menu)
        .onChange(of: selectedServiceType) {
            filterServices()
            print("Selected Type: \(selectedServiceType.rawValue)")
        }
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
                    self.filteredServiceList = fetchedServices
                    appState.areServicesLoaded = true
                }
            }
        } else {
            DispatchQueue.main.async {
                self.serviceList = servicesFromSWData
                self.filteredServiceList = servicesFromSWData
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
    
    /// Filters 'serviceList' based on 'filterText' and 'selectedServiceType', then updates 'filteredServiceList'.
    private func filterServices() {
        filteredServiceList = serviceList.filter { service in
            let matchesText = filterText.isEmpty || service.serviceName.localizedCaseInsensitiveContains(filterText)
            let matchesType = selectedServiceType == .all || service.serviceType == selectedServiceType.id
            
            return matchesText && matchesType
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
            NavigationLink(destination: CustomServiceView()) {
                Text("Custom Service")
                    .font(.system(size: 20, weight: .regular))
            }
            .listRowBackground(Color(UIColor.systemGray5))
        }
    }
}

/// Subview for the 'Available Services' section
struct AvailableServicesSection: View {
    @Binding var services: [Service]
    
    var body: some View {
        Section(header: Text("Available Services")) {
            ForEach(Array(services.enumerated()), id: \.element.id) { index, service in
                NavigationLink(destination: ServicePlansView(chosenService: service)) {
                    Text(service.serviceName)
                        .font(.system(size: 20, weight: .regular))
                }
                .listRowBackground(index % 2 == 0 ? Color(UIColor.systemGray5) : Color(UIColor.systemGray4))
            }
        }
    }
}

struct SearchBarSection: View {
    @Binding var filterText: String
    var filterServiceFunction: () -> Void
    
    var body: some View {
        Section(header: Text("Search Service")) {
            TextField("Service Name...", text: $filterText)
                .padding(10)
                .cornerRadius(8)
                .onChange(of: filterText) {
                    filterServiceFunction()
                }
                .listRowInsets(EdgeInsets())
        }
    }
}


enum ServiceType: String, CaseIterable, Identifiable {
    case all = "All"
    case alışveriş = "Alışveriş"
    case diziFilm = "Dizi - Film"
    case gelişim = "Gelişim"
    case müzik = "Müzik"
    case oyun = "Oyun"
    
    var id: String { self.rawValue }
}


#Preview {
    ServicesView()
}
