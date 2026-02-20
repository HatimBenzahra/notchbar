import SwiftUI

struct CompactClockView: View {

    @ObservedObject var themeManager: ThemeManager
    let currentTime: Date

    @State private var colonOpacity: Double = 1.0

    var body: some View {
        HStack(spacing: 0) {
            Text(hourString)
                .font(themeManager.compactFont)
                .monospacedDigit()
                .foregroundStyle(.white)

            Text(":")
                .font(themeManager.compactFont)
                .monospacedDigit()
                .foregroundStyle(themeManager.accentColor)
                .opacity(colonOpacity)
                .animation(
                    .easeInOut(duration: 0.5).repeatForever(autoreverses: true),
                    value: colonOpacity
                )

            Text(minuteString)
                .font(themeManager.compactFont)
                .monospacedDigit()
                .foregroundStyle(.white)
        }
        .onAppear {
            colonOpacity = 0.4
        }
    }

    private var hourString: String {
        let f = DateFormatter()
        f.dateFormat = "HH"
        return f.string(from: currentTime)
    }

    private var minuteString: String {
        let f = DateFormatter()
        f.dateFormat = "mm"
        return f.string(from: currentTime)
    }
}

#if DEBUG
struct CompactClockView_Previews: PreviewProvider {
    static var previews: some View {
        CompactClockView(
            themeManager: ThemeManager(),
            currentTime: Date()
        )
        .padding(.horizontal, 16)
        .frame(height: 37)
        .background(Color.black)
    }
}
#endif
