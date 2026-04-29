import SwiftUI

struct MainInputView: View {
    @Binding var text: String
    let iconSystemName: String
    let placeholder: String

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: iconSystemName)
                .font(.title3)
                .foregroundStyle(.secondary)
                .scaledToFit()
                .frame(width: 20, height: 16, alignment: .center)
            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
                .font(.title3)
        }
        .padding()
    }
}
