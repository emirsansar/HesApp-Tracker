import SwiftUI

struct FeedbackSheetView: View {
    
    @Binding var showFeedbackSheet: Bool
    @Binding var feedbackText: String
    @Binding var errorOccured: Bool
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        VStack(spacing: 20) {
            Text(errorOccured ? "Error" : "Success")
                .font(.title2)
                .foregroundColor(errorOccured ? .red : .green)
            
            Text(errorOccured ? feedbackText : "Plan has been added successfully.")
                .font(.body)
                .multilineTextAlignment(.center)
            
            Button("OK") {
                showFeedbackSheet = false
                if !errorOccured {
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
        feedbackText: $feedbackMessage,
        errorOccured: $isAddError
    )
    
}
