import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var appState: AppState
    
    @Environment(\.modelContext) var context
    
    @ObservedObject private var userSubsVM = UserSubscriptionsViewModel()
    @ObservedObject private var userVM = UserViewModel()
    @ObservedObject private var authVM = AuthenticationViewModel()
    
    @State private var showLogOutFeedback = false
    @State private var logOutFeedbackText: String?
    @State private var isLogOutAlertPresented = false
    @State private var isSideMenuVisible = false
    
    @State private var showSelectLanguageSheetView = false
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        
        NavigationView {
            ZStack {
                backgroundView
                VStack {
                    appLogoView
                    greetingView
                    userSummaryCard
                    if showLogOutFeedback {
                        feedbackView
                    }
                    Spacer()
                }
                
                if isSideMenuVisible {
                    Color.black.opacity(0.5)
                        .edgesIgnoringSafeArea(.all)
                    sideMenuContent
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    sideMenuToggleButton
                }
                ToolbarItem(placement: .principal) {
                    Text("home")
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundStyle(Color.black.opacity(0.8))
                }
            }
            .background(Color.mainBlue)
            .navigationBarTitleDisplayMode(.inline)
        }
        .frame(maxWidth: .infinity)
        .alert(isPresented: $isLogOutAlertPresented) {
            logOutConfirmationAlert
        }
        .sheet(isPresented: $showSelectLanguageSheetView) {
            SelectLanguageSheetView(defaultLanguage: $appState.selectedLanguage)
        }
        .onAppear {
            loadUserData()
            configureNavigationBarAppearance()
        }
        .onChange(of: authVM.logOutSuccess) {
            if authVM.logOutSuccess {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.appState.updateLoginStatus(isLogged: false)
                }
            } else if let error = authVM.logOutError {
                logOutFeedbackText = error
            }
        }
        
    }
    
    
    // MARK: - Subviews
    
    private var appLogoView: some View {
        Image("hesapp")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: UIScreen.main.bounds.height * 0.12)
            .padding(.top, 15)
    }
    
    private var sideMenuToggleButton: some View {
        Button {
            withAnimation {
                isSideMenuVisible.toggle()
            }
        } label: {
            if isSideMenuVisible {
                Image(systemName: "xmark")
                    .foregroundColor(.black)
                    .imageScale(.large)
                    .padding()
            } else {
                Image(systemName: "list.bullet")
                    .foregroundColor(.black)
                    .imageScale(.large)
                    .padding()
            }
        }
    }
    
    private var headerView: some View {
        ZStack {
            HStack {
                sideMenuToggleButton
                Spacer()
            }
            appLogoView
            HStack {
                Spacer()
            }
        }
    }
    
    private var greetingView: some View {
        VStack {
            HStack {
                Image(systemName: "hand.wave.fill")
                    .resizable()
                    .frame(width: 25, height: 25)
                    .foregroundColor(.black)
                Text("welcome")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
            }
            Text(userVM.currentUser.fullName == "" ? " " : userVM.currentUser.fullName)
                .font(.title2)
                .padding(.bottom, 20)
                .foregroundColor(.black)
        }
        .padding(.top, 20)
        .padding(.horizontal)
    }
    
    private var userSummaryCard: some View {
        VStack(spacing: 5) {
            subscriptionCountView
            monthlySpendingView
            annualSpendingView
        }
        .padding()
        .background(Color(.systemGray4).opacity(0.85))
        .cornerRadius(10)
        .shadow(color: Color(.systemGray3), radius: 5, x: 0, y: 5)
        .frame(width: UIScreen.main.bounds.width * 0.85)
    }
    
    private var subscriptionCountView: some View {
        infoRow(labelKey: "label_total_sub_count", value: "\(userVM.currentUser.subscriptionCount)", icon: "number")
    }
    
    private var monthlySpendingView: some View {
        infoRow(labelKey: "label_monthly_spend", value: String(format: "%.2f", userVM.currentUser.monthlySpend), icon: "calendar")
    }
    
    private var annualSpendingView: some View {
        infoRow(labelKey: "label_annualy_spend", value: String(format: "%.2f", userVM.currentUser.monthlySpend * 12), icon: "calendar")
    }
    
    private func infoRow(labelKey: String, value: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
            Text(appState.localizedString(for: labelKey))
                .frame(alignment: .leading)
                .fontWeight(.medium)
            Spacer()
            Text(value)
                .frame(alignment: .trailing)
                .fontWeight(.medium)
            Text("₺")
                .font(.system(size: 16, weight: .medium))
        }
        .padding(.vertical, 5)
    }
    
    private var feedbackView: some View {
        VStack {
            if let error = logOutFeedbackText {
                Text(error)
                    .errorFeedbackTextStyle()
            }
            
            if authVM.isLoggingOut || authVM.logOutSuccess {
                VStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding(.top,10)
                        .padding(.bottom,3)
                        .scaleEffect(1.2)
                    Text(appState.localizedString(for: "text_logging_out"))
                        .font(.body)
                        .padding(.horizontal)
                        .foregroundColor(.black.opacity(0.9))
                        .transition(.opacity)
                        .padding(.bottom,10)
                }
                .background(Color.green.opacity(0.60))
                .cornerRadius(8)
            }
        }
        .animation(.easeInOut, value: showLogOutFeedback)
        .padding()
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private var logOutConfirmationAlert: Alert {
        Alert(
            title: Text(appState.localizedString(for: "label_log_out")),
            message: Text(appState.localizedString(for: "text_log_out_confirmation")),
            primaryButton: .destructive(Text(appState.localizedString(for: "button_ok"))) {
                logOut()
            },
            secondaryButton: .cancel(Text(appState.localizedString(for: "button_cancel"))) {
                isLogOutAlertPresented = false
            }
        )
    }
    
    private var sideMenuContent: some View {
        GeometryReader { _ in
            HStack {
                AppSideMenuView(
                    showSideMenu: $isSideMenuVisible,
                    showingLogoutAlert: $isLogOutAlertPresented,
                    showSelectLanguageSheetView: $showSelectLanguageSheetView)
                        .offset(x: isSideMenuVisible ? 0 : 230)
                        .animation(.easeInOut(duration: 0.3), value: isSideMenuVisible)
                Spacer()
            }
        }
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
    
    private func loadUserData() {
        /// Loads user data from Firestore if the app is opened for the first time or the user's subscription list has changed.
        guard !appState.isFetchedUserDetails || appState.isUserChangedSubsList else {
            loadUserDataFromSwiftData()
            return
        }
        
        /// Loads user data from SwiftData.
        loadUserDataFromFirestore()
    }

    private func loadUserDataFromFirestore() {
        userVM.fetchsUserFullname() { userFullName in
            guard let fullName = userFullName else { return }
            userVM.updateCurrentUserName(fullName: fullName)
            
            fetchSubscriptionsSummary()
        }
    }

    /// Fetchs user fullname from Firestore.
    private func fetchSubscriptionsSummary() {
        userSubsVM.fetchSubscriptionsSummary() { userSubCount, userMounthlySpend in
            userVM.updateCurrentUserSubscriptionSummary(subscriptionCount: userSubCount, monthlySpend: userMounthlySpend)
            userVM.saveUserDetailsToSwiftData(user: userVM.currentUser, context: context)
            
            appState.isFetchedUserDetails = true
            appState.isUserChangedSubsList = false
        }
    }
    
    /// Fetch subscription summary and update user subscription details.
    private func loadUserDataFromSwiftData() {
        guard let userEmail = AuthManager.shared.auth.currentUser?.email else { return }
        
        if let existingUser = userVM.fetchUserFromSwiftData(byEmail: userEmail, context: context) {
            userVM.currentUser = existingUser
        } else {
            print("No user found in SwiftData with email: \(userEmail)")
        }
    }
    
    /// Log the user out.
    private func logOut() {
        self.showLogOutFeedback = true

        userSubsVM.removeAllUserSubscriptionsFromSwiftData(context: context) { success in
            if success {
                appState.isFetchedUserDetails = false
                appState.isFetchedUserSubscriptions = false
                authVM.logOut()
            } else {
                authVM.logOutSuccess = false
                authVM.logOutError = appState.localizedString(for: "text_error_log_out")
            }
        }
    }

    /// Configures the navigation bar appearance.
    private func configureNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor(Color(.mainBlue).opacity(0.90))
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
}


#Preview {
    HomeView()
}
