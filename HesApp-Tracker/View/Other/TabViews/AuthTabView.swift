import SwiftUI

struct AuthTabView: View {
    
    @Binding var authTabBarSelection: Int
    
    var body: some View {
        
        ZStack {
            background
            HStack {
                Spacer()
                loginButton
                Spacer()
                registerButton
                Spacer()
            }
        }
        
    }
    
    
    private var background: some View {
        Rectangle()
            .frame(height: 80)
            .foregroundColor(Color(.systemGray4).opacity(0.7))
    }
    
    private var loginButton: some View {
        Button(action: {
            authTabBarSelection = 1
        }) {
            VStack {
                Image(systemName: "person.text.rectangle")
                    .foregroundColor(authTabBarSelection == 1 ? .blue : .gray)
                Text("Log In")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(authTabBarSelection == 1 ? .blue : .gray)

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
                    .foregroundColor(authTabBarSelection == 2 ? .blue : .gray)
                Text("Register")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(authTabBarSelection == 2 ? .blue : .gray)
                
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
    
}


#Preview {
    AuthTabView(authTabBarSelection: .constant(1))
}
