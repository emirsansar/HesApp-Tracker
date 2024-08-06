//
//  ToastView.swift
//  HesApp-Tracker
//
//  Created by Emir Sansar on 5.08.2024.
//

import SwiftUI

struct ToastView: View {
    let message: String
    let type: ToastType
    let isShowing: Bool
    
    enum ToastType {
        case success, error
    }
    
    private var backgroundColor: Color {
        switch type {
        case .success:
            return Color.green
        case .error:
            return Color.red
        }
    }
    
    private var textColor: Color {
        Color.white
    }
    
    var body: some View {
        VStack {
            Spacer()
            if isShowing {
                HStack {
                    Text(message)
                        .font(.subheadline)
                        .foregroundColor(textColor)
                        .padding()
                }
                .background(backgroundColor)
                .cornerRadius(8)
                .padding()
                .transition(.opacity)
                .animation(.easeInOut(duration: 2))
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .center)
        .frame(height: 50)
        .padding(.bottom, 20)
    }
    
}
