import SwiftUI
import FirebaseAuth

struct Home: View {
    
    @Binding var isUserLoggedIn: Bool
    
    @ObservedObject private var userDetailVM = UserAuthAndDetailsViewModel()
    @ObservedObject private var userSubsVM = UsersSubscriptionsViewModel()
    
    @State private var isFeedbackVisible = false
    @State private var feedbackMessage: String?
    
    var body: some View {
        
        VStack {
            appLogoView
            greetingView
            userSummaryView
            if isFeedbackVisible {
                feedbackView
            }
            Spacer()
            logOutButton
        }
        .padding()
        .background(GradientBackground())
        .onAppear {
            loadUserData()
        }
        
    }
    
    
    // MARK: - Subviews
    
    private var appLogoView: some View {
        Image("hesapp")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: UIScreen.main.bounds.height * 0.10)
            .padding(.top, 10)
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
        .padding()
    }
    
    private var userSummaryView: some View {
        VStack(alignment: .leading) {
            userSubsCount
            userMonthlySpend
            userAnnuallySpend
        }
        .padding()
        .background(Color.white.opacity(0.8))
        .cornerRadius(10)
        .shadow(color: .gray, radius: 5, x: 0, y: 5)
    }
    
    private var userSubsCount: some View {
        infoRow(label: "Total sub count:", value: "\(userSubsVM.totalSubscriptionCount)", icon: "number")
    }
    
    private var userMonthlySpend: some View {
        infoRow(label: "Monthly spending:", value: String(format: "%.2f", userSubsVM.totalMonthlySpending), icon: "calendar")
    }
    
    private var userAnnuallySpend: some View {
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
    
    private var logOutButton: some View {
        Button(action: logOut) {
            Text("Log Out")
                .frame(width: UIScreen.main.bounds.width * 0.20, height: 20, alignment: .center)
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(8)
                .shadow(color: .gray, radius: 5, x: 0, y: 5)
                .opacity(0.75)
        }
        .padding(.bottom, 25)
    }
    
    
    // MARK: - Functions
    
    private func loadUserData() {
        userDetailVM.getUserFullname()
        userSubsVM.fetchSubscriptionsSummary(userEmail: "emir2@gmail.com")
    }
    
    private func logOut() {
        do {
            try Auth.auth().signOut()
            isUserLoggedIn = false
        } catch let signOutError as NSError {
            feedbackMessage = "Error signing out: \(signOutError.localizedDescription)"
            isFeedbackVisible = true
        }
    }
    
}


#Preview {
    Home(isUserLoggedIn: .constant(true))
}
