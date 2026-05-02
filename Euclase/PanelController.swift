import AppKit
import KeyboardShortcuts
import SwiftUI

extension KeyboardShortcuts.Name {
    static let togglePanel = Self(
        "togglePanel",
        default: .init(.space, modifiers: [.option])
    )
}

final class FloatingPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
}

final class PanelController {
    private let panel: FloatingPanel
    private let registry: ExtensionRegistry

    init(registry: ExtensionRegistry) {
        self.registry = registry

        panel = FloatingPanel(
            contentRect: NSRect(x: 0, y: 0, width: 550, height: 360),
            styleMask: [.nonactivatingPanel, .borderless],
            backing: .buffered,
            defer: false
        )

        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.isFloatingPanel = true
        panel.level = .mainMenu
        panel.animationBehavior = .none
        panel.hidesOnDeactivate = false
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .transient]
        panel.center()

        let hostingView = NSHostingView(rootView: ContentView().environmentObject(registry))
        panel.contentView = hostingView
    }

    func start() {
        KeyboardShortcuts.onKeyUp(for: .togglePanel) { [weak self] in
            self?.toggle()
        }
    }

    private func toggle() {
        panel.isVisible ? hidePanel() : showPanel()
    }

    private func showPanel() {
        panel.orderFront(nil)
    }

    private func hidePanel() {
        panel.orderOut(nil)
    }
}
