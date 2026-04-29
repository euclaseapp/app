import SwiftUI

struct CommandItemView: View {
    let selected: Bool
    let title: String
    let description: String
    let starred: Bool

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: "folder.fill")
                .font(.largeTitle)
                .frame(width: 36, height: 36)
                .foregroundStyle(.red)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.medium)
                Text(description)
                    .font(.caption)
                    .fontWeight(.regular)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if starred {
                Image(systemName: "star.fill")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .scaledToFit()
                    .frame(width: 20, height: 16, alignment: .center)
            }
        }
        .padding(.all, 8)
        .background(selected ? .secondary.opacity(0.25) : Color.clear, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
