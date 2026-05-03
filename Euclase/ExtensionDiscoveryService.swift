import Foundation

struct Extension {
    let id: String
    let path: String
    let description: String
    let commands: [Command]
}

struct Command {
    let name: String
}

final class ExtensionDiscoveryService {
    private let fileManager: FileManager
    private let extensionsRootURL: URL

    init(
        fileManager: FileManager = .default,
        extensionsRootURL: URL = URL(fileURLWithPath: "/Users/rony/.config/euclase/extensions")
    ) {
        self.fileManager = fileManager
        self.extensionsRootURL = extensionsRootURL
    }

    func discoverExtensions() -> [Extension] {
        var discoveredExtensions: [Extension] = []

        for directoryURL in extensionDirectoryURLs() {
            guard let package = loadPackageJSON(at: directoryURL) else {
                print("Skipping extension at \(directoryURL.path): invalid or missing package.json")
                continue
            }

            let metadata = extractExtensionMetadata(from: package)
            let extensionPath = buildExtensionPath(forExtensionID: metadata.id)
            let commands = discoverCommands(in: directoryURL)

            discoveredExtensions.append(
                Extension(
                    id: metadata.id,
                    path: extensionPath,
                    description: metadata.description,
                    commands: commands
                )
            )
        }

        return discoveredExtensions
    }

    private func extensionDirectoryURLs() -> [URL] {
        guard let urls = try? fileManager.contentsOfDirectory(
            at: extensionsRootURL,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else {
            print("Could not read extensions directory at \(extensionsRootURL.path)")
            return []
        }

        return urls.filter { url in
            (try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true
        }
    }

    private func loadPackageJSON(at extensionDirectoryURL: URL) -> ExtensionPackageJSON? {
        let packageURL = extensionDirectoryURL.appendingPathComponent("package.json")

        guard fileManager.fileExists(atPath: packageURL.path) else {
            return nil
        }

        guard let data = try? Data(contentsOf: packageURL) else {
            return nil
        }

        return try? JSONDecoder().decode(ExtensionPackageJSON.self, from: data)
    }

    private func extractExtensionMetadata(from package: ExtensionPackageJSON) -> (id: String, description: String) {
        let description = package.description ?? ""
        return (id: package.name, description: description)
    }

    private func discoverCommands(in extensionDirectoryURL: URL) -> [Command] {
        let commandsDirectoryURL = extensionDirectoryURL.appendingPathComponent("commands", isDirectory: true)

        guard fileManager.fileExists(atPath: commandsDirectoryURL.path) else {
            print("Extension at \(extensionDirectoryURL.path) has no commands directory")
            return []
        }

        guard let commandFileURLs = try? fileManager.contentsOfDirectory(
            at: commandsDirectoryURL,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        ) else {
            print("Could not read commands at \(commandsDirectoryURL.path)")
            return []
        }

        return commandFileURLs
            .filter { $0.pathExtension == "ts" }
            .compactMap { commandFileURL in
                guard let name = commandName(from: commandFileURL) else {
                    return nil
                }
                return Command(name: name)
            }
            .sorted { $0.name < $1.name }
    }

    private func commandName(from commandFileURL: URL) -> String? {
        let name = commandFileURL.deletingPathExtension().lastPathComponent
        return name.isEmpty ? nil : name
    }

    private func buildExtensionPath(forExtensionID extensionID: String) -> String {
        "\(extensionsRootURL.path)/\(extensionID)"
    }
}

private struct ExtensionPackageJSON: Decodable {
    let name: String
    let description: String?
}
