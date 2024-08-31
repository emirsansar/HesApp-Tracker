import SwiftUI

struct GradientBackground: View {
    
    var body: some View {
        LinearGradient(
            gradient: Gradient(
                colors: [Color(.mainBlue), Color(.systemGray4)]),
                startPoint: .center, endPoint: .bottom
        )
        .edgesIgnoringSafeArea(.all)
    }
    
}

#Preview {
    GradientBackground()
}
