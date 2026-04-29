import SwiftUI

@main
struct EuclaseApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let floatingPanelController = FloatingPanelController()

    func applicationDidFinishLaunching(_ notification: Notification) {
        floatingPanelController.start()
    }
}
