import SwiftUI

// MARK: - SettingsView

struct SettingsView: View {

    @ObservedObject var themeManager: ThemeManager
    @Binding var showSettings: Bool

    @State private var customPickerColor: Color = .white
    @State private var isCustomSelected: Bool = false

    var body: some View {
        VStack(spacing: 16) {
            colorSection
            fontSection
        }
        .frame(maxWidth: 280)
        .padding(.horizontal, 22)
        .padding(.vertical, 14)
        .background(
            GeometryReader { geo in
                Color.clear.preference(
                    key: ClockContentSizeKey.self,
                    value: geo.size
                )
            }
        )
        .transition(
            .asymmetric(
                insertion: .opacity.combined(with: .move(edge: .top)),
                removal: .opacity.combined(with: .move(edge: .top))
            )
        )
    }

    // MARK: - Color Section

    private var colorSection: some View {
        VStack(spacing: 9) {
            sectionLabel("Color")

            HStack(spacing: 5) {
                ForEach(AccentOption.palette) { option in
                    presetColorCircle(for: option)
                }
                customColorCircle
            }
        }
    }

    private func presetColorCircle(for option: AccentOption) -> some View {
        let isSelected = !isCustomSelected && themeManager.accentColorHex == option.hex

        return Button {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.58)) {
                themeManager.accentColorHex = option.hex
                isCustomSelected = false
            }
        } label: {
            Circle()
                .fill(Color(hexString: option.hex))
                .frame(width: 18, height: 18)
                .overlay(
                    Circle()
                        .strokeBorder(Color.white, lineWidth: 1.5)
                        .opacity(isSelected ? 1 : 0)
                        .animation(.easeInOut(duration: 0.15), value: isSelected)
                )
                .scaleEffect(isSelected ? 1.15 : 1.0)
                .animation(.spring(response: 0.28, dampingFraction: 0.58), value: isSelected)
        }
        .buttonStyle(.plain)
    }

    private var customColorCircle: some View {
        ZStack {
            // Rainbow ring background — always visible
            Circle()
                .strokeBorder(
                    AngularGradient(
                        colors: [
                            .red, .orange, .yellow, .green,
                            .cyan, .blue, .purple, .pink, .red
                        ],
                        center: .center
                    ),
                    lineWidth: 2
                )
                .frame(width: 18, height: 18)

            Circle()
                .strokeBorder(Color.white, lineWidth: 1.5)
                .frame(width: 18, height: 18)
                .opacity(isCustomSelected ? 1 : 0)
                .animation(.easeInOut(duration: 0.15), value: isCustomSelected)

            ColorPicker("", selection: $customPickerColor, supportsOpacity: false)
                .labelsHidden()
                .frame(width: 18, height: 18)
                .opacity(0.015)
        }
        .frame(width: 18, height: 18)
        .scaleEffect(isCustomSelected ? 1.15 : 1.0)
        .animation(.spring(response: 0.28, dampingFraction: 0.58), value: isCustomSelected)
        .onChange(of: customPickerColor) { newColor in
            if let hex = newColor.hexString {
                withAnimation(.spring(response: 0.28, dampingFraction: 0.58)) {
                    themeManager.accentColorHex = hex
                    isCustomSelected = true
                }
            }
        }
    }

    // MARK: - Font Section

    private var fontSection: some View {
        VStack(spacing: 9) {
            sectionLabel("Font")

            HStack(spacing: 5) {
                ForEach(FontChoice.allCases, id: \.rawValue) { choice in
                    fontPill(for: choice)
                }
            }
        }
    }

    private func fontPill(for choice: FontChoice) -> some View {
        let isSelected = themeManager.fontChoice == choice

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                themeManager.fontChoice = choice
            }
        } label: {
            Text(choice.pillLabel)
                .font(.system(size: 11.5, weight: isSelected ? .semibold : .regular, design: choice.design))
                .foregroundStyle(
                    isSelected
                        ? Color.white
                        : themeManager.secondaryText
                )
                .lineLimit(1)
                .padding(.horizontal, 8)
                .frame(height: 28)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(isSelected ? themeManager.accentColor : Color.clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(
                            isSelected ? Color.clear : Color.white.opacity(0.25),
                            lineWidth: 1
                        )
                )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }

    // MARK: - Helpers

    private func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(themeManager.captionFont)
            .tracking(1.5)
            .foregroundStyle(themeManager.secondaryText)
    }
}

// MARK: - SettingsToggleButton

struct SettingsToggleButton: View {

    @Binding var showSettings: Bool
    @ObservedObject var themeManager: ThemeManager

    @State private var isHovered: Bool = false

    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.22)) {
                showSettings.toggle()
            }
        } label: {
            Image(systemName: showSettings ? "xmark" : "gearshape.fill")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(
                    isHovered
                        ? themeManager.accentColor
                        : Color.white.opacity(0.3)
                )
                .frame(width: 16, height: 16)
                .contentTransition(.symbolEffect(.replace))
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
    }
}

// MARK: - FontChoice Display Helpers

private extension FontChoice {
    /// Short label rendered in the pill using that font's design
    var pillLabel: String {
        switch self {
        case .rounded: return "Round"
        case .mono:    return "Mono"
        case .serif:   return "Serif"
        case .classic: return "Classic"
        }
    }
}

// MARK: - Color + Hex Helpers

extension Color {

    /// Initialise from a 6-character hex string (without #).
    init(hexString hex: String) {
        let clean = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: clean).scanHexInt64(&value)
        let r = Double((value >> 16) & 0xFF) / 255
        let g = Double((value >> 8)  & 0xFF) / 255
        let b = Double( value        & 0xFF) / 255
        self.init(.sRGB, red: r, green: g, blue: b, opacity: 1)
    }

    /// Convert to a 6-character uppercase hex string using SwiftUI's `cgColor`.
    /// Available on macOS 12+ without importing AppKit.
    var hexString: String? {
        guard
            let cg = cgColor,
            let components = cg.components,
            components.count >= 3
        else { return nil }

        // cgColor components are already in [0…1] linear / sRGB space for colour-picker output
        let r = Int((components[0] * 255).rounded().clamped(to: 0...255))
        let g = Int((components[1] * 255).rounded().clamped(to: 0...255))
        let b = Int((components[2] * 255).rounded().clamped(to: 0...255))
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}

private extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}

// MARK: - Preview

#if DEBUG
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            SettingsView(
                themeManager: ThemeManager(),
                showSettings: .constant(true)
            )
        }
        .frame(width: 500, height: 200)
    }
}
#endif
