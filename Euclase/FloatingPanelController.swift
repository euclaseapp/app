import AppKit
import KeyboardShortcuts
import SwiftUI

extension KeyboardShortcuts.Name {
    static let toggleFloatingPanel = Self(
        "toggleFloatingPanel",
        default: .init(.space, modifiers: [.option, .command])
    )
}

final class FloatingPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
}

final class FloatingPanelController {
    private let panel: FloatingPanel

    init() {
        panel = FloatingPanel(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 320),
            styleMask: [.nonactivatingPanel, .borderless],
            backing: .buffered,
            defer: false
        )

        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.isFloatingPanel = true
        panel.level = .mainMenu
        panel.animationBehavior = .documentWindow
        panel.hidesOnDeactivate = false
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .transient]
        panel.center()

        let hostingView = NSHostingView(rootView: ContentView())
        panel.contentView = hostingView
    }

    func start() {
        KeyboardShortcuts.onKeyUp(for: .toggleFloatingPanel) { [weak self] in
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
