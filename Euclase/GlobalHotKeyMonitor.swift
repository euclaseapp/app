import Carbon
import Foundation

final class GlobalHotKeyMonitor {
    private static let hotKeySignature = OSType(0x4555434C) // "EUCL"
    private static let hotKeyIdentifier: UInt32 = 1

    private var eventHandlerRef: EventHandlerRef?
    private var hotKeyRef: EventHotKeyRef?
    private var handler: (() -> Void)?
    private let expectedHotKeyID = EventHotKeyID(
        signature: hotKeySignature,
        id: hotKeyIdentifier
    )

    func start(keyCode: UInt32, modifiers: UInt32, handler: @escaping () -> Void) -> Bool {
        stop()
        self.handler = handler

        var eventSpec = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        let eventHandlerStatus = InstallEventHandler(
            GetEventDispatcherTarget(),
            { _, event, userData in
                guard
                    let userData,
                    let event
                else { return noErr }

                let monitor = Unmanaged<GlobalHotKeyMonitor>
                    .fromOpaque(userData)
                    .takeUnretainedValue()
                monitor.handleHotKeyEvent(event)
                return noErr
            },
            1,
            &eventSpec,
            Unmanaged.passUnretained(self).toOpaque(),
            &eventHandlerRef
        )

        guard eventHandlerStatus == noErr else {
            #if DEBUG
            print("Global hotkey handler install failed: \(eventHandlerStatus)")
            #endif
            stop()
            return false
        }

        let registerStatus = RegisterEventHotKey(
            keyCode,
            modifiers,
            expectedHotKeyID,
            GetEventDispatcherTarget(),
            0,
            &hotKeyRef
        )

        guard registerStatus == noErr else {
            #if DEBUG
            print("Global hotkey registration failed: \(registerStatus)")
            #endif
            stop()
            return false
        }

        #if DEBUG
        print("Global hotkey registered")
        #endif
        return true
    }

    func stop() {
        if let hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }

        if let eventHandlerRef {
            RemoveEventHandler(eventHandlerRef)
            self.eventHandlerRef = nil
        }

        handler = nil
    }

    deinit {
        stop()
    }

    private func handleHotKeyEvent(_ event: EventRef) {
        var hotKeyID = EventHotKeyID()
        let status = withUnsafeMutablePointer(to: &hotKeyID) { pointer in
            GetEventParameter(
                event,
                EventParamName(kEventParamDirectObject),
                EventParamType(typeEventHotKeyID),
                nil,
                MemoryLayout<EventHotKeyID>.size,
                nil,
                pointer
            )
        }

        guard
            status == noErr,
            hotKeyID.signature == expectedHotKeyID.signature,
            hotKeyID.id == expectedHotKeyID.id
        else { return }

        if Thread.isMainThread {
            handler?()
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.handler?()
            }
        }
    }
}
