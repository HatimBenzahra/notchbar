import SwiftUI

struct NotchRootView: View {

    @ObservedObject var viewModel: NotchViewModel
    @State private var currentTime = Date()

    private let timeTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack(alignment: .top) {
            NotchShape(state: viewModel.state)
                .fill(Color.black)
                .frame(
                    width: viewModel.currentWidth,
                    height: viewModel.currentHeight
                )
                .overlay { notchContent }
                .clipped()
                .onHover { hovering in
                    if hovering {
                        viewModel.cancelCollapse()
                        viewModel.expand()
                    } else {
                        viewModel.scheduleCollapse()
                    }
                }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .animation(
            viewModel.state == .expanded ? viewModel.openAnimation : viewModel.closeAnimation,
            value: viewModel.state
        )
        .onReceive(timeTimer) { currentTime = $0 }
    }

    @ViewBuilder
    private var notchContent: some View {
        if viewModel.state == .expanded {
            expandedContent
                .transition(.opacity.combined(with: .scale(scale: 0.97)))
        } else {
            compactContent
                .transition(.opacity)
        }
    }

    private var compactContent: some View {
        HStack {
            Spacer()
            CompactClockView(
                themeManager: viewModel.themeManager,
                currentTime: currentTime
            )
            Spacer()
        }
        .frame(height: viewModel.compactHeight)
    }

    private var expandedContent: some View {
        ZStack {
            VStack(spacing: 0) {
                Spacer().frame(height: viewModel.compactHeight + 10)

                Spacer()

                if viewModel.showSettings {
                    SettingsView(
                        themeManager: viewModel.themeManager,
                        showSettings: $viewModel.showSettings
                    )
                    .transition(.opacity.combined(with: .scale(scale: 0.97)))
                } else {
                    VStack(spacing: 4) {
                        ExpandedClockView(
                            themeManager: viewModel.themeManager,
                            currentTime: currentTime
                        )

                        SpiderView(crawlWidth: viewModel.currentWidth * 0.35)
                            .opacity(0.85)
                    }
                    .transition(.opacity.combined(with: .scale(scale: 0.97)))
                }

                Spacer().frame(minHeight: 24)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 44)

            VStack {
                HStack {
                    Spacer()
                    SettingsToggleButton(
                        showSettings: $viewModel.showSettings,
                        themeManager: viewModel.themeManager
                    )
                }
                .padding(.top, viewModel.compactHeight + 4)
                .padding(.horizontal, 50)

                Spacer()
            }
        }
        .onPreferenceChange(ClockContentSizeKey.self) { size in
            viewModel.updateContentSize(size)
        }
        .animation(.easeInOut(duration: 0.25), value: viewModel.showSettings)
    }
}

#if DEBUG
struct NotchRootView_Previews: PreviewProvider {
    static var previews: some View {
        NotchRootView(viewModel: NotchViewModel())
            .frame(width: 500, height: 210)
            .background(Color.gray)
    }
}
#endif
