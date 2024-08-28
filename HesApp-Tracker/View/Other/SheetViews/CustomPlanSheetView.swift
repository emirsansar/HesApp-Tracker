import SwiftUI

struct CustomPlanSheetView: View {
    
    @Binding var customPlanName: String
    @Binding var customPlanPrice: String
    @Binding var numberOfUsers: String
    @Binding var showFeedbackSheet: Bool
    @Binding var feedbackMessage: String
    @Binding var isAddError: Bool
    
    var processSubscription: (Plan, Int) -> Void
    
    @EnvironmentObject var appState: AppState
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack() {
            headerView
            formFields
            formButtons
            Spacer()
        }
        .background(backgroundView)
        .presentationDetents([.height(375)])
    }
    
    // MARK: - Subviews
    
    private var headerView: some View {
        Text("label_your_custom_plan")
            .font(.system(size: 24, weight: .semibold))
            .foregroundStyle(.black)
            .padding(.top, 20)
            .padding(.bottom,10)
    }
    
    private var formFields: some View {
        VStack(spacing: 10) {
            planNameField
            planPriceField
            userCountField
        }
        .padding(.horizontal, 5)
        .padding(.top)
        .background(Color(UIColor.systemGray5).opacity(0.35))
        .cornerRadius(10)
        .padding(.horizontal, 30)
    }
    
    private var planNameField: some View {
        VStack(alignment: .leading) {
            Text("label_plan_name")
                .font(.headline)
                .padding(.bottom, 2)
                .padding(.leading, 16)
            TextField("label_plan_name", text: $customPlanName)
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
            TextField("label_plan_price_with_format", text: $customPlanPrice)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)
                .padding(.bottom, 10)
                .padding(.horizontal, 16)
        }
    }
    
    private var userCountField: some View {
        VStack(alignment: .leading) {
            Text("label_user_count")
                .font(.headline)
                .padding(.bottom, 2)
                .padding(.leading, 16)
            TextField("label_how_many_users", text: $numberOfUsers)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
                .padding(.bottom, 15)
                .padding(.horizontal, 16)
        }
    }
    
    private var formButtons: some View {
        HStack {
            cancelButton
            Spacer()
            confirmButton
        }
        .padding(.top, 10)
        .padding(.horizontal, 50)
    }
    
    private var confirmButton: some View {
        Button("button_confirm") {
            if let quantity = Int(numberOfUsers), quantity > 0 {
                let normalizedPriceString = customPlanPrice.replacingOccurrences(of: ",", with: ".")
                
                if let price = Double(normalizedPriceString) {
                    let customPlan = Plan(planName: customPlanName, planPrice: price)
                    processSubscription(customPlan, quantity)
                } else {
                    feedbackMessage = appState.localizedString(for: "label_error_invalid_format")
                    showFeedbackSheet = true
                    isAddError = true
                    dismiss()
                }
                numberOfUsers = "1"
                dismiss()
            }
        }
        .font(.system(size: 17, weight: .medium))
        .disabled(customPlanName.isEmpty || customPlanPrice.isEmpty || numberOfUsers.isEmpty)
    }
    
    private var cancelButton: some View {
        Button("button_cancel") {
            dismiss()
        }
        .font(.system(size: 17, weight: .medium))
        .foregroundColor(.red)
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
    
}

#Preview {
    
    @State var customPlanName = ""
    @State var customPlanPrice = ""
    @State var numberOfUsers = "1"
    @State var showCustomPlanSheet = true
    @State var showFeedbackSheet = false
    @State var feedbackMessage = ""
    @State var isAddError = false
    
    return CustomPlanSheetView(
        customPlanName: $customPlanName,
        customPlanPrice: $customPlanPrice,
        numberOfUsers: $numberOfUsers,
        showFeedbackSheet: $showFeedbackSheet,
        feedbackMessage: $feedbackMessage,
        isAddError: $isAddError,
        processSubscription: { plan, quantity in
        }
    )
    
}
