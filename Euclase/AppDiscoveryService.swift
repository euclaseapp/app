import Foundation

struct DiscoveredApp {
    let name: String
    let path: String
}

final class AppDiscoveryService {
    private let fileManager: FileManager
    private let applicationsURL: URL

    init(
        fileManager: FileManager = .default,
        applicationsURL: URL = URL(fileURLWithPath: "/Applications")
    ) {
        self.fileManager = fileManager
        self.applicationsURL = applicationsURL
    }

    func discoverApps() -> [DiscoveredApp] {
        appBundleURLs().compactMap { bundleURL in
            discoveredApp(from: bundleURL)
        }
    }

    private func appBundleURLs() -> [URL] {
        guard let urls = try? fileManager.contentsOfDirectory(
            at: applicationsURL,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else {
            print("Could not read applications directory at \(applicationsURL.path)")
            return []
        }

        return urls.filter { url in
            guard url.pathExtension == "app" else {
                return false
            }

            return (try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true
        }
    }

    private func discoveredApp(from bundleURL: URL) -> DiscoveredApp? {
        let name = appName(from: bundleURL)

        guard !name.isEmpty else {
            return nil
        }

        return DiscoveredApp(name: name, path: bundleURL.path)
    }

    private func appName(from bundleURL: URL) -> String {
        bundleURL.deletingPathExtension().lastPathComponent
    }
}
