import SwiftUI

@main
struct EuclaseApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            SettingsView()
                .environmentObject(appDelegate.registry)
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    let registry = ExtensionRegistry()
    private lazy var floatingPanelController = PanelController(registry: registry)

    func applicationDidFinishLaunching(_ notification: Notification) {
        registry.reloadFromDisk()
        floatingPanelController.start()
    }
}
