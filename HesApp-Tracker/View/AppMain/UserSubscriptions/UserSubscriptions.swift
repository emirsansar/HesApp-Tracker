import SwiftUI
import SwiftData

struct UserSubscriptions: View {
    
    @ObservedObject private var userSubscriptionsVM = UserSubscriptionsViewModel()
    
    @State private var sortType: SortType = .priceAscending
    
    @State private var selectedSubscription: UserSubscription?
    
    @State private var showFeedbackSheet = false
    @State private var showEditSheet = false
    @State private var feedbackMessage: String = ""
    @State private var isAddError: Bool = false
    
    @EnvironmentObject var appState: AppState
    @Environment(\.modelContext) var context
    
    @Query(sort: \UserSubscription.planPrice, order: .forward) private var userSubsriptionsFromSWData: [UserSubscription]
    
    var body: some View {
        VStack(spacing: 0) {
            titleView
            sortPickerView
            subscriptionListDivider
            subscriptionsListView
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .background(GradientBackground())
        .onAppear(perform: loadUserSubscriptions)
        .sheet(isPresented: $showFeedbackSheet) {
            FeedbackSheetView(
                showFeedbackSheet: $showFeedbackSheet,
                feedbackText: $feedbackMessage,
                errorOccured: $isAddError
            )
        }
        .sheet(isPresented: $showEditSheet) {
            EditSubscriptionSheetView(
                selectedSubscription: $selectedSubscription,
                confirmEditedSubscription: editSelectedUserSubscription
            )
        }
    }
    
    // MARK: - Subviews
    
    private var titleView: some View {
        Text("Your Subscriptions")
            .font(.system(size: 30, weight: .semibold))
            .padding()
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
        List {
            ForEach(Array(sortedSubscriptions.enumerated()), id: \.element.serviceName) { index, subscription in
                SubscriptionRow(selectedSubscription: $selectedSubscription,
                                subscription: subscription,
                                index: index,
                                onRemove: removeSubscription,
                                onEdit: toggleShowEditSheet)
            }
            .listRowInsets(EdgeInsets())
        }
        .refreshable {
            appState.isFetchedUserSubscriptions = false
            loadUserSubscriptions()
        }
    }
    
    private var subscriptionListDivider: some View {
        Divider()
            .frame(height: 0.6)
            .background(Color.black.opacity(0.5))
    }
    
    
    // MARK: - Functions
    
    /// Loads user's subscriptions from ViewModel.
    private func loadUserSubscriptions() {
        if !appState.isFetchedUserSubscriptions || appState.isUserChangedSubsList {
            userSubscriptionsVM.fetchUserSubscriptions() { fetchedUserSubscriptions, success in
                if success {
                    processAddingUserSubscriptionsToSwiftData(fetchedUserSubscriptinos: fetchedUserSubscriptions!)
                    appState.isFetchedUserSubscriptions = true
                }
            }
        } else {
            userSubscriptionsVM.userSubscriptions = userSubsriptionsFromSWData
        }
    }
    
    private func processAddingUserSubscriptionsToSwiftData (fetchedUserSubscriptinos: [UserSubscription]) {
        let existingUserSubscriptions = Set(userSubsriptionsFromSWData.map { $0.serviceName })
        let newUserSubscriptions = fetchedUserSubscriptinos.filter { !existingUserSubscriptions.contains($0.serviceName) }
        
        if !newUserSubscriptions.isEmpty {
            userSubscriptionsVM.saveUserSubscriptionsToSwiftData(userSubscriptions: newUserSubscriptions, context: context)
        }
    }

    /// Sorts the subscription list on ViewModel.
    private var sortedSubscriptions: [UserSubscription] {
        switch sortType {
        case .priceAscending:
            return userSubscriptionsVM.userSubscriptions.sorted {
                $0.planPrice / Double($0.personCount) < $1.planPrice / Double($1.personCount)
            }
        case .priceDescending:
            return userSubscriptionsVM.userSubscriptions.sorted {
                $0.planPrice / Double($0.personCount) > $1.planPrice / Double($1.personCount)
            }
        case .alphabetically:
            return userSubscriptionsVM.userSubscriptions.sorted { $0.serviceName < $1.serviceName }
        }
    }
    
    /// Process of the removing subscription.
    private func removeSubscription() {
        if let subscription = selectedSubscription {
            userSubscriptionsVM.removeSubscriptionFromUser(selectedSub: subscription) { success, error in
                DispatchQueue.main.async {
                    if success {
                        userSubscriptionsVM.removeUserSubscriptionFromSwiftData(
                            selectedSub: subscription,
                            userSubsriptionsFromSWData: userSubsriptionsFromSWData,
                            context: context) { removeSuccess in
                                handleRemovalResult(success: true, subscription: subscription)
                            }
                    } 
                    else if let error = error {
                        handleRemovalResult(success: false, subscription: subscription)
                    }
                }
            }
        }
    }
    
    /// Handles the result of removing a subscription by updating the feedback message and showing a feedback sheet.
    private func handleRemovalResult(success: Bool, subscription: UserSubscription) {
        if success {
            self.feedbackMessage = "The \(subscription.serviceName) was removed successfully."
            self.isAddError = false
            appState.isUserChangedSubsList = true
        } else {
            self.feedbackMessage = "Failed to remove the \(subscription.serviceName) subscription."
            self.isAddError = true
            loadUserSubscriptions()
        }
        self.showFeedbackSheet = true
    }
    
    /// Toggles the edit sheet when a subscription is selected for editing.
    private func toggleShowEditSheet() {
        if selectedSubscription != nil {
            showEditSheet.toggle()
        }
    }

    /// Called when confirm button is tapped in the edit sheet, it edits the selected subscription by ViewModel.
    private func editSelectedUserSubscription(editedSub: UserSubscription) {
        userSubscriptionsVM.updateSubscription(editedSub: editedSub) { success, error in
            DispatchQueue.main.async {
                if success {
                    self.feedbackMessage = "Subscription edited successfully."
                    appState.isUserChangedSubsList = true
                    self.isAddError = false
                } else if let error = error {
                    self.feedbackMessage = error
                    self.isAddError = true
                }
                showFeedbackSheet = true
                showEditSheet = false
                loadUserSubscriptions()
            }
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
    UserSubscriptions()
}
