import Foundation
import JavaScriptCore
import Combine

struct ExtensionManifest: Decodable {
    let name: String
    let version: String
    let description: String?
    let author: String?
    let icon: String?
}

struct ExtensionCommand: Identifiable {
    let id: String
    let extensionName: String
    let commandID: String
    let description: String
    let scriptURL: URL

    var scriptPath: String { scriptURL.path }
}

struct ExtensionRecord: Identifiable {
    let id: String
    let manifest: ExtensionManifest
    let commands: [ExtensionCommand]
}

struct CommandMetadata {
    let description: String?
}

@MainActor
final class ExtensionRegistry: ObservableObject {
    @Published private(set) var extensions: [ExtensionRecord] = []
    @Published private(set) var commands: [ExtensionCommand] = []

    func reloadFromDisk() {
        let discovered = ExtensionLoader.discoverExtensions()
        extensions = discovered.sorted { $0.manifest.name.localizedCaseInsensitiveCompare($1.manifest.name) == .orderedAscending }
        commands = discovered
            .flatMap(\.commands)
            .sorted { $0.commandID.localizedCaseInsensitiveCompare($1.commandID) == .orderedAscending }
        
//        print("all commands: \(commands)")
    }
}

enum ExtensionLoader {
    static func discoverExtensions() -> [ExtensionRecord] {
        let rootURL = extensionRootURL()
        createDirectoryIfNeeded(at: rootURL)

        let fileManager = FileManager.default
        guard let folderURLs = try? fileManager.contentsOfDirectory(
            at: rootURL,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }

        return folderURLs.compactMap { folderURL in
            guard isDirectory(folderURL) else { return nil }
            let extensionName = folderURL.lastPathComponent
            let manifestURL = folderURL.appendingPathComponent("manifest.json")
            let commandsURL = folderURL.appendingPathComponent("commands", isDirectory: true)

            guard
                let manifestData = try? Data(contentsOf: manifestURL),
                let manifest = try? JSONDecoder().decode(ExtensionManifest.self, from: manifestData)
            else {
                // TODO: Surface invalid/missing manifest errors in Settings.
                return nil
            }

            let commands = loadCommands(from: commandsURL, extensionName: extensionName)
            return ExtensionRecord(
                id: extensionName,
                manifest: manifest,
                commands: commands
            )
        }
    }

    static func extensionRootURL() -> URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
        let baseURL = appSupport ?? URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Library/Application Support", isDirectory: true)
        return baseURL
            .appendingPathComponent("Euclase", isDirectory: true)
            .appendingPathComponent("extensions", isDirectory: true)
    }

    private static func loadCommands(from commandsURL: URL, extensionName: String) -> [ExtensionCommand] {
        let fileManager = FileManager.default
        guard let fileURLs = try? fileManager.contentsOfDirectory(
            at: commandsURL,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }

        return fileURLs
            .filter { $0.pathExtension == "js" }
            .sorted { $0.lastPathComponent.localizedCaseInsensitiveCompare($1.lastPathComponent) == .orderedAscending }
            .map { fileURL in
                let commandID = fileURL.deletingPathExtension().lastPathComponent
                let source = (try? String(contentsOf: fileURL, encoding: .utf8)) ?? ""
                let metadata = parseMetadata(from: source)
                return ExtensionCommand(
                    id: "\(extensionName).\(commandID)",
                    extensionName: extensionName,
                    commandID: commandID,
                    description: metadata.description ?? "",
                    scriptURL: fileURL
                )
            }
    }

    private static func parseMetadata(from source: String) -> CommandMetadata {
        let pattern = #"const\s+metadata\s*=\s*(\{[\s\S]*?\})\s*;?"#
        guard
            let regex = try? NSRegularExpression(pattern: pattern),
            let match = regex.firstMatch(in: source, range: NSRange(source.startIndex..., in: source)),
            let objectRange = Range(match.range(at: 1), in: source)
        else {
            return CommandMetadata(description: nil)
        }

        let objectLiteral = String(source[objectRange])
        let context = JSContext()
        let script = "(\(objectLiteral))"
        guard let value = context?.evaluateScript(script) else {
            return CommandMetadata(description: nil)
        }

        return CommandMetadata(
            description: value.forProperty("description")?.toString()
        )
    }

    private static func isDirectory(_ url: URL) -> Bool {
        (try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true
    }

    private static func createDirectoryIfNeeded(at url: URL) {
        if FileManager.default.fileExists(atPath: url.path) { return }
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }
}
