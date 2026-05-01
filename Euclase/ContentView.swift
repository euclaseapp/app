import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var inputText = ""

    var body: some View {
        VStack(spacing: 0) {
            MainInputView(
                text: $inputText,
                iconSystemName: "magnifyingglass",
                placeholder: "Search for apps and commands..."
            )
            
            ScrollView(showsIndicators: false) {
                LazyVStack(alignment: .leading, spacing: 0) {
                    CommandItemView(selected: true, title: "Euclase", description: "~/Documents/Euclase", starred: true)
                    CommandItemView(selected: false, title: "Euclase", description: "~/Documents/Euclase", starred: false)
                    CommandItemView(selected: false, title: "Euclase", description: "~/Documents/Euclase", starred: false)
                    CommandItemView(selected: false, title: "Euclase", description: "~/Documents/Euclase", starred: false)
                    CommandItemView(selected: false, title: "Euclase", description: "~/Documents/Euclase", starred: false)
                    CommandItemView(selected: false, title: "Euclase", description: "~/Documents/Euclase", starred: false)
                    CommandItemView(selected: false, title: "Euclase", description: "~/Documents/Euclase", starred: false)
                    CommandItemView(selected: false, title: "Euclase", description: "~/Documents/Euclase", starred: false)
                    CommandItemView(selected: false, title: "Euclase", description: "~/Documents/Euclase", starred: false)
                    CommandItemView(selected: false, title: "Euclase", description: "~/Documents/Euclase", starred: false)
                    CommandItemView(selected: false, title: "Euclase", description: "~/Documents/Euclase", starred: false)
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .onAppear {
            Temporary.bootstrap(in: modelContext)
        }
    }
}
