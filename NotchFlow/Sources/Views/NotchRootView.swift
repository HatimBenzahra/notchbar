import SwiftUI

private struct ContentSizeKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

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
            Text(timeString)
                .font(NotchType.compactTime)
                .monospacedDigit()
                .tracking(0.5)
                .foregroundStyle(.white)
            Spacer()
        }
        .frame(height: viewModel.compactHeight)
    }

    private var expandedContent: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 0) {
                Spacer().frame(height: viewModel.compactHeight)

                Spacer()

                VStack(spacing: 4) {
                    Text(timeString)
                        .font(NotchType.heroLarge)
                        .monospacedDigit()
                        .tracking(-1.5)
                        .foregroundStyle(.white)

                    Text(dateString.uppercased())
                        .font(NotchType.caption)
                        .tracking(1.8)
                        .foregroundStyle(NotchTheme.textSecondary)
                }
                .background(
                    GeometryReader { geo in
                        Color.clear.preference(
                            key: ContentSizeKey.self,
                            value: geo.size
                        )
                    }
                )

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            SpiderView(threadLength: 28)
                .padding(.top, viewModel.compactHeight + 2)
                .padding(.trailing, 30)
                .opacity(0.85)
        }
        .onPreferenceChange(ContentSizeKey.self) { size in
            viewModel.updateContentSize(size)
        }
    }

    private var timeString: String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f.string(from: currentTime)
    }

    private var dateString: String {
        let f = DateFormatter()
        f.dateFormat = "EEE d MMM"
        return f.string(from: currentTime)
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
