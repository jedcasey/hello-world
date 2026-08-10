import SwiftUI
import UIKit

// MARK: - Adaptive color

private extension Color {
    /// A dynamic color that resolves per the system appearance.
    init(light: UIColor, dark: UIColor) {
        self.init(uiColor: UIColor { trait in
            trait.userInterfaceStyle == .dark ? dark : light
        })
    }
}

// MARK: - Palette
// Ascent: one brand, two moods. Light is warm morning paper; dark is a deep
// indigo night that glows rather than broods. The sunrise-amber accent and
// the vivid arena tones are shared, so the app feels like itself in both.

enum Palette {
    /// Ground. Warm cream by day, deep indigo-navy by night.
    static let bg = Color(
        light: UIColor(red: 0.980, green: 0.969, blue: 0.945, alpha: 1),
        dark:  UIColor(red: 0.051, green: 0.067, blue: 0.125, alpha: 1))

    static let bgElevated = Color(
        light: UIColor.white,
        dark:  UIColor(red: 0.082, green: 0.102, blue: 0.180, alpha: 1))

    static let card = Color(
        light: UIColor.white,
        dark:  UIColor(white: 1, alpha: 0.055))

    static let cardStrong = Color(
        light: UIColor(red: 1, green: 0.985, blue: 0.955, alpha: 1),
        dark:  UIColor(white: 1, alpha: 0.10))

    static let stroke = Color(
        light: UIColor(red: 0.35, green: 0.28, blue: 0.16, alpha: 0.10),
        dark:  UIColor(white: 1, alpha: 0.10))

    static let textPrimary = Color(
        light: UIColor(red: 0.13, green: 0.11, blue: 0.09, alpha: 1),
        dark:  UIColor(red: 0.965, green: 0.955, blue: 0.935, alpha: 1))

    static let textSecondary = Color(
        light: UIColor(red: 0.42, green: 0.38, blue: 0.33, alpha: 1),
        dark:  UIColor(white: 1, alpha: 0.64))

    static let textTertiary = Color(
        light: UIColor(red: 0.62, green: 0.57, blue: 0.50, alpha: 1),
        dark:  UIColor(white: 1, alpha: 0.40))

    /// The sunrise accent — XP, ranks, rewards. Deeper by day for contrast on
    /// cream; luminous by night so it glows against the indigo.
    static let gold = Color(
        light: UIColor(red: 0.87, green: 0.49, blue: 0.13, alpha: 1),
        dark:  UIColor(red: 0.97, green: 0.72, blue: 0.35, alpha: 1))

    /// Second stop of the reward gradient.
    static let goldDeep = Color(
        light: UIColor(red: 0.76, green: 0.34, blue: 0.09, alpha: 1),
        dark:  UIColor(red: 0.90, green: 0.52, blue: 0.20, alpha: 1))

    /// Neutral fills for chips, discs and inactive states.
    static let fill = Color(
        light: UIColor(red: 0.35, green: 0.28, blue: 0.16, alpha: 0.06),
        dark:  UIColor(white: 1, alpha: 0.07))

    static let fillStrong = Color(
        light: UIColor(red: 0.35, green: 0.28, blue: 0.16, alpha: 0.11),
        dark:  UIColor(white: 1, alpha: 0.14))

    /// Soft warm wash behind accent iconography.
    static let accentSoft = Color(
        light: UIColor(red: 0.95, green: 0.62, blue: 0.24, alpha: 0.14),
        dark:  UIColor(red: 0.97, green: 0.72, blue: 0.35, alpha: 0.16))
}

// MARK: - Category colors
// Vivid, energetic arena tones tuned to read on cream and to glow on indigo.

extension QuestCategory {
    var gradientColors: [Color] {
        switch self {
        case .physical:
            return [Color(red: 1.00, green: 0.45, blue: 0.30), Color(red: 0.89, green: 0.25, blue: 0.28)]
        case .mental:
            return [Color(red: 0.53, green: 0.47, blue: 0.98), Color(red: 0.37, green: 0.31, blue: 0.86)]
        case .financial:
            return [Color(red: 0.98, green: 0.66, blue: 0.22), Color(red: 0.87, green: 0.48, blue: 0.11)]
        case .social:
            return [Color(red: 0.98, green: 0.44, blue: 0.58), Color(red: 0.85, green: 0.26, blue: 0.46)]
        case .adventure:
            return [Color(red: 0.16, green: 0.75, blue: 0.55), Color(red: 0.05, green: 0.55, blue: 0.46)]
        case .creative:
            return [Color(red: 0.72, green: 0.44, blue: 0.96), Color(red: 0.55, green: 0.29, blue: 0.81)]
        }
    }

    var accent: Color { gradientColors[0] }

    var gradient: LinearGradient {
        LinearGradient(colors: gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

// MARK: - Card chrome
// Soft-elevated by day (paper over paper), softly luminous by night.

struct CardBackground: ViewModifier {
    @Environment(\.colorScheme) private var scheme
    var radius: CGFloat
    var fill: Color

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(fill)
                    .overlay(
                        RoundedRectangle(cornerRadius: radius, style: .continuous)
                            .strokeBorder(Palette.stroke, lineWidth: 1)
                    )
                    .shadow(
                        color: scheme == .dark
                            ? Color.black.opacity(0.30)
                            : Color(red: 0.35, green: 0.24, blue: 0.10).opacity(0.08),
                        radius: scheme == .dark ? 18 : 14,
                        y: scheme == .dark ? 10 : 6
                    )
            )
    }
}

extension View {
    func cardChrome(radius: CGFloat = 24, fill: Color = Palette.card) -> some View {
        modifier(CardBackground(radius: radius, fill: fill))
    }
}

// MARK: - Ambient background

/// Static backdrop (reduced-motion fallback): the same two moods as the
/// aurora shader — a warm morning wash by day, luminous night glows by dark.
struct AmbientBackground: View {
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        ZStack {
            Palette.bg

            if scheme == .dark {
                RadialGradient(
                    colors: [Color(red: 0.97, green: 0.72, blue: 0.35).opacity(0.14), .clear],
                    center: .topTrailing, startRadius: 10, endRadius: 480
                )
                RadialGradient(
                    colors: [Color(red: 0.42, green: 0.36, blue: 0.85).opacity(0.16), .clear],
                    center: .bottomLeading, startRadius: 10, endRadius: 560
                )
                RadialGradient(
                    colors: [Color(red: 0.15, green: 0.55, blue: 0.55).opacity(0.10), .clear],
                    center: .topLeading, startRadius: 10, endRadius: 420
                )
            } else {
                RadialGradient(
                    colors: [Color(red: 1.0, green: 0.80, blue: 0.55).opacity(0.32), .clear],
                    center: .topTrailing, startRadius: 10, endRadius: 480
                )
                RadialGradient(
                    colors: [Color(red: 1.0, green: 0.62, blue: 0.40).opacity(0.16), .clear],
                    center: .bottomLeading, startRadius: 10, endRadius: 560
                )
            }
        }
        .ignoresSafeArea()
    }
}
