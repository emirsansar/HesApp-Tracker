import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct UserSubscriptions: View {
    
    @ObservedObject private var viewModel = UserSubscriptionsViewModel()
    
    @State private var sortType: SortType = .priceAscending
    
    @State private var selectedSubscription: UserSubscription?
    
    @State private var showFeedbackSheet = false
    @State private var showEditSheet = false
    @State private var feedbackMessage: String = ""
    @State private var isAddError: Bool = false
    
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 0) {
            titleView
            sortPickerView
            subscriptionListDivider
            subscriptionsListView
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .background(GradientBackground())
        .onAppear(perform: loadSubscriptions)
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
                confirmEditedSubscription: confirmEdit2
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
            ForEach(Array(sortedSubscriptions.enumerated()), id: \.element.id) { index, subscription in
                SubscriptionRow(selectedSubscription: $selectedSubscription,
                                subscription: subscription,
                                index: index,
                                onRemove: removeSubscription,
                                onEdit: editSubscription)
            }
            .listRowInsets(EdgeInsets())
        }
        //.scrollContentBackground(.hidden)
    }
    
    private var subscriptionListDivider: some View {
        Divider()
            .frame(height: 0.6)
            .background(Color.black.opacity(0.5))
    }
    
    // MARK: - Functions
    
    /// Loads user's subscriptions from ViewModel.
    private func loadSubscriptions() {
        viewModel.fetchUserSubscriptions()
    }

    /// Sorts the subscription list on ViewModel.
    private var sortedSubscriptions: [UserSubscription] {
        switch sortType {
        case .priceAscending:
            return viewModel.userSubscriptions.sorted {
                $0.plan.planPrice / Double($0.personCount) < $1.plan.planPrice / Double($1.personCount)
            }
        case .priceDescending:
            return viewModel.userSubscriptions.sorted {
                $0.plan.planPrice / Double($0.personCount) > $1.plan.planPrice / Double($1.personCount)
            }
        case .alphabetically:
            return viewModel.userSubscriptions.sorted { $0.serviceName < $1.serviceName }
        }
    }
    
    /// Process of the removing subscription.
    private func removeSubscription() {
        if let subscription = selectedSubscription {
            viewModel.removeSubscriptionFromUser(selectedSub: subscription) { success, error in
                DispatchQueue.main.async {
                    if success {
                        self.feedbackMessage = "The \(selectedSubscription?.serviceName ?? "Subscription") was removed successfully."
                        self.isAddError = false
                        appState.isUserChangedSubsList = true
                    } else if let error = error {
                        self.feedbackMessage = error.localizedDescription
                        self.isAddError = false
                        self.loadSubscriptions()
                    }
                    self.showFeedbackSheet = true
                }
            }
        }
    }
    
    /// Opens the edit sheet when a subscription is selected for editing.
    private func editSubscription() {
        if selectedSubscription != nil {
            showEditSheet = true
        }
    }
    
    /// Called when confirm button is tapped in the edit sheet, it edits the selected subscription by ViewModel.
    private func confirmEdit2(editedSub: UserSubscription) {
        viewModel.updateSubscription(editedSub: editedSub) { success, error in
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
                loadSubscriptions()
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
