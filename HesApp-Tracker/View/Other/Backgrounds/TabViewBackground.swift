import SwiftUI

struct TabViewBackground: View {
    
    var body: some View {
        
        Rectangle()
            .frame(height: 90)
            .foregroundColor(Color(.systemGray4).opacity(0.7))
        
    }
    
}

#Preview {
    TabViewBackground()
}
