import SwiftUI

struct AppMainView: View {

    @State var appMainTabBarSelection: Int = 1
    
    var body: some View {
        VStack {
            switch appMainTabBarSelection {
            case 1:
                HomeView()
            case 2:
                ServicesView()
            case 3:
                UserSubscriptionsView()
            default:
                HomeView()
            }
            
            AppMainTabView(appMainTabBarSelection: $appMainTabBarSelection)
                .padding(.top, -10)
        }
        .edgesIgnoringSafeArea(.bottom)
    }
    
}


#Preview {
    AppMainView()
}
