import SwiftUI
import FirebaseAuth

struct Home: View {
    
    @ObservedObject private var userDetailVM = UserAuthAndDetailsViewModel()
    @ObservedObject private var userSubsVM = UserSubscriptionsViewModel()
    
    @State private var isFeedbackVisible = false
    @State private var feedbackText: String?
    
    @State private var isLogOutAlertPresented = false
    @State private var isSideMenuVisible = false
    
    init () {
        configureNavigationBarAppearance()
    }
    
    var body: some View {
        
        NavigationView {
            ZStack {
                GradientBackground()
                
                VStack {
                    appLogoView
                    greetingView
                    userSummaryCard
                    if isFeedbackVisible {
                        feedbackView
                    }
                    Spacer()
                }
                .padding()
                .onAppear {
                    loadUserData()
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
            }
            .alert(isPresented: $isLogOutAlertPresented) {
                logOutConfirmationAlert
            }
        }
        
    }
    
    
    // MARK: - Subviews
    
    private var appLogoView: some View {
        Image("hesapp")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: UIScreen.main.bounds.height * 0.12)
            .padding(.top, -40)
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
            Text(userDetailVM.fullname)
                .font(.title2)
                .padding(.bottom, 20)
        }
        .padding(.top, 30)
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
        infoRow(label: "Total sub count:", value: "\(userSubsVM.totalSubscriptionCount)", icon: "number")
    }
    
    private var monthlySpendingView: some View {
        infoRow(label: "Monthly spending:", value: String(format: "%.2f", userSubsVM.totalMonthlySpending), icon: "calendar")
    }
    
    private var annualSpendingView: some View {
        infoRow(label: "Annually spend:", value: String(format: "%.2f", userSubsVM.totalMonthlySpending * 12), icon: "calendar")
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
        Text(feedbackText ?? "Info")
            .font(.body)
            .padding()
            .padding(.bottom, 5)
            .background(feedbackText?.starts(with: "Error") == true ? Color.red : Color.green)
            .foregroundColor(.white)
            .cornerRadius(8)
            .frame(maxWidth: .infinity, alignment: .center)
            .opacity(isFeedbackVisible ? 1 : 0)
            .transition(.opacity)
            .animation(.easeInOut, value: isFeedbackVisible)
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
                        .animation(.easeInOut(duration: 0.4), value: isSideMenuVisible)
                Spacer()
            }
        }
    }
    
    
    // MARK: - Functions
    
    /// Loads user data.
    private func loadUserData() {
        userDetailVM.getUserFullname()
        userSubsVM.fetchSubscriptionsSummary()
    }
    
    /// Signs the user out.
    private func logOut() {
        do {
            try Auth.auth().signOut()
            try AuthManager.shared.auth.signOut()
        } catch let signOutError as NSError {
            feedbackText = "Error signing out: \(signOutError.localizedDescription)"
            isFeedbackVisible = true
        }
        
        isLogOutAlertPresented = false
    }

    /// Configures the navigation bar appearance.
    private func configureNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.shadowColor = .clear
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }
    
}


#Preview {
    Home()
}
