import SwiftUI

struct AppMainTabView: View {
    
    @Binding var appMainTabBarSelection: Int
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        
        VStack(spacing: 0) {
            tabViewDivider
            
            ZStack{
                TabViewBackground()
                HStack{
                    homeButton
                    Spacer()
                    servicesButton
                    Spacer()
                    userSubscriptionsButton
                }
            }
        }
       
    }
    
    
    private var homeButton: some View {
        Button(action: {
            appMainTabBarSelection = 1
        }) {
            VStack {
                Image(systemName: "house")
                    .foregroundColor(
                            appMainTabBarSelection == 1
                            ? .blue
                            : (colorScheme == .dark ? .white.opacity(0.8) : .black.opacity(0.8) )
                        )
                Text("tab_home")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(
                            appMainTabBarSelection == 1
                            ? .blue
                            : (colorScheme == .dark ? .white.opacity(0.8) : .black.opacity(0.8) )
                        )

                if appMainTabBarSelection == 1 {
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(.blue)
                        .padding(.top, 2)
                } else {
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(.clear)
                        .padding(.top, 2)
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
    }
    
    private var servicesButton: some View {
        Button(action: {
            appMainTabBarSelection = 2
        }) {
            VStack {
                Image(systemName: "list.bullet")
                    .foregroundColor(
                            appMainTabBarSelection == 2
                            ? .blue
                            : (colorScheme == .dark ? .white.opacity(0.8) : .black.opacity(0.8) )
                        )
                Text("tab_services")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(
                            appMainTabBarSelection == 2
                            ? .blue
                            : (colorScheme == .dark ? .white.opacity(0.8) : .black.opacity(0.8) )
                        )

                if appMainTabBarSelection == 2 {
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(.blue)
                        .padding(.top, 2)
                } else {
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(.clear)
                        .padding(.top, 2)
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
    }
    
    private var userSubscriptionsButton: some View {
        Button(action: {
            appMainTabBarSelection = 3
        }) {
            VStack {
                Image(systemName: "person")
                    .foregroundColor(
                            appMainTabBarSelection == 3
                            ? .blue
                            : (colorScheme == .dark ? .white.opacity(0.8) : .black.opacity(0.8) )
                        )
                Text("tab_subscriptions")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(
                            appMainTabBarSelection == 3
                            ? .blue
                            : (colorScheme == .dark ? .white.opacity(0.8) : .black.opacity(0.8) )
                        )
                if appMainTabBarSelection == 3 {
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(.blue)
                        .padding(.top, 2)
                } else {
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(.clear)
                        .padding(.top, 2)
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
    }
    
    private var tabViewDivider: some View {
        Divider()
            .frame(height: 0.1)
            .background(.black)
    }
    
}

#Preview {
    AppMainTabView(appMainTabBarSelection: .constant(1))
}
