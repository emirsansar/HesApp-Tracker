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
    
    @State private var showConfirmSubSheetView = false
    @State private var numberOfUsers: String = "1"
    
    @State private var showCustomPlanSheet = false
    @State private var customPlanName: String = ""
    @State private var customPlanPrice: String = ""
    
    @State private var showFeedbackSheet = false
    @State private var feedbackMessage: String = ""
    @State private var isAddError: Bool = false

    
    var body: some View {
        
        VStack {
            headerView
            infoTextView
            planList
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
    
    private var planList: some View {
        List {
            ForEach(Array(plansVM.plans.enumerated()), id: \.element.planName) { index, plan in
                PlanRow(plan: plan, index: index)
                .onTapGesture {
                    self.selectedPlan = plan
                    self.showConfirmSubSheetView = true
                }
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            backToServicesButton
            Spacer()
            serviceTitleView
            Spacer()
            addCustomPlanButton
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
    
    
    // MARK: - Functions
    
    private func loadPlans() {
        plansVM.fetchPlansOfServiceFromFirestore(documentID: chosenService.serviceName) { plans, error in
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

    // MARK: - Structs

struct PlanRow: View {
    var plan: Plan
    var index: Int
    
    var body: some View {
        HStack {
            Text(plan.planName)
                .font(.system(size: 20, weight: .medium))
            Spacer()
            Text("\(plan.planPrice, specifier: "%.2f") TL")
                .font(.system(size: 19, weight: .medium))
        }
        .listRowBackground(index % 2 == 0 ? Color.white : Color(UIColor.systemGray5))
    }
}


#Preview {
    ServicePlans(chosenService: Service(serviceName: "Spotify",serviceType: "Müzik"))
}
