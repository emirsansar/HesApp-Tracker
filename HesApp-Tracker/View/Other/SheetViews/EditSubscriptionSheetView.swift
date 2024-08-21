import SwiftUI

struct EditSubscriptionSheetView: View {
    
    @Binding var selectedSubscription: UserSubscription?
    
    @State private var selectedPlanName: String = ""
    @State private var selectedPlanPrice: String = ""
    @State private var numberOfUsers: String = ""
    
    let confirmEditedSubscription: (UserSubscription) -> Void
    
    var body: some View {
        
        ZStack {
            GradientBackground()
            
            VStack {
                headerView
                formFields
                confirmButton
                Spacer()
            }
            .padding()
            .onAppear {
                if let subscription = selectedSubscription {
                    selectedPlanName = subscription.planName
                    selectedPlanPrice = String(subscription.planPrice)
                    numberOfUsers = String(subscription.personCount)
                }
            }
        }
        .presentationDetents([.height(500)])
        
    }
    
    // MARK: - Subviews
    
    private var headerView: some View {
        Text("Edit Subscription")
            .font(.system(size: 24, weight: .semibold))
            .fontWeight(.bold)
            .foregroundColor(.black)
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
        VStack(alignment: .center) {
            Text(selectedSubscription?.serviceName ?? "")
                .font(.title3).bold()
        }
        .padding(.top, 20)
        .padding(.bottom,10)
    }
    
    private var planNameField: some View {
        VStack(alignment: .leading) {
            Text("Plan Name")
                .font(.headline)
                .padding(.bottom, 2)
                .padding(.leading, 16)
            TextField("New Plan Name", text: $selectedPlanName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.bottom, 10)
                .padding(.horizontal, 16)
        }
    }
    
    private var planPriceField: some View {
        VStack(alignment: .leading) {
            Text("Plan Price")
                .font(.headline)
                .padding(.bottom, 2)
                .padding(.leading, 16)
            TextField("New Plan Price", text: $selectedPlanPrice)
                .keyboardType(.decimalPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.bottom, 10)
                .padding(.horizontal, 16)
        }
    }
    
    private var numberOfUsersField: some View {
        VStack(alignment: .leading) {
            Text("User Count")
                .font(.headline)
                .padding(.bottom, 2)
                .padding(.leading, 16)
            TextField("New User Count", text: $numberOfUsers)
                .keyboardType(.numberPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 16)
                .padding(.bottom, 10)
        }.padding(.bottom, 15)
    }
    
    private var confirmButton: some View {
        Button {
            let normalizedPriceString = selectedPlanPrice.replacingOccurrences(of: ",", with: ".")
            
            if let price = Double(normalizedPriceString), let personCount = Int(numberOfUsers) {
                let editedSubscription = UserSubscription(serviceName: selectedSubscription!.serviceName, planName: selectedPlanName, planPrice: price, personCount: personCount)
                
                confirmEditedSubscription(editedSubscription)
            }
        } label: {
            Text("Confirm")
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .padding(.top)
        .padding(.horizontal, 16)
        .disabled(selectedPlanPrice.isEmpty || selectedPlanName.isEmpty || numberOfUsers.isEmpty)
    }
    
}


//Preview
struct EditSubscriptionSheetView_Previews: PreviewProvider {
    static var previews: some View {
        EditSubscriptionSheetView(
            selectedSubscription: .constant(
                UserSubscription(
                    serviceName: "Example Service",
                    planName: "Example Plan",
                    planPrice: 100.0,
                    personCount: 1
                )
            ),
            confirmEditedSubscription: { updatedSubscription in
                print("Updated subscription: \(updatedSubscription)")
            }
        )
    }
}
