import SwiftUI

struct AppSideMenuView: View {
    
    @Binding var showSideMenu: Bool
    @Binding var showingLogoutAlert: Bool
    
    var body: some View {
        
        VStack (alignment: .leading) {
            settingsTitle
            dividerView
            logOutButton
            Spacer()
        }
        .padding()
        .background(Color.grayForGradient)
        .shadow(color: .black.opacity(0.3), radius: 5, x: 5, y: 0)
        
    }
    
    private var settingsTitle: some View {
        Text("Settings")
            .font(.title2)
            .foregroundStyle(Color.black.opacity(0.85))
            .padding(.top, 10)
            .padding(.horizontal)
    }
    
    private var dividerView: some View {
        Divider()
            .frame(width: 120, height: 1)
            .background(Color.black)
            .padding(.bottom, 25)
            .padding(.horizontal,3)
    }
        
    private var logOutButton: some View {
        Button(action: {
            self.showingLogoutAlert = true
            withAnimation {
                showSideMenu.toggle()
            }
        }) {
            HStack {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .foregroundColor(.blue)
                    .font(.headline)
                
                Text("Log Out")
                    .font(.headline)
            }
        }
        .padding(.leading, 10)
    }
    
}
    

#Preview {
    AppSideMenuView(showSideMenu: .constant(true), showingLogoutAlert: .constant(false))
}
