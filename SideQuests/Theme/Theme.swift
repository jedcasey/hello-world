import SwiftUI
import UIKit

// MARK: - Palette
// Nightfall: near-black ground, typography-first hierarchy in steps of white,
// and one quiet champagne accent reserved for XP, rank and reward moments.
// Color is rationed; the dark photography carries the mood.

enum Palette {
    static let bg           = Color(red: 0.024, green: 0.024, blue: 0.028)
    static let bgElevated   = Color(red: 0.055, green: 0.055, blue: 0.062)
    static let card         = Color.white.opacity(0.038)
    static let cardStrong   = Color.white.opacity(0.07)
    static let stroke       = Color.white.opacity(0.08)
    static let textPrimary  = Color(white: 0.96)
    static let textSecondary = Color(white: 0.55)
    static let textTertiary = Color(white: 0.33)

    /// The reward accent. Historically "gold"; in Nightfall it is a muted
    /// champagne — barely a color at all. The name stays so call sites
    /// don't churn.
    static let gold         = Color(red: 0.92, green: 0.88, blue: 0.80)
    /// Second stop of the reward gradient.
    static let goldDeep     = Color(red: 0.70, green: 0.66, blue: 0.58)

    /// Neutral fills for chips, discs and inactive states.
    static let fill         = Color.white.opacity(0.05)
    static let fillStrong   = Color.white.opacity(0.10)
    /// Soft wash behind accent iconography.
    static let accentSoft   = Color.white.opacity(0.06)
}

// MARK: - Category colors
// Dusty, desaturated arena tones — visible in rings and bars without ever
// shouting against the monochrome ground.

extension QuestCategory {
    var gradientColors: [Color] {
        switch self {
        case .physical:
            return [Color(red: 0.80, green: 0.46, blue: 0.38), Color(red: 0.60, green: 0.30, blue: 0.28)]
        case .mental:
            return [Color(red: 0.55, green: 0.53, blue: 0.78), Color(red: 0.39, green: 0.36, blue: 0.62)]
        case .financial:
            return [Color(red: 0.78, green: 0.65, blue: 0.42), Color(red: 0.60, green: 0.47, blue: 0.27)]
        case .social:
            return [Color(red: 0.78, green: 0.47, blue: 0.53), Color(red: 0.58, green: 0.31, blue: 0.40)]
        case .adventure:
            return [Color(red: 0.38, green: 0.62, blue: 0.52), Color(red: 0.24, green: 0.44, blue: 0.39)]
        case .creative:
            return [Color(red: 0.62, green: 0.48, blue: 0.76), Color(red: 0.45, green: 0.33, blue: 0.59)]
        }
    }

    var accent: Color { gradientColors[0] }

    var gradient: LinearGradient {
        LinearGradient(colors: gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

// MARK: - Card chrome
// Flat by intent: a whisper of fill and a hairline. No drop shadows —
// hierarchy comes from type and spacing, not elevation.

struct CardBackground: ViewModifier {
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
            )
    }
}

extension View {
    func cardChrome(radius: CGFloat = 24, fill: Color = Palette.card) -> some View {
        modifier(CardBackground(radius: radius, fill: fill))
    }
}

// MARK: - Ambient background

/// Near-black backdrop with two faint cool glows for depth.
struct AmbientBackground: View {
    var body: some View {
        ZStack {
            Palette.bg

            RadialGradient(
                colors: [Color(red: 0.45, green: 0.50, blue: 0.62).opacity(0.10), .clear],
                center: .topLeading, startRadius: 10, endRadius: 500
            )

            RadialGradient(
                colors: [Color(red: 0.55, green: 0.55, blue: 0.60).opacity(0.06), .clear],
                center: .bottomTrailing, startRadius: 10, endRadius: 520
            )
        }
        .ignoresSafeArea()
    }
}
