import SwiftUI

/// Spacing, radii, type, and the live-verb control. Hex stays in DesignTokens.
enum WeaveSpace {
    static let unit: CGFloat = 8
    static func steps(_ count: CGFloat) -> CGFloat { unit * count }
}

enum WeaveRadius {
    /// Rail plate, sheets, and primary surfaces.
    static let plate: CGFloat = 4
    /// Chips, badges, and small controls.
    static let chip: CGFloat = 2
}

enum WeaveType {
    private static var bold: String { DesignTokens.fontFamily + "-Bold" }
    private static var regular: String { DesignTokens.fontFamily }
    private static var italic: String { DesignTokens.fontFamily + "-Italic" }

    static let display = Font.custom(bold, size: 34, relativeTo: .largeTitle)
    static let title = Font.custom(bold, size: 24, relativeTo: .title2)
    static let headline = Font.custom(bold, size: 20, relativeTo: .headline)
    static let body = Font.custom(regular, size: 17, relativeTo: .body)
    static let caption = Font.custom(regular, size: 14, relativeTo: .caption)
    static let micro = Font.custom(regular, size: 12, relativeTo: .caption2)
    static let playful = Font.custom(italic, size: 17, relativeTo: .body)
    static let digits = Font.custom(regular, size: 17, relativeTo: .body).monospacedDigit()
}

enum WeaveCount {
    static func text(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }

    /// A night stamp, not a quantity. Decimal grouping would turn the day into a count.
    static func day(_ daykey: Int) -> String {
        let year = daykey / 10000
        let month = (daykey / 100) % 100
        let day = daykey % 100
        var parts = DateComponents()
        parts.year = year
        parts.month = month
        parts.day = day
        let formatter = DateFormatter()
        formatter.calendar = .current
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        if let date = Calendar.current.date(from: parts) {
            return formatter.string(from: date)
        }
        let plain = NumberFormatter()
        plain.numberStyle = .none
        plain.usesGroupingSeparator = false
        return plain.string(from: NSNumber(value: daykey)) ?? "0"
    }
}

@MainActor
enum WeaveFeel {
    static func commit() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}

/// Primary chrome: material plus accent at low opacity. Press, disable, and load are visible.
struct WeaveVerbStyle: ButtonStyle {
    var loading: Bool = false
    /// Full-width on the header. Compact when the control sits on the lit node.
    var expands: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        WeaveVerbLabel(configuration: configuration, loading: loading, expands: expands)
    }
}

private struct WeaveVerbLabel: View {
    let configuration: ButtonStyleConfiguration
    var loading: Bool
    var expands: Bool
    @Environment(\.isEnabled) private var enabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @ScaledMetric(relativeTo: .body) private var hit: CGFloat = 44

    var body: some View {
        configuration.label
            .font(WeaveType.headline)
            .foregroundStyle(enabled ? DesignTokens.ink : DesignTokens.muted)
            .frame(maxWidth: expands ? .infinity : nil, minHeight: hit)
            .padding(.horizontal, WeaveSpace.steps(2))
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: WeaveRadius.plate, style: .continuous)
                        .fill(.thinMaterial)
                    RoundedRectangle(cornerRadius: WeaveRadius.plate, style: .continuous)
                        .fill(DesignTokens.accent.opacity(configuration.isPressed && enabled ? 0.28 : 0.16))
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: WeaveRadius.plate, style: .continuous)
                    .strokeBorder(DesignTokens.ink.opacity(enabled ? 0.12 : 0.06), lineWidth: 1)
            }
            .opacity(!enabled || loading ? 0.45 : 1)
            .scaleEffect(configuration.isPressed && enabled && !reduceMotion ? 0.98 : 1)
            .contentShape(RoundedRectangle(cornerRadius: WeaveRadius.plate, style: .continuous))
            .animation(reduceMotion ? .easeOut(duration: 0.2) : .easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

/// Reset and other destructive actions. Accent stays on the live verb.
struct WeaveDangerStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(WeaveType.headline)
            .foregroundStyle(DesignTokens.ink)
            .frame(maxWidth: .infinity, minHeight: 44)
            .background {
                RoundedRectangle(cornerRadius: WeaveRadius.plate, style: .continuous)
                    .fill(.regularMaterial)
            }
            .overlay {
                RoundedRectangle(cornerRadius: WeaveRadius.plate, style: .continuous)
                    .strokeBorder(DesignTokens.ink.opacity(configuration.isPressed ? 0.45 : 0.2), lineWidth: 1)
            }
            .opacity(configuration.isPressed ? 0.7 : 1)
            .contentShape(RoundedRectangle(cornerRadius: WeaveRadius.plate, style: .continuous))
    }
}

struct WeaveQuietStyle: ButtonStyle {
    var enabled: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(WeaveType.body)
            .foregroundStyle(enabled ? DesignTokens.ink : DesignTokens.muted)
            .frame(minHeight: 44)
            .padding(.horizontal, WeaveSpace.steps(2))
            .background {
                RoundedRectangle(cornerRadius: WeaveRadius.chip, style: .continuous)
                    .fill(.thinMaterial)
            }
            .overlay {
                RoundedRectangle(cornerRadius: WeaveRadius.chip, style: .continuous)
                    .strokeBorder(DesignTokens.ink.opacity(configuration.isPressed ? 0.28 : 0.12), lineWidth: 1)
            }
            .opacity(enabled ? (configuration.isPressed ? 0.72 : 1) : 0.45)
            .contentShape(RoundedRectangle(cornerRadius: WeaveRadius.chip, style: .continuous))
    }
}

struct WeaveChip: View {
    var word: String

    var body: some View {
        Text(word)
            .font(WeaveType.micro)
            .foregroundStyle(DesignTokens.ink)
            .padding(.horizontal, WeaveSpace.unit)
            .padding(.vertical, WeaveSpace.unit)
            .background {
                RoundedRectangle(cornerRadius: WeaveRadius.chip, style: .continuous)
                    .fill(.thinMaterial)
            }
            .overlay {
                RoundedRectangle(cornerRadius: WeaveRadius.chip, style: .continuous)
                    .strokeBorder(DesignTokens.ink.opacity(0.12), lineWidth: 1)
            }
            .accessibilityLabel(word)
    }
}
