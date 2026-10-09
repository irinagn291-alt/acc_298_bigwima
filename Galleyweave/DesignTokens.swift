import SwiftUI

/// SPEC section 7. The only place these hex values live — reach colours
/// and the font family through here. Keep this file and its values.
enum DesignTokens {
    /// #FFFFFF
    static let bg = Color(red: 1.000000, green: 1.000000, blue: 1.000000)
    static let bgHex = "#FFFFFF"
    /// #FFFFFF
    static let surface = Color(red: 1.000000, green: 1.000000, blue: 1.000000)
    static let surfaceHex = "#FFFFFF"
    /// #111827
    static let ink = Color(red: 0.066667, green: 0.094118, blue: 0.152941)
    static let inkHex = "#111827"
    /// #FF5701
    static let accent = Color(red: 1.000000, green: 0.341176, blue: 0.003922)
    static let accentHex = "#FF5701"
    /// #6A6F76
    static let muted = Color(red: 0.415686, green: 0.435294, blue: 0.462745)
    static let mutedHex = "#6A6F76"
    static let fontFamily = "Georgia"
}
