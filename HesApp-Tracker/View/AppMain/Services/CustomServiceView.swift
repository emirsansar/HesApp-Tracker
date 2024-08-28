import SwiftUI

struct CustomServiceView: View {
    
    @ObservedObject var userSubsVM = UserSubscriptionsViewModel()
    
    @State private var serviceName: String = ""
    @State private var planName: String = ""
    @State private var planPrice: String = ""
    @State private var numberOfUsers: String = "1"
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showFeedbackSheet = false
    @State private var feedbackMessage: String = ""
    @State private var isAddError: Bool = false
    
    @EnvironmentObject var appState: AppState
    @Environment(\.colorScheme) var colorScheme
    
    
    var body: some View {
        VStack {
            headerView
            formFields
            addServiceButton
            Spacer()
        }
        .background(backgroundView)
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showFeedbackSheet){
            FeedbackSheetView(
                feedbackText: $feedbackMessage,
                errorOccured: $isAddError
            )
        }
    }
    
    
    // MARK: - Subviews
    
    private var headerView: some View {
        HStack {
            backToServicesViewButton
            Spacer()
            Text("label_custom_service")
                .font(.system(size: 30, weight: .semibold))
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding(.leading, -10)
            Spacer()
            
        }
        .padding()
    }
    
    private var formFields: some View {
        VStack(spacing: 10) {
            serviceNameField
            planNameField
            planPriceField
            numberOfUsersField
        }
        .background(Color(UIColor.systemGray5).opacity(0.35))
        .cornerRadius(10)
        .padding(.horizontal, 16)
    }
    
    private var serviceNameField: some View {
        VStack(alignment: .leading) {
            Text("label_service_name")
                .font(.headline)
                .padding(.bottom, 2)
                .padding(.leading, 16)
            TextField("label_enter_service_name", text: $serviceName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.bottom, 10)
                .padding(.horizontal, 16)
        }.padding(.top, 20)
    }
    
    private var planNameField: some View {
        VStack(alignment: .leading) {
            Text("label_plan_name")
                .font(.headline)
                .padding(.bottom, 2)
                .padding(.leading, 16)
            TextField("label_enter_plan_name", text: $planName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.bottom, 10)
                .padding(.horizontal, 16)
        }
    }
    
    private var planPriceField: some View {
        VStack(alignment: .leading) {
            Text("label_plan_price")
                .font(.headline)
                .padding(.bottom, 2)
                .padding(.leading, 16)
            TextField("label_enter_plan_price", text: $planPrice)
                .keyboardType(.decimalPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.bottom, 10)
                .padding(.horizontal, 16)
        }
    }
    
    private var numberOfUsersField: some View {
        VStack(alignment: .leading) {
            Text("label_user_count")
                .font(.headline)
                .padding(.bottom, 2)
                .padding(.leading, 16)
            TextField("label_enter_user_count", text: $numberOfUsers)
                .keyboardType(.numberPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 16)
                .padding(.bottom, 10)
        }.padding(.bottom, 15)
    }
    
    private var addServiceButton: some View {
        Button(action: {
            addCustomServiceToUser()
        }) {
            Text("button_add_service")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .cornerRadius(8)
        }
        .padding(.horizontal, 16)
        .padding(.top,15)
        .disabled(serviceName.isEmpty || planName.isEmpty || planPrice.isEmpty || numberOfUsers.isEmpty)
    }
    
    private var backToServicesViewButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "chevron.left")
                .foregroundColor(.black.opacity(0.85))
                .imageScale(.large)
        }
    }
    
    private var backgroundView: some View {
        Group {
            if colorScheme == .dark {
                GradientBGforDarkTheme()
            } else {
                GradientBackground()
            }
        }
    }
    
    
    // MARK: - Functions
    
    /// Checks whether the price can be converted to a Double.
    /// The price needs to be stored in Firestore with a dot instead of a comma.
    private func normalizePriceInput(planPrice: String) -> (Double?, Bool) {
        let normalizedPriceString = planPrice.replacingOccurrences(of: ",", with: ".")
        
        if let price = Double(normalizedPriceString) {
            return (price, true)
        } else {
            return (nil, false)
        }
    }
    
    /// Saves the custom service to the user's collection.
    private func addCustomServiceToUser () {
        let (convertedPrice, success) = normalizePriceInput(planPrice: planPrice)
        
        guard success else {
            DispatchQueue.main.async {
                self.feedbackMessage = appState.localizedString(for: "text_invalid_price_format")
                self.isAddError = true
                self.showFeedbackSheet = true
            }
            return
        }
        
        let plan = Plan(planName: planName, planPrice: convertedPrice!)
        
        userSubsVM.addPlanToUserOnFirestore(serviceName: serviceName, plan: plan, personCount: Int(numberOfUsers)!) { success in
            DispatchQueue.main.async {
                if success {
                    appState.isUserChangedSubsList = true
                    self.handleShowingFeedback(isSuccessful: true)
                } else {
                    self.handleShowingFeedback(isSuccessful: false)
                }
                
                self.feedbackMessage = userSubsVM.planAddingError ?? ""
                self.showFeedbackSheet = true
            }
        }
    }
    
    /// Controls the display of feedback based on whether the service was added successfully.
    private func handleShowingFeedback(isSuccessful: Bool) {
        if isSuccessful {
            self.serviceName = ""
            self.planName = ""
            self.planPrice = ""
            self.isAddError = false
        } else {
            self.isAddError = true
        }
    }
    
}


#Preview {
    CustomServiceView()
}
