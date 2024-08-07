//
//  FeedbackSheetView.swift
//  HesApp-Tracker
//
//  Created by Emir Sansar on 6.08.2024.
//

import SwiftUI

struct FeedbackSheetView: View {
    
    @Binding var showFeedbackSheet: Bool
    @Binding var feedbackMessage: String
    @Binding var isAddError: Bool
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        VStack(spacing: 20) {
            Text(isAddError ? "Error" : "Success")
                .font(.title2)
                .foregroundColor(isAddError ? .red : .green)
            
            Text(isAddError ? feedbackMessage : "Plan has been added successfully.")
                .font(.body)
                .multilineTextAlignment(.center)
            
            Button("OK") {
                showFeedbackSheet = false
                if !isAddError {
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .padding()
        }
        .padding(.horizontal, 40)
        .presentationDetents([.height(170)])
        
    }
    
}

#Preview {
    
    @State var showFeedbackSheet = true
    @State var feedbackMessage = "An error occurred"
    @State var isAddError = true
    
    return FeedbackSheetView(
        showFeedbackSheet: $showFeedbackSheet,
        feedbackMessage: $feedbackMessage,
        isAddError: $isAddError
    )
    
}
