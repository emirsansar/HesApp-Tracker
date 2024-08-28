import SwiftUI

struct EditSubscriptionSheetView: View {
    
    @Binding var selectedSubscription: UserSubscription?
    
    @State private var selectedPlanName: String = ""
    @State private var selectedPlanPrice: String = ""
    @State private var numberOfUsers: String = ""
    
    @Environment(\.colorScheme) var colorScheme
    
    let confirmEditedSubscription: (UserSubscription) -> Void
    
    var body: some View {
        ZStack {
            backgroundView
            
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
        .presentationDetents([.height(460)])
    }
    
    // MARK: - Subviews
    
    private var headerView: some View {
        Text("label_edit_subscription")
            .font(.system(size: 24, weight: .semibold))
            .fontWeight(.bold)
            .foregroundColor(.black)
            .padding(.top, 20)
            .padding(.bottom,10)
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
        .padding(.top, 15)
        .padding(.bottom,5)
    }
    
    private var planNameField: some View {
        VStack(alignment: .leading) {
            Text("label_plan_name")
                .font(.headline)
                .padding(.bottom, 2)
                .padding(.leading, 16)
            TextField("label_new_plan_name", text: $selectedPlanName)
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
            TextField("label_new_plan_price", text: $selectedPlanPrice)
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
            TextField("", text: $numberOfUsers)
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
            Text("button_confirm")
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
