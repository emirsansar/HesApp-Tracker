import SwiftUI

struct AuthTabView: View {
    
    @Binding var authTabBarSelection: Int
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        
        VStack(spacing: 0) {
            tabViewDivider
                    
            ZStack {
                TabViewBackground()
                HStack {
                    Spacer()
                    loginButton
                    Spacer()
                    registerButton
                    Spacer()
                }
            }
        }
        
    }

    
    private var loginButton: some View {
        Button(action: {
            authTabBarSelection = 1
        }) {
            VStack {
                Image(systemName: "person.text.rectangle")
                    .foregroundColor(
                        authTabBarSelection == 1
                            ? .blue
                            : (colorScheme == .dark ? .white.opacity(0.8) : .black.opacity(0.8) )
                        )
                Text("tab_log_in")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(
                        authTabBarSelection == 1
                            ? .blue
                            : (colorScheme == .dark ? .white.opacity(0.8) : .black.opacity(0.8) )
                        )

                if authTabBarSelection == 1 {
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
    
    private var registerButton: some View {
        Button(action: {
            authTabBarSelection = 2
        }) {
            VStack {
                Image(systemName: "pencil.line")
                    .foregroundColor(
                            authTabBarSelection == 2
                            ? .blue
                            : (colorScheme == .dark ? .white.opacity(0.8) : .black.opacity(0.8) )
                        )
                Text("tab_register")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(
                            authTabBarSelection == 2
                            ? .blue
                            : (colorScheme == .dark ? .white.opacity(0.8) : .black.opacity(0.8) )
                        )
                
                if authTabBarSelection == 2 {
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
    AuthTabView(authTabBarSelection: .constant(1))
}
