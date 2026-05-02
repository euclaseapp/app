import AppKit
import Carbon
import SwiftUI

final class FloatingPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
}

final class PanelController {
    private let panel: FloatingPanel
    private let registry: ExtensionRegistry
    private let hotKeyMonitor = GlobalHotKeyMonitor()

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

    deinit {
        hotKeyMonitor.stop()
    }

    func start() {
        let didStart = hotKeyMonitor.start(
            keyCode: UInt32(kVK_Space),
            modifiers: UInt32(optionKey | cmdKey)
        ) { [weak self] in
            self?.toggle()
        }

        #if DEBUG
        if !didStart {
            print("Panel hotkey monitor failed to start")
        }
        #endif
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
