import SwiftUI

struct CustomPlanSheetView: View {
    
    @Binding var customPlanName: String
    @Binding var customPlanPrice: String
    @Binding var numberOfUsers: String
    @Binding var showCustomPlanSheet: Bool
    @Binding var showFeedbackSheet: Bool
    @Binding var feedbackMessage: String
    @Binding var isAddError: Bool
    
    var processSubscription: (Plan, Int) -> Void
    
    var body: some View {
        
        VStack(spacing: 20) {
            Text("Your Custom Plan")
                .font(.headline)
            
            TextField("Plan Name:", text: $customPlanName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("Plan Price: 00.00", text: $customPlanPrice)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)
            
            TextField("How many users?", text: $numberOfUsers)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
            
            HStack {
                Button("Cancel") {
                    showCustomPlanSheet = false
                }
                .foregroundColor(.red)
                Spacer()
                Button("Confirm") {
                    if let quantity = Int(numberOfUsers), quantity > 0 {
                        let normalizedPriceString = customPlanPrice.replacingOccurrences(of: ",", with: ".")
                        
                        if let price = Double(normalizedPriceString) {
                            let customPlan = Plan(planName: customPlanName, planPrice: price)
                            processSubscription(customPlan, quantity)
                        } else {
                            feedbackMessage = "Error: Please enter a valid price."
                            showFeedbackSheet = true
                            isAddError = true
                            showCustomPlanSheet = false
                        }
                        showCustomPlanSheet = false
                        numberOfUsers = "1"
                    }
                }
                .disabled(customPlanName.isEmpty || customPlanPrice.isEmpty || numberOfUsers.isEmpty)
            }
        }
        .padding(.horizontal, 40)
        .presentationDetents([.height(300)])
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
        showCustomPlanSheet: $showCustomPlanSheet,
        showFeedbackSheet: $showFeedbackSheet,
        feedbackMessage: $feedbackMessage,
        isAddError: $isAddError,
        processSubscription: { plan, quantity in
        }
    )
    
}
