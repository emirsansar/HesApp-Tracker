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
                .listStyle(InsetGroupedListStyle())
                .navigationTitle("services")
            }
        }
        .onAppear(perform: loadServices)
        .padding(.top, -40)
    }
    
    
    // MARK: - Subviews
    
    private var pickerServiceType: some View {
        Picker("filter_services_by_type", selection: $selectedServiceType) {
            ForEach(sortedServiceTypes) { typeOption in
                Text(typeOption.localizedString(appState: appState))
                    .tag(typeOption)
            }
        }
        .pickerStyle(.menu)
        .onChange(of: selectedServiceType) {
            filterServices()
        }
    }
    
    /// Returns service types with 'all' first, followed by the rest sorted alphabetically.
    private var sortedServiceTypes: [ServiceType] {
        let sortedTypes = ServiceType.allCases
            .filter { $0 != .all }
            .sorted { $0.localizedString(appState: appState) < $1.localizedString(appState: appState) }
        return [.all] + sortedTypes
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
            let matchesType = selectedServiceType == .all || service.serviceType == selectedServiceType.rawValue
            
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
        Section(header: Text("add_new_service")) {
            NavigationLink(destination: CustomServiceView()) {
                Text("label_custom_service")
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
        Section(header: Text("available_services")) {
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
        Section(header: Text("search_service")) {
            TextField("service_name_field", text: $filterText)
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
    case all = "all"
    case shopping = "shopping"
    case seriesMovies = "seriesMovies"
    case selfDevelopment = "selfDevelopment"
    case music = "music"
    case game = "game"
    case sport = "sport"
    case storage = "storage"
    
    var id: String { self.rawValue }
    
    func localizedString(appState: AppState) -> String {
        return appState.localizedString(for: self.rawValue)
    }
}


#Preview {
    ServicesView()
}
