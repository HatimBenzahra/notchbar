import SwiftUI

struct ClockContentSizeKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

struct ExpandedClockView: View {

    @ObservedObject var themeManager: ThemeManager
    let currentTime: Date

    @State private var accentLineScale: CGFloat = 0

    var body: some View {
        VStack(spacing: 8) {
            Text(timeString)
                .font(themeManager.heroFont)
                .monospacedDigit()
                .tracking(-1.5)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, .white.opacity(0.85)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: themeManager.accentColor.opacity(0.3), radius: 20)

            RoundedRectangle(cornerRadius: 0.75)
                .fill(themeManager.accentColor)
                .frame(width: 40, height: 1.5)
                .scaleEffect(x: accentLineScale, y: 1)
                .onAppear {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.65)) {
                        accentLineScale = 1
                    }
                }

            Text(dateString.uppercased())
                .font(themeManager.captionFont)
                .tracking(1.8)
                .foregroundStyle(themeManager.secondaryText)
        }
        .background(
            GeometryReader { geo in
                Color.clear.preference(
                    key: ClockContentSizeKey.self,
                    value: geo.size
                )
            }
        )
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
struct ExpandedClockView_Previews: PreviewProvider {
    static var previews: some View {
        ExpandedClockView(
            themeManager: ThemeManager(),
            currentTime: Date()
        )
        .padding(32)
        .background(Color.black)
    }
}
#endif
