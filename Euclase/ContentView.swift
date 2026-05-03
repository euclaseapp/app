import SwiftUI

struct ContentView: View {
    @State private var extensions: [Extension] = []

    var body: some View {
        VStack {
            TextInputView()

            ForEach(discoveredCommands) { discoveredCommand in
                Button(discoveredCommand.commandName) {
                    run(discoveredCommand: discoveredCommand)
                }
            }
        }
        .onAppear(perform: loadExtensions)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var discoveredCommands: [DiscoveredCommand] {
        extensions.flatMap { discoveredExtension in
            discoveredExtension.commands.map { command in
                DiscoveredCommand(extensionID: discoveredExtension.id, commandName: command.name)
            }
        }
    }

    private func loadExtensions() {
        extensions = ExtensionDiscoveryService().discoverExtensions()
    }

    private func run(discoveredCommand: DiscoveredCommand) {
        let commandPath = commandFilePath(
            extensionID: discoveredCommand.extensionID,
            commandName: discoveredCommand.commandName
        )

        CommandRunner.run(file: commandPath) { message in
            handleMessage(message)
        }
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

private struct DiscoveredCommand: Identifiable {
    let extensionID: String
    let commandName: String

    var id: String {
        "\(extensionID):\(commandName)"
    }
}
