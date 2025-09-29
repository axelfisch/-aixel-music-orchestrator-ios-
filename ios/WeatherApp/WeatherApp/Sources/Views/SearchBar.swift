import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    var isLoading: Bool
    var onSearch: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            TextField("Rechercher une ville", text: $text)
                .textInputAutocapitalization(.words)
                .disableAutocorrection(true)
                .submitLabel(.search)
                .onSubmit { onSearch() }
            if isLoading {
                ProgressView().progressViewStyle(.circular)
            } else if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill").foregroundColor(.secondary)
                }
            }
            Button(action: onSearch) {
                Text("Chercher")
            }
            .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(10)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .padding(.horizontal)
    }
}

struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        SearchBar(text: .constant("Paris"), isLoading: false, onSearch: {})
            .previewLayout(.sizeThatFits)
            .padding()
    }
}

