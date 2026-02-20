import SwiftUI

// MARK: - FontChoice

enum FontChoice: String, CaseIterable, Codable {
    case rounded = "rounded"
    case mono    = "mono"
    case serif   = "serif"
    case classic = "classic"

    var design: Font.Design {
        switch self {
        case .rounded: return .rounded
        case .mono:    return .monospaced
        case .serif:   return .serif
        case .classic: return .default
        }
    }

    var displayName: String {
        switch self {
        case .rounded: return "Rounded"
        case .mono:    return "Monospaced"
        case .serif:   return "Serif"
        case .classic: return "Classic"
        }
    }
}

// MARK: - AccentOption

struct AccentOption: Identifiable {
    let id:   String
    let name: String
    let hex:  String

    var color: Color { ThemeManager.color(from: hex) }

    // MARK: Palette

    static let palette: [AccentOption] = [
        AccentOption(id: "#007AFF", name: "Electric Blue",  hex: "#007AFF"),
        AccentOption(id: "#AF52DE", name: "Violet",         hex: "#AF52DE"),
        AccentOption(id: "#FF6B6B", name: "Coral",          hex: "#FF6B6B"),
        AccentOption(id: "#34C759", name: "Emerald",        hex: "#34C759"),
        AccentOption(id: "#FF9F0A", name: "Sunset Orange",  hex: "#FF9F0A"),
        AccentOption(id: "#FF2D55", name: "Hot Pink",       hex: "#FF2D55"),
        AccentOption(id: "#5AC8FA", name: "Cyan",           hex: "#5AC8FA"),
        AccentOption(id: "#FFD60A", name: "Gold",           hex: "#FFD60A"),
    ]
}

// MARK: - ThemeManager

final class ThemeManager: ObservableObject {

    // MARK: Persisted preferences

    @AppStorage("notchflow_accent_hex")
    var accentColorHex: String = "#007AFF" {
        willSet { objectWillChange.send() }
    }

    @AppStorage("notchflow_font_choice")
    var fontChoiceRaw: String = FontChoice.rounded.rawValue {
        willSet { objectWillChange.send() }
    }

    // MARK: Derived preference accessors

    var fontChoice: FontChoice {
        get { FontChoice(rawValue: fontChoiceRaw) ?? .rounded }
        set { fontChoiceRaw = newValue.rawValue }
    }

    // MARK: Computed colour properties

    var accentColor: Color {
        ThemeManager.color(from: accentColorHex)
    }

    var accentGradient: LinearGradient {
        LinearGradient(
            colors: [accentColor, accentColor.opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var secondaryText: Color {
        Color(white: 1.0).opacity(0.5)
    }

    // MARK: Computed font properties

    var heroFont: Font {
        .system(size: 48, weight: .heavy, design: fontChoice.design)
    }

    var compactFont: Font {
        .system(size: 14, weight: .medium, design: fontChoice.design)
    }

    var captionFont: Font {
        .system(size: 13, weight: .regular, design: fontChoice.design)
    }

    // MARK: Convenience mutators

    func setAccent(_ option: AccentOption) {
        accentColorHex = option.hex
    }

    func resetToDefaults() {
        accentColorHex = "#007AFF"
        fontChoiceRaw  = FontChoice.rounded.rawValue
    }

    // MARK: Hex ↔ Color helpers

    static func color(from hex: String) -> Color {
        var sanitised = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if sanitised.hasPrefix("#") { sanitised.removeFirst() }

        guard sanitised.count == 6 || sanitised.count == 8 else {
            return .accentColor
        }

        var value: UInt64 = 0
        guard Scanner(string: sanitised).scanHexInt64(&value) else {
            return .accentColor
        }

        let r, g, b, a: Double
        if sanitised.count == 6 {
            r = Double((value >> 16) & 0xFF) / 255
            g = Double((value >>  8) & 0xFF) / 255
            b = Double( value        & 0xFF) / 255
            a = 1.0
        } else {
            r = Double((value >> 24) & 0xFF) / 255
            g = Double((value >> 16) & 0xFF) / 255
            b = Double((value >>  8) & 0xFF) / 255
            a = Double( value        & 0xFF) / 255
        }

        return Color(.sRGB, red: r, green: g, blue: b, opacity: a)
    }

    static func hex(from color: Color) -> String {
        #if canImport(AppKit)
        let native = NSColor(color).usingColorSpace(.sRGB)
        guard let c = native else { return "#007AFF" }
        let r = Int(c.redComponent   * 255 + 0.5)
        let g = Int(c.greenComponent * 255 + 0.5)
        let b = Int(c.blueComponent  * 255 + 0.5)
        return String(format: "#%02X%02X%02X", r, g, b)
        #else
        return "#007AFF"
        #endif
    }
}
