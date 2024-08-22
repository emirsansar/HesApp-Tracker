import SwiftUI

struct ServicePlansView: View {
    
    var chosenService: Service
    
    @ObservedObject var plansVM = PlanViewModel()
    @ObservedObject var userSubsVM = UserSubscriptionsViewModel()
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var plans: [Plan] = [Plan]()
    @State private var selectedPlan: Plan?
    
    @State private var showConfirmSubSheetView = false
    @State private var numberOfUsers: String = "1"
    
    @State private var showCustomPlanSheet = false
    @State private var customPlanName: String = ""
    @State private var customPlanPrice: String = ""
    
    @State private var showFeedbackSheet = false
    @State private var feedbackMessage: String = ""
    @State private var isAddError: Bool = false
    
    @EnvironmentObject var appState: AppState

    var body: some View {
        
        VStack(spacing: 0) {
            headerView
            planListDivider
            planSections
        }
        .navigationBarBackButtonHidden(true)
        .background(GradientBackground())
        .onAppear {
            loadPlans()
        }
        .sheet(isPresented: $showConfirmSubSheetView) {
            ConfirmationSubSheetView(
                numberOfUsers: $numberOfUsers,
                showConfirmSubSheetView: $showConfirmSubSheetView,
                selectedPlan: $selectedPlan,
                processSubscription: processSubscription
            )
        }
        .sheet(isPresented: $showCustomPlanSheet) {
            CustomPlanSheetView(
                customPlanName: $customPlanName,
                customPlanPrice: $customPlanPrice,
                numberOfUsers: $numberOfUsers,
                showCustomPlanSheet: $showCustomPlanSheet,
                showFeedbackSheet: $showFeedbackSheet,
                feedbackMessage: $feedbackMessage,
                isAddError: $isAddError,
                processSubscription: processSubscription
            )
        }
        .sheet(isPresented: $showFeedbackSheet){
            FeedbackSheetView(
                showFeedbackSheet: $showFeedbackSheet,
                feedbackText: $feedbackMessage,
                errorOccured: $isAddError
            )
        }
        
    }
    
    
    // MARK: - Subviews
    
    private var planSections: some View {
        List {
            AddCustomPlanSection(showCustomPlanSheet: $showCustomPlanSheet)
            
            AvailablePlansSection(
                plans: $plans,
                selectedPlan: $selectedPlan,
                showConfirmSubSheetView: $showConfirmSubSheetView)
        }
    }
    
    private var headerView: some View {
        HStack {
            backToServicesButton
            Spacer()
            serviceTitleView
            Spacer()
        }
        .padding()
    }
    
    private var serviceTitleView: some View {
        Text("Plans for \(chosenService.serviceName)")
            .font(.system(size: 30, weight: .semibold))
            .fontWeight(.bold)
            .foregroundColor(.black)
            .lineLimit(3)
    }
    
    private var backToServicesButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "chevron.left")
                .foregroundColor(.black.opacity(0.85))
                .imageScale(.large)
        }
    }
    
    private var planListDivider: some View {
        Divider()
            .frame(height: 0.6)
            .background(Color.black.opacity(0.5))
    }
    
    
    // MARK: - Functions
    
    /// Loads plans of selected service from Firestore.
    private func loadPlans() {
        plansVM.fetchPlansOfServiceFromFirestore(documentID: chosenService.serviceName) { plans, error in
            self.plans = plans ?? []
        }
    }
    
    /// Adds the selected plan to user's collection in Firestore and provides feedback on the operation result.
    private func processSubscription(plan: Plan, quantity: Int) {
        userSubsVM.addPlanToUserOnFirestore(
            serviceName: chosenService.serviceName,
            plan: plan,
            personCount: quantity)
            { success in
                if success {
                    self.isAddError = false
                    self.feedbackMessage = "Selected plan added successfully:\n \(plan.planName) - \(plan.planPrice) ₺"
                    appState.isUserChangedSubsList = true
                } else {
                    self.isAddError = true
                    self.feedbackMessage = userSubsVM.planAddingError!
                }

                self.showFeedbackSheet = true
            }
    }
    
}


    // MARK: - Structs

struct PlanRow: View {
    var plan: Plan
    var index: Int
    
    var body: some View {
        HStack {
            Text(plan.planName)
                .font(.system(size: 19, weight: .regular))
            Spacer()
            Text("\(plan.planPrice, specifier: "%.2f") ₺")
                .font(.system(size: 18, weight: .regular))
        }
    }
}

/// Subview to create a custom plan by showing CustomPlanSheetView.
struct AddCustomPlanSection: View {
    @Binding var showCustomPlanSheet: Bool
    
    var body: some View {
        Section(header: Text("Add Custom Plan")) {
            HStack {
                Text("Custom Plan")
                    .font(.system(size: 19, weight: .regular))
                Spacer()
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.black.opacity(0.6))
            }
            .onTapGesture {
                showCustomPlanSheet = true
            }
        }
    }
}

/// Subview for the 'Available Plans' section.
struct AvailablePlansSection: View {
    @Binding var plans: [Plan]
    @Binding var selectedPlan: Plan?
    @Binding var showConfirmSubSheetView: Bool
    
    var body: some View {
        Section(header: Text("Available Plans")) {
            ForEach(Array(plans.enumerated()), id: \.element.planName) { index, plan in
                PlanRow(plan: plan, index: index)
                .onTapGesture {
                    selectedPlan = plan
                    showConfirmSubSheetView = true
                }.listRowBackground(index % 2 == 0 ? Color.white : Color(UIColor.systemGray5))
            }
        }
    }
}


#Preview {
    ServicePlansView(chosenService: Service(serviceName: "Spotify",serviceType: "Müzik"))
}
