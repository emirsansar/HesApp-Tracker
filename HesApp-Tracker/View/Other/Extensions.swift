import Foundation
import SwiftUI

extension View {
    
    func errorFeedbackTextStyle() -> some View {
        self.font(.body)
            .background(Color.red.opacity(0.60))
            .foregroundColor(.black.opacity(0.9))
            .cornerRadius(8)
            .padding(.bottom, 10)
            .transition(.opacity)
    }
    
    func successFeedbackTextStyle() -> some View {
        self.font(.body)
            .foregroundColor(.black.opacity(0.9))
            .multilineTextAlignment(.center)
            .padding()
            .background(Color.green.opacity(0.60))
            .cornerRadius(8)
    }
    
    func textFieldStyle() -> some View {
        self.padding()
            .background()
            .cornerRadius(8)
            .shadow(radius: 5)
            .autocapitalization(.none)
            .frame(width: UIScreen.main.bounds.width*0.85)
    }
    
    func smallTextFieldStyle() -> some View {
        self.padding()
            .background()
            .cornerRadius(8)
            .shadow(radius: 5)
            .autocapitalization(.none)
    }
    
    func buttonStyle() -> some View {
        self.padding()
            .background(.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            .font(.headline)
            .shadow(color: .blue.opacity(0.3), radius: 5)
    }
    
    func labelStyle() -> some View {
        self.font(.headline)
            .padding(.bottom, 2)
            .padding(.leading, 16)
    }
    
}

