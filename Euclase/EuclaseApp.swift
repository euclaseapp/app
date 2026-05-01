import SwiftUI

@main
struct EuclaseApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            SettingsView()
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let floatingPanelController = PanelController()

    func applicationDidFinishLaunching(_ notification: Notification) {
        floatingPanelController.start()
    }
}
