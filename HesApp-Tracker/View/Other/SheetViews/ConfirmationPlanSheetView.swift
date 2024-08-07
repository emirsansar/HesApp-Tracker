//
//  ConfirmSubSheetView.swift
//  HesApp-Tracker
//
//  Created by Emir Sansar on 6.08.2024.
//

import SwiftUI

struct ConfirmationSubSheetView: View {
    
    @Binding var numberOfUsers: String
    @Binding var showConfirmSubSheetView: Bool
    @Binding var selectedPlan: Plan?
    
    var processSubscription: (Plan, Int) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("How many users?")
                .font(.headline)
            
            TextField("1", text: $numberOfUsers)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
            
            HStack {
                Button("Cancel") {
                    showConfirmSubSheetView = false
                }
                .foregroundColor(.red)
                Spacer()
                Button("Confirm") {
                    if let quantity = Int(numberOfUsers), quantity > 0, let plan = selectedPlan {
                        processSubscription(plan, quantity)
                        showConfirmSubSheetView = false
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
    @State var showConfirmSubSheetView = true
    @State var selectedPlan: Plan? = Plan(planName: "Basic", planPrice: 9.99)
    
    return ConfirmationSubSheetView(
        numberOfUsers: $numberOfUsers,
        showConfirmSubSheetView: $showConfirmSubSheetView,
        selectedPlan: $selectedPlan,
        processSubscription: { plan, quantity in
        }
    )
    
}
