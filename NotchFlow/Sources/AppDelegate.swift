import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {

    var notchPanel: NotchPanel?
    let viewModel = NotchViewModel()

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        setupNotchPanel()
    }

    private func setupNotchPanel() {
        let screen = NSScreen.screens.first(where: { $0.safeAreaInsets.top > 0 }) ?? NSScreen.main
        guard let screen = screen else { return }

        let panelWidth = viewModel.maxPanelWidth
        let panelHeight = viewModel.maxPanelHeight
        let panelX = screen.frame.origin.x + (screen.frame.width / 2) - (panelWidth / 2)
        let panelY = screen.frame.origin.y + screen.frame.height - panelHeight

        let panel = NotchPanel(
            contentRect: NSRect(x: panelX, y: panelY, width: panelWidth, height: panelHeight),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        let rootView = NotchRootView(viewModel: viewModel)
        let hostingView = NSHostingView(rootView: rootView)
        hostingView.frame = NSRect(origin: .zero, size: NSSize(width: panelWidth, height: panelHeight))
        panel.contentView = hostingView
        panel.setFrameOrigin(NSPoint(x: panelX, y: panelY))
        panel.orderFrontRegardless()

        self.notchPanel = panel
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }
}
