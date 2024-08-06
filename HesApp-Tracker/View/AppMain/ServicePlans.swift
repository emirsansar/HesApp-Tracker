//
//  ServicePlans.swift
//  HesApp-Tracker
//
//  Created by Emir Sansar on 3.08.2024.
//

import SwiftUI

struct ServicePlans: View {
    
    var chosenService: Service
    
    @ObservedObject var plansVM = PlanViewModel()
    @ObservedObject var userSubsVM = UsersSubscriptionsViewModel()
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedPlan: Plan?
    
    @State private var showSubscriptionSheet = false
    @State private var numberOfUsers: String = "1"
    
    @State private var showCustomPlanSheet = false
    @State private var customPlanName: String = ""
    @State private var customPlanPrice: String = ""
    
    @State private var showFeedbackSheet = false
    @State private var feedbackMessage: String = ""
    @State private var isAddError: Bool = false

    
    var body: some View {
        
        VStack {
            HStack {
                backToServicesButton
                Spacer()
                serviceTitleView
                Spacer()
                addCustomPlanButton
            }
            .padding()
            
            infoTextView
            planList
        }
        .background(gradientBG)
        .onAppear {
            loadPlans()
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showSubscriptionSheet) {
            subscriptionConfirmationSheet
        }
        .sheet(isPresented: $showCustomPlanSheet) {
            customPlanSheet
        }
        .sheet(isPresented: $showFeedbackSheet){
            feedbackSheet
        }
        
    }
    
    
    // MARK: - Subviews
    
    private var planList: some View {
        List {
            ForEach(Array(plansVM.plans.enumerated()), id: \.element.planName) { index, plan in
                HStack {
                    Text(plan.planName)
                        .font(.system(size: 20, weight: .medium))
                    Spacer()
                    Text("\(plan.planPrice, specifier: "%.2f") TL")
                        .font(.system(size: 19, weight: .medium))
                }
                .listRowBackground(index % 2 == 0 ? Color.white : Color(UIColor.systemGray5))
                .contentShape(Rectangle())
                .onTapGesture {
                    self.selectedPlan = plan
                    self.showSubscriptionSheet = true
                }
            }
        }
    }
    
    private var subscriptionConfirmationSheet: some View {
        VStack(spacing: 20) {
            Text("How many users?")
                .font(.headline)
            
            TextField("1", text: $numberOfUsers)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
            
            HStack {
                Button("Cancel") {
                    showSubscriptionSheet = false
                }
                .foregroundColor(.red)
                Spacer()
                Button("Confirm") {
                    if let quantity = Int(numberOfUsers), quantity > 0 {
                        processSubscription(plan: selectedPlan!, quantity: quantity)
                        showSubscriptionSheet = false
                    }
                }
                .disabled(numberOfUsers.isEmpty)
            }
        }
        .padding(.horizontal, 40)
        .presentationDetents([.height(200)])
    }
    
    private var feedbackSheet: some View {
        VStack(spacing: 20) {
            Text(isAddError ? "Error" : "Success")
                .font(.title2)
                .foregroundColor(isAddError ? .red : .green)
            
            Text(isAddError ? feedbackMessage : "Plan has been added successfully.")
                .font(.body)
                .multilineTextAlignment(.center)
            
            Button("OK") {
                showFeedbackSheet = false
                self.numberOfUsers = "1"
                if !isAddError {
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .padding()
        }
        .padding(.horizontal, 40)
        .presentationDetents([.height(170)])
    }

    private var customPlanSheet: some View {
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
                            processSubscription(plan: customPlan, quantity: quantity)
                        } else {
                            feedbackMessage = "Error: Please enter a valid price."
                            isAddError = true
                            self.showCustomPlanSheet = false
                            self.showFeedbackSheet = true
                        }
                        self.showCustomPlanSheet = false
                        self.numberOfUsers = "1"
                    }
                }
                .disabled(customPlanName.isEmpty || customPlanPrice.isEmpty || numberOfUsers.isEmpty)
            }
        }
        .padding(.horizontal, 40)
        .presentationDetents([.height(300)])
    }
    
    
    private var serviceTitleView: some View {
        Text("Plans for \(chosenService.serviceName)")
            .font(.system(size: 30, weight: .semibold))
            .fontWeight(.bold)
            .foregroundColor(.black)
            .lineLimit(3)
    }
    
    private var addCustomPlanButton: some View {
        Button(action: {
            self.showCustomPlanSheet = true
        }) {
            Image(systemName: "plus")
                .foregroundColor(.black.opacity(0.85))
                .imageScale(.large)
        }
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
    
    private var infoTextView: some View {
        Text("Tap to choose your subscription.")
            .font(.headline)
            .fontWeight(.medium)
            .foregroundColor(.black.opacity(0.7))
            .padding(.top, -10)
    }
    
    private var gradientBG: LinearGradient {
        LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.55), Color("#afd2e0")]), startPoint: .center, endPoint: .bottom)
    }
    
    
    // MARK: - Functions
    
    private func loadPlans() {
        plansVM.getPlansOfServiceFromFirestore(documentID: chosenService.serviceName) { plans, error in
            self.plansVM.plans = plans ?? []
        }
    }
    
    private func processSubscription(plan: Plan, quantity: Int) {
        userSubsVM.addPlanToUserOnFirestore(serviceName: chosenService.serviceName, plan: plan, personCount: quantity) { success in
            if success {
                self.isAddError = false
            } else {
                self.isAddError = true
            }
            
            self.feedbackMessage = userSubsVM.planAddingError ?? ""
            self.showFeedbackSheet = true
        }
    }
    
}


#Preview {
    ServicePlans(chosenService: Service(serviceName: "Spotify",serviceType: "Müzik"))
}
