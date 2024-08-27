import SwiftUI

struct FeedbackSheetView: View {
    
    @Binding var showFeedbackSheet: Bool
    @Binding var feedbackText: String
    @Binding var errorOccured: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Text(errorOccured ? "label_error" : "label_success")
                .font(.title2)
                .foregroundColor(errorOccured ? .red : .green)
            
            Text(feedbackText)
                .font(.body)
                .multilineTextAlignment(.center)
            
            Button("button_ok") {
                showFeedbackSheet = false
            }
            .padding()
        }
        .padding(.horizontal, 40)
        .presentationDetents([.height(185)])
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
