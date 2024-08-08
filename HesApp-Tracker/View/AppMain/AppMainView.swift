import SwiftUI

struct AppMainView: View {
    
    @Binding var isUserLoggedIn: Bool
    
    @State var appMainTabBarSelection: Int = 1
    
    var body: some View {
        
        VStack {
            switch appMainTabBarSelection {
            case 1:
                Home(isUserLoggedIn: $isUserLoggedIn)
            case 2:
                Services()
            case 3:
                UsersSubscriptions()
            default:
                Home(isUserLoggedIn: $isUserLoggedIn)
            }
            
            AppMainTabView(appMainTabBarSelection: $appMainTabBarSelection)
                .foregroundColor(Color(.systemGray4).opacity(0.7))
                .padding(.top, -10)
        }
        .edgesIgnoringSafeArea(.bottom)
        
    }
}


#Preview {
    AppMainView(isUserLoggedIn: .constant(true))
}
