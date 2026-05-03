import SwiftUI

struct TextInputView: View {
    @Binding var query: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .frame(width: 24, height: 24)
                .font(.title3)
                .foregroundStyle(.secondary)
            TextField("Search for apps and commands...", text: $query)
                .textFieldStyle(.plain)
                .font(.title3)
            }
        .padding()
    }
}
