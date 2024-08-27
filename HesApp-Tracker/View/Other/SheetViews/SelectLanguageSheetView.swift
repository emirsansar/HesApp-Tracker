import SwiftUI

struct SelectLanguageSheetView: View {
    
    @EnvironmentObject var appState: AppState
    @Binding var defaultLanguage: String
    @State private var newLanguage: String?
    @State private var hasUserSelectedLanguage: Bool = false
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 10) {
            languageRow(language: "tr", languageName: "Türkçe")
            languageRow(language: "en", languageName: "English")
            
            confirmButton
        }
        .padding(.horizontal, 25)
        .presentationDetents([.height(230)])
    }
    
    private func languageRow(language: String, languageName: String) -> some View {
        HStack {
            Image("\(language)_flag")
                .resizable()
                .frame(width: 40, height: 30)
            
            Text(languageName)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
            
            Image(systemName: (hasUserSelectedLanguage ? (newLanguage == language ? "checkmark.square" : "square") : (defaultLanguage == language ? "checkmark.square" : "square")))
                .font(.title2)
                .foregroundColor((hasUserSelectedLanguage ? (newLanguage == language ? .blue : .gray) : (defaultLanguage == language ? .blue : .gray)))
                .onTapGesture {
                    hasUserSelectedLanguage = true
                    newLanguage = language
                }
        }
        .padding()
        .background(Color(.systemGray5))
        .cornerRadius(8)
    }
    
    private var confirmButton: some View {
        Button(action: {
            appState.selectedLanguage = newLanguage!
            dismiss()
        }) {
            Text("button_change")
                .font(.headline)
                .padding()
                .background((newLanguage == nil || newLanguage == defaultLanguage || !hasUserSelectedLanguage) ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
        .disabled(newLanguage == nil || newLanguage == defaultLanguage || !hasUserSelectedLanguage)
        .padding(.top, 5)
    }
}

#Preview {
    SelectLanguageSheetView(defaultLanguage: .constant("tr"))
        .environmentObject(AppState())
}
