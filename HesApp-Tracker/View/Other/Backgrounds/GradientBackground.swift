import SwiftUI

struct GradientBackground: View {
    
    var body: some View {
        LinearGradient(
            gradient: Gradient(
                colors: [Color(.mainBlue).opacity(0.90), Color(.systemGray4)]),
                startPoint: .center, endPoint: .bottom
        )
        .edgesIgnoringSafeArea(.all)
    }
    
}

#Preview {
    GradientBackground()
}
