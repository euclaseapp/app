import SwiftUI
import AppKit

struct ContentView: View {
    @State private var query = ""
    @State private var extensions: [Extension] = []
    @State private var apps: [DiscoveredApp] = []

    var body: some View {
        VStack(spacing: 0) {
            TextInputView(query: $query)

            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(filteredSearchItems) { item in
                        Button {
                            run(item: item)
                        } label: {
                            searchItemRow(for: item)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
            }
        }
        .onAppear(perform: loadData)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var allSearchItems: [SearchItem] {
        commandSearchItems() + appSearchItems()
    }

    private var filteredSearchItems: [SearchItem] {
        guard !query.isEmpty else {
            return allSearchItems
        }

        let normalizedQuery = query.lowercased()
        return allSearchItems.filter { item in
            item.title.lowercased().contains(normalizedQuery)
        }
    }

    private func commandSearchItems() -> [SearchItem] {
        extensions.flatMap { discoveredExtension in
            discoveredExtension.commands.map { command in
                SearchItem(
                    id: "command:\(discoveredExtension.id):\(command.name)",
                    title: command.name,
                    kind: .command(extensionID: discoveredExtension.id, commandName: command.name)
                )
            }
        }
    }

    private func appSearchItems() -> [SearchItem] {
        apps.map { app in
            SearchItem(
                id: "app:\(app.path)",
                title: app.name,
                kind: .app(path: app.path)
            )
        }
    }

    private func loadData() {
        extensions = ExtensionDiscoveryService().discoverExtensions()
        apps = AppDiscoveryService().discoverApps()
    }

    private func run(item: SearchItem) {
        switch item.kind {
        case let .command(extensionID, commandName):
            runCommand(extensionID: extensionID, commandName: commandName)
        case let .app(path):
            openApp(path: path)
        }
    }

    @ViewBuilder
    private func searchItemRow(for item: SearchItem) -> some View {
        HStack(spacing: 8) {
            searchItemIcon(for: item)
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.title3)
                    .fontWeight(.medium)
                Text("Lorem ipsum")
                    .font(.caption)
                    .fontWeight(.regular)
                    .foregroundStyle(.secondary.opacity(0.75))
            }
            Spacer(minLength: 0)
        }
        .padding(.all, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.secondary.opacity(0.25))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    @ViewBuilder
    private func searchItemIcon(for item: SearchItem) -> some View {
        switch item.kind {
        case .command:
            Image(systemName: "terminal")
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundStyle(.secondary)
        case let .app(path):
            appIcon(path: path)
        }
    }

    private func appIcon(path: String) -> Image {
        let icon = NSWorkspace.shared.icon(forFile: path)
        icon.size = NSSize(width: 40, height: 40)
        return Image(nsImage: icon)
    }

    private func runCommand(extensionID: String, commandName: String) {
        let commandPath = commandFilePath(extensionID: extensionID, commandName: commandName)

        CommandRunner.run(file: commandPath) { message in
            handleMessage(message)
        }
    }

    private func openApp(path: String) {
        NSWorkspace.shared.open(URL(fileURLWithPath: path))
    }

    private func commandFilePath(extensionID: String, commandName: String) -> String {
        "/Users/rony/.config/euclase/extensions/\(extensionID)/commands/\(commandName).ts"
    }

    private func handleMessage(_ message: String) {
        guard
            let data = message.data(using: .utf8),
            let payload = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let method = payload["method"] as? String,
            method == "print",
            let params = payload["params"]
        else {
            print(message)
            return
        }

        print(params)
    }
}

private struct SearchItem: Identifiable {
    let id: String
    let title: String
    let kind: SearchItemKind
}

private enum SearchItemKind {
    case command(extensionID: String, commandName: String)
    case app(path: String)
}
