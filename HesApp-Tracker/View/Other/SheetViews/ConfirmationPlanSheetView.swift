import SwiftUI

struct ConfirmationSubSheetView: View {
    
    @Binding var numberOfUsers: String
    @Binding var selectedPlan: Plan?
    
    var processSubscription: (Plan, Int) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("label_how_many_users")
                .labelStyle()
            
            TextField("1", text: $numberOfUsers)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
            
            HStack {
                Button("button_cancel") {
                    dismiss()
                }
                .foregroundColor(.red)
                Spacer()
                Button("button_confirm") {
                    if let quantity = Int(numberOfUsers), quantity > 0, let plan = selectedPlan {
                        processSubscription(plan, quantity)
                        dismiss()
                    }
                }
                .disabled(numberOfUsers.isEmpty)
            }
        }
        .padding(.horizontal, 40)
        .presentationDetents([.height(200)])
    }
}

#Preview {
    
    @State var numberOfUsers = "1"
    @State var selectedPlan: Plan? = Plan(planName: "Basic", planPrice: 9.99)
    
    return ConfirmationSubSheetView(
        numberOfUsers: $numberOfUsers,
        selectedPlan: $selectedPlan,
        processSubscription: { plan, quantity in
        }
    )
    
}
