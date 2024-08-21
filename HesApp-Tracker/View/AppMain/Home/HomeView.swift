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

    
    var body: some View {
        
        NavigationView {
            ZStack {
                GradientBackground()
                
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
                    Text("Home")
                        .font(.system(size: 18, weight: .semibold))
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
        .onAppear {
            loadUserData()
            configureNavigationBarAppearance()
        }
        .onChange(of: authVM.logOutSuccess) { success in
            if success {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
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
            .padding(.top, 5)
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
                Text("Welcome,")
                    .font(.title)
                    .fontWeight(.bold)
            }
            Text(userVM.currentUser.fullName == "" ? " " : userVM.currentUser.fullName)
                .font(.title2)
                .padding(.bottom, 20)
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
        .background(Color.white.opacity(0.8))
        .cornerRadius(10)
        .shadow(color: .gray, radius: 5, x: 0, y: 5)
        .frame(width: UIScreen.main.bounds.width * 0.85)
    }
    
    private var subscriptionCountView: some View {
        infoRow(label: "Total sub count:", value: "\(userVM.currentUser.subscriptionCount)", icon: "number")
    }
    
    private var monthlySpendingView: some View {
        infoRow(label: "Monthly spend:", value: String(format: "%.2f", userVM.currentUser.monthlySpend), icon: "calendar")
    }
    
    private var annualSpendingView: some View {
        infoRow(label: "Annually spend:", value: String(format: "%.2f", userVM.currentUser.monthlySpend * 12), icon: "calendar")
    }
    
    private func infoRow(label: String, value: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
            Text(label)
                .frame(alignment: .leading)
            Spacer()
            Text(value)
                .frame(alignment: .trailing)
                .fontWeight(.bold)
            Text("₺")
                .font(.system(size: 16, weight: .bold))
        }
        .padding(.vertical, 5)
    }
    
    private var feedbackView: some View {
        VStack {
            if let error = logOutFeedbackText {
                Text(error)
                    .font(.body)
                    .padding()
                    .background(Color.red.opacity(0.20))
                    .foregroundColor(.black.opacity(0.85))
                    .cornerRadius(8)
                    .padding(.bottom, 10)
                    .transition(.opacity)
            }
            
            if authVM.isLoggingOut || authVM.logOutSuccess {
                VStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding(.top,10)
                        .padding(.bottom,3)
                        .scaleEffect(1.2) 
                    Text("Logging out.")
                        .font(.body)
                        .padding(.horizontal)
                        .foregroundColor(.black.opacity(0.85))
                        .cornerRadius(8)
                        .transition(.opacity)
                        .padding(.bottom,10)
                }
                .background(Color.green.opacity(0.20))
            }
        }
        .animation(.easeInOut, value: showLogOutFeedback)
        .padding()
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private var logOutConfirmationAlert: Alert {
        Alert(
            title: Text("Log Out"),
            message: Text("Are you sure you want to log out?"),
            primaryButton: .destructive(Text("Log Out")) {
                logOut()
            },
            secondaryButton: .cancel() {
                isLogOutAlertPresented = false
            }
        )
    }
    
    private var sideMenuContent: some View {
        GeometryReader { _ in
            HStack {
                AppSideMenuView(
                    showSideMenu: $isSideMenuVisible,
                    showingLogoutAlert: $isLogOutAlertPresented)
                        .offset(x: isSideMenuVisible ? 0 : 230)
                        .animation(.easeInOut(duration: 0.3), value: isSideMenuVisible)
                Spacer()
            }
        }
    }
    
    
    // MARK: - Functions
    
    /// Loads user data from ViewModels.
    private func loadUserData() {
        
        if !appState.isFetchedUserDetails || appState.isUserChangedSubsList {
            DispatchQueue.main.async {
                userVM.fetchsUserFullname() { userFullName in
                    let fullName = userFullName
                    
                    userSubsVM.fetchSubscriptionsSummary() { userSubCount, userMounthlySpend in
                        let subsCount = userSubCount
                        let monthlySpend = userMounthlySpend
                        
                        userVM.updateCurrentUser(fullName: fullName!, subscriptionCount: subsCount, monthlySpend: monthlySpend)
                        userVM.saveUserDetailsToSwiftData(user: userVM.currentUser, context: context)
                        
                        appState.isFetchedUserDetails = true
                        appState.isUserChangedSubsList = false
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                let userEmail = AuthManager.shared.auth.currentUser!.email!
                
                if let existingUser = userVM.fetchUserFromSwiftData(byEmail: userEmail, context: context) {
                    userVM.currentUser = existingUser
                } else {
                    print("No user found in SwiftData with email: \(userEmail)")
                }
            }
        }

    }
    
    /// Log the user out.
    private func logOut() {
        self.showLogOutFeedback = true
        authVM.logOut()
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
    //let user = User(email: "emir2@gmail.com", fullName: "Emir Sansar", subscriptionCount: 2, monthlySpend: 125.12)
    
    HomeView()
}
