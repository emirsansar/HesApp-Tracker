import SwiftUI

struct FeedbackSheetView: View {
    
    @Binding var feedbackText: String
    @Binding var errorOccured: Bool
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text(errorOccured ? "label_error" : "label_success")
                .font(.title2)
                .foregroundColor(errorOccured ? .red : .green)
            
            Text(feedbackText)
                .font(.body)
                .multilineTextAlignment(.center)
            
            Button("button_ok") {
                dismiss()
            }
            .padding()
        }
        .padding(.horizontal, 40)
        .presentationDetents([.height(170)])
    }
    
}


#Preview {
    
    @State var feedbackMessage = "An error occurred"
    @State var isAddError = true
    
    return FeedbackSheetView(
        feedbackText: $feedbackMessage,
        errorOccured: $isAddError
    )
    
}
