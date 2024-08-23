import SwiftUI

struct TabViewBackground: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Rectangle()
            .frame(height: 90)
            .foregroundColor(colorScheme == .dark ? Color(.systemGray6) : Color(.systemGray4))
    }
    
    
}

#Preview {
    TabViewBackground()
}
