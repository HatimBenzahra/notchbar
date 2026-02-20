import SwiftUI
import AppKit

enum NotchState {
    case compact
    case expanded
}

final class NotchViewModel: ObservableObject {

    @Published var state: NotchState = .compact
    @Published var contentWidth: CGFloat = 0
    @Published var contentHeight: CGFloat = 0

    private var collapseTimer: Timer?

    let openAnimation: Animation = .spring(.bouncy(duration: 0.4))
    let closeAnimation: Animation = .smooth(duration: 0.4)

    private static let expandedPadding: CGFloat = 40

    var compactWidth: CGFloat {
        let screen = NSScreen.screens.first(where: { $0.safeAreaInsets.top > 0 })
        guard let screen = screen,
              let leftPadding = screen.auxiliaryTopLeftArea?.width,
              let rightPadding = screen.auxiliaryTopRightArea?.width else {
            return 200
        }
        return screen.frame.width - leftPadding - rightPadding + 4
    }

    var compactHeight: CGFloat {
        let screen = NSScreen.screens.first(where: { $0.safeAreaInsets.top > 0 })
        guard let screen = screen else { return 37 }
        return screen.safeAreaInsets.top > 0 ? screen.safeAreaInsets.top : 37
    }

    var expandedWidth: CGFloat {
        let minWidth = compactWidth + 60
        let contentBased = contentWidth + Self.expandedPadding * 2
        return max(minWidth, contentBased)
    }

    var expandedHeight: CGFloat {
        let minHeight = compactHeight + 60
        let contentBased = contentHeight + compactHeight + Self.expandedPadding
        return max(minHeight, contentBased)
    }

    var maxPanelWidth: CGFloat {
        let screen = NSScreen.screens.first(where: { $0.safeAreaInsets.top > 0 }) ?? NSScreen.main
        return screen?.frame.width ?? 1440
    }

    var maxPanelHeight: CGFloat { 600 }

    var currentWidth: CGFloat {
        state == .compact ? compactWidth : expandedWidth
    }

    var currentHeight: CGFloat {
        state == .compact ? compactHeight : expandedHeight
    }

    func updateContentSize(_ size: CGSize) {
        if abs(contentWidth - size.width) > 1 {
            contentWidth = size.width
        }
        if abs(contentHeight - size.height) > 1 {
            contentHeight = size.height
        }
    }

    func expand() {
        collapseTimer?.invalidate()
        collapseTimer = nil
        guard state == .compact else { return }
        state = .expanded
    }

    func scheduleCollapse() {
        collapseTimer?.invalidate()
        collapseTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
            guard let self = self, self.state == .expanded else { return }
            self.state = .compact
        }
    }

    func cancelCollapse() {
        collapseTimer?.invalidate()
        collapseTimer = nil
    }
}
