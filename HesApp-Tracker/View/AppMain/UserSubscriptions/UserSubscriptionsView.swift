import SwiftUI
import SwiftData

struct UserSubscriptionsView: View {
    
    @ObservedObject private var userSubscriptionsVM = UserSubscriptionsViewModel()
    
    @State private var sortType: SortType = .priceAscending
    
    @State private var selectedSubscription: UserSubscription?
    
    @State private var showFeedbackSheet = false
    @State private var showEditSheet = false
    @State private var feedbackMessage: String = ""
    @State private var isAddError: Bool = false
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var appState: AppState
    @Environment(\.modelContext) var context
    
    @Query(sort: \UserSubscription.planPrice, order: .forward) private var userSubsriptionsFromSWData: [UserSubscription]
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            subscriptionListDivider
            subscriptionsListView
        }
        .onAppear(perform: loadUserSubscriptions)
        .sheet(isPresented: $showFeedbackSheet) {
            FeedbackSheetView(
                feedbackText: $feedbackMessage,
                errorOccured: $isAddError
            )
        }
        .sheet(isPresented: $showEditSheet) {
            EditSubscriptionSheetView(
                selectedSubscription: $selectedSubscription,
                confirmEditedSubscription: updateSelectedUserSubscription
            )
        }
        .onChange(of: appState.isUserChangedSubsList) {
            loadUserSubscriptions()
        }
        
    }
    
    // MARK: - Subviews
    
    private var titleView: some View {
        Text("your_subscriptions")
            .font(.system(size: 30, weight: .semibold))
            .foregroundColor(Color.black.opacity(0.9))
            .padding()
    }
    
    private var sortPickerView: some View {
        Picker("sort_options", selection: $sortType) {
            ForEach(SortType.allCases) { sortOption in
                Text(sortOption.localizedString(appState: appState))
                    .tag(sortOption)
                    .foregroundColor(colorScheme == .dark ? .black : .white)
            }
        }
        .pickerStyle(.segmented)
        .padding()
    }
    
    private var headerView: some View {
        VStack {
            titleView
            sortPickerView
        }
        .background(.mainBlue)
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
            .background(colorScheme == .dark ? .white : .black.opacity(0.5))
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
        userSubscriptionsVM.removeSubscriptionFromUser(selectedSub: selectedSubscription!) { success, error in
            DispatchQueue.main.async {
                if success {
                    userSubscriptionsVM.removeUserSubscriptionFromSwiftData(
                        selectedSub: selectedSubscription!,
                        userSubsriptionsFromSWData: userSubsriptionsFromSWData,
                        context: context) 
                        { removeSuccess in
                            handleRemovalResult(success: true, subscription: selectedSubscription!)
                        }
                }
                else if error != nil {
                    handleRemovalResult(success: false, subscription: selectedSubscription!)
                }
            }
        }
    }
    
    /// Handles the result of removing a subscription by updating the feedback message and showing a feedback sheet.
    private func handleRemovalResult(success: Bool, subscription: UserSubscription) {
        if success {
            self.feedbackMessage = String(format: appState.localizedString(for: "text_subscription_removed_succesfully"), subscription.serviceName)
            self.isAddError = false
            appState.isUserChangedSubsList = true
        } else {
            self.feedbackMessage = String(format: appState.localizedString(for: "text_subscription_remove_failed"), subscription.serviceName)
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
    private func updateSelectedUserSubscription(updatedSubscription: UserSubscription) {
        showEditSheet = false
        
        userSubscriptionsVM.updateSubscription(updatedSubscription: updatedSubscription) { success, error in
            DispatchQueue.main.async {
                if success {
                    userSubscriptionsVM.updateUserSubscriptionInSwiftData(
                        selectedSub: selectedSubscription!,
                        updatedSub: updatedSubscription,
                        userSubsriptionsFromSWData: userSubsriptionsFromSWData,
                        context: context)
                        { successOnSWData in
                            handleUpdateResult(success: successOnSWData, updatedSubscription: updatedSubscription)
                        }
                } 
                else if error != nil {
                    handleUpdateResult(success: false, updatedSubscription: updatedSubscription)
                }
            }
        }
    }
    
    /// Handles the result of updating a subscription by updating the feedback message and showing a feedback sheet.
    private func handleUpdateResult (success: Bool, updatedSubscription: UserSubscription) {
        if success {
            self.feedbackMessage = String(format: appState.localizedString(for: "text_subscription_updated_succesfully"), updatedSubscription.serviceName)
            appState.isUserChangedSubsList = true
            self.isAddError = false
        } else {
            self.feedbackMessage = String(format: appState.localizedString(for: "text_subscription_update_failed"), updatedSubscription.serviceName)
            self.isAddError = true
        }
        
        self.showFeedbackSheet = true
    }
    
}


enum SortType: String, CaseIterable, Identifiable {
    case priceAscending = "priceAscending"
    case priceDescending = "priceDescending"
    case alphabetically = "alphabetically"
    
    var id: String { self.rawValue }
    
    func localizedString(appState: AppState) -> String {
        return appState.localizedString(for: self.rawValue)
    }
}


#Preview {
    UserSubscriptionsView()
}
