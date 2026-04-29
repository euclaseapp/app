import AppKit
import KeyboardShortcuts
import SwiftData
import SwiftUI

extension KeyboardShortcuts.Name {
    static let togglePanel = Self(
        "togglePanel",
        default: .init(.space, modifiers: [.option, .command])
    )
}

final class FloatingPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
}

final class PanelController {
    private let panel: FloatingPanel
    private let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try ModelContainer(for: ItemRecord.self)
        } catch {
            fatalError("Failed to create SwiftData container: \(error)")
        }

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

        let hostingView = NSHostingView(rootView: ContentView().modelContainer(modelContainer))
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
