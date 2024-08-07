//
//  UsersSubscriptions.swift
//  HesApp-Tracker
//
//  Created by Emir Sansar on 2.08.2024.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct UsersSubscriptions: View {
    
    @ObservedObject private var viewModel = UsersSubscriptionsViewModel()
    
    @State private var sortType: SortType = .priceAscending
    @State private var selectedSubscription: UsersSub?
    @State private var isRemoveAlertPresented = false
    @State private var isFeedbackVisible = false
    @State private var feedbackMessage: String?
    
    var body: some View {
        
        VStack {
            titleView
            sortPickerView
            subscriptionsListView
            if isFeedbackVisible {
                feedbackView
            } else {
                instructionTextView
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .background(GradientBackground())
        .onAppear(perform: fetchSubscriptions)
        .alert(isPresented: $isRemoveAlertPresented) {
            removeAlert
        }

    }
    
    
    // MARK: - Subviews
    
    private var titleView: some View {
        Text("Your Subscriptions")
            .font(.system(size: 30, weight: .semibold))
    }
    
    private var sortPickerView: some View {
        Picker("Sort Option", selection: $sortType) {
            ForEach(SortType.allCases) { sortOption in
                Text(sortOption.rawValue).tag(sortOption)
            }
        }
        .pickerStyle(PalettePickerStyle())
        .padding()
    }
    
    private var subscriptionsListView: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(Array(sortedSubscriptions.enumerated()), id: \.element.serviceName) { index, subscription in
                    subscriptionRow(subscription: subscription, index: index)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func subscriptionRow(subscription: UsersSub, index: Int) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(subscription.serviceName)
                    .font(.system(size: 18, weight: .regular))
                Text(subscription.planName)
                    .font(.system(size: 15, weight: .light))
            }.padding(.leading, 10)
            Spacer()
            Text("\((subscription.planPrice / Double(subscription.personCount)), specifier: "%.2f") TL")
                .padding(.trailing)
                .font(.system(size: 17, weight: .regular))
            
        }
        .padding()
        .background(index % 2 == 0 ? Color.white : Color(UIColor.systemGray5))
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .shadow(radius: 2)
        .onTapGesture {
            selectedSubscription = subscription
            isRemoveAlertPresented = true
        }
    }

    
    private var feedbackView: some View {
        Text(feedbackMessage ?? "Info")
            .font(.body)
            .padding()
            .padding(.bottom, 5)
            .background(feedbackMessage?.starts(with: "Error") == true ? Color.red : Color.green)
            .foregroundColor(.white)
            .cornerRadius(8)
            .frame(maxWidth: .infinity, alignment: .center)
            .opacity(isFeedbackVisible ? 1 : 0)
            .transition(.opacity)
            .animation(.easeInOut, value: isFeedbackVisible)
    }
    
    private var instructionTextView: some View {
        Text("Tap on the subscription you want to remove.")
            .font(.system(size: 14, weight: .regular))
            .foregroundColor(Color(UIColor.black))
            .padding()
            .opacity(isFeedbackVisible ? 0 : 1)
    }
    
    private var removeAlert: Alert {
        Alert(
            title: Text("Remove Subscription"),
            message: Text("Are you sure you want to remove the subscription of \(selectedSubscription?.serviceName ?? "Unknown Service")?"),
            primaryButton: .destructive(Text("Remove")) {
                removeSubscription()
            },
            secondaryButton: .cancel()
        )
    }
    
    
    // MARK: - Functions
    
    private var sortedSubscriptions: [UsersSub] {
        switch sortType {
        case .priceAscending:
            return viewModel.userSubscriptions.sorted {
                $0.planPrice/Double($0.personCount) < $1.planPrice/Double($1.personCount)  }
        case .priceDescending:
            return viewModel.userSubscriptions.sorted {
                $0.planPrice/Double($0.personCount) > $1.planPrice/Double($1.personCount)  }
        case .alphabetically:
            return viewModel.userSubscriptions.sorted { $0.serviceName < $1.serviceName }
        }
    }
    
    private func fetchSubscriptions() {
        viewModel.fetchUserSubscriptions(userEmail: "emir2@gmail.com")
    }
    
    private func removeSubscription() {
        if let subscription = selectedSubscription {
            viewModel.removeSubscriptionFromUser(selectedSub: subscription) { success, error in
                if success {
                    displayFeedback(message: "\(subscription.serviceName) is removed successfully.")
                } else if let error = error {
                    displayFeedback(message: error.localizedDescription)
                }
            }
        }
    }
    
    private func displayFeedback(message: String) {
        feedbackMessage = message
        isFeedbackVisible = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isFeedbackVisible = false
        }
    }
}


enum SortType: String, CaseIterable, Identifiable {
    case priceAscending = "Price ↑"
    case priceDescending = "Price ↓"
    case alphabetically = "Alphabetically"
    
    var id: String { self.rawValue }
}


#Preview {
    UsersSubscriptions()
}
