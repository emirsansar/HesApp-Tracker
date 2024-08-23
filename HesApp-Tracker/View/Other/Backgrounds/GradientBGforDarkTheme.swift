import SwiftUI

struct GradientBGforDarkTheme: View {
    
    var body: some View {
        LinearGradient(
            gradient: Gradient(
                colors: [Color(.mainBlue), Color(.systemGray6)]), 
                startPoint: .center, endPoint: .bottom
        ).edgesIgnoringSafeArea(.all)
    }
    
}

#Preview {
    GradientBGforDarkTheme()
}
