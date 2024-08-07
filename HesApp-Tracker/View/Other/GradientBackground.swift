//
//  GradientBackground.swift
//  HesApp-Tracker
//
//  Created by Emir Sansar on 6.08.2024.
//

import SwiftUI

struct GradientBackground: View {
    
    var body: some View {
        
        LinearGradient(gradient: Gradient(colors: [Color(.mainBlue).opacity(0.90), Color(.grayForGradient)]), startPoint: .center, endPoint: .bottom)
            .edgesIgnoringSafeArea(.all)
        
    }
    
}

#Preview {
    GradientBackground()
}
