import SwiftUI
import UIKit

// MARK: - Palette
// Daybreak: warm ivory paper, dark warm ink, and one ember accent reserved
// for XP, rank and reward moments.

enum Palette {
    static let bg           = Color(red: 0.984, green: 0.980, blue: 0.965)
    static let bgElevated   = Color.white
    static let card         = Color.white
    static let cardStrong   = Color(red: 0.961, green: 0.949, blue: 0.918)
    static let stroke       = Color(red: 0.36, green: 0.31, blue: 0.22).opacity(0.14)
    static let textPrimary  = Color(red: 0.110, green: 0.094, blue: 0.066)
    static let textSecondary = Color(red: 0.43, green: 0.40, blue: 0.35)
    static let textTertiary = Color(red: 0.64, green: 0.61, blue: 0.55)

    /// The reward accent. Historically "gold"; in Daybreak it is a sunrise
    /// ember — the name stays so call sites don't churn.
    static let gold         = Color(red: 0.957, green: 0.380, blue: 0.122)
    /// Second stop of the reward gradient.
    static let goldDeep     = Color(red: 1.00, green: 0.686, blue: 0.235)

    /// Neutral fills for chips, discs and inactive states on the light ground.
    static let fill         = Color(red: 0.36, green: 0.31, blue: 0.22).opacity(0.06)
    static let fillStrong   = Color(red: 0.36, green: 0.31, blue: 0.22).opacity(0.11)
    /// Soft warm wash behind ember iconography.
    static let accentSoft   = Color(red: 0.996, green: 0.953, blue: 0.910)
}

// MARK: - Category colors

extension QuestCategory {
    var gradientColors: [Color] {
        switch self {
        case .physical:
            return [Color(red: 1.00, green: 0.44, blue: 0.22), Color(red: 0.88, green: 0.19, blue: 0.26)]
        case .mental:
            return [Color(red: 0.48, green: 0.45, blue: 1.00), Color(red: 0.30, green: 0.24, blue: 0.86)]
        case .financial:
            return [Color(red: 0.94, green: 0.64, blue: 0.14), Color(red: 0.82, green: 0.49, blue: 0.07)]
        case .social:
            return [Color(red: 1.00, green: 0.46, blue: 0.56), Color(red: 0.84, green: 0.22, blue: 0.45)]
        case .adventure:
            return [Color(red: 0.14, green: 0.71, blue: 0.51), Color(red: 0.09, green: 0.51, blue: 0.43)]
        case .creative:
            return [Color(red: 0.73, green: 0.42, blue: 1.00), Color(red: 0.51, green: 0.27, blue: 0.90)]
        }
    }

    var accent: Color { gradientColors[0] }

    var gradient: LinearGradient {
        LinearGradient(colors: gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

// MARK: - Card chrome

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
                    .shadow(color: Color(red: 0.30, green: 0.24, blue: 0.12).opacity(0.07), radius: 14, y: 5)
            )
    }
}

extension View {
    func cardChrome(radius: CGFloat = 24, fill: Color = Palette.card) -> some View {
        modifier(CardBackground(radius: radius, fill: fill))
    }
}

// MARK: - Ambient background

/// Warm ivory backdrop with two faint morning glows for depth.
struct AmbientBackground: View {
    var body: some View {
        ZStack {
            Palette.bg

            RadialGradient(
                colors: [Color(red: 1.00, green: 0.69, blue: 0.24).opacity(0.16), .clear],
                center: .topLeading, startRadius: 10, endRadius: 500
            )

            RadialGradient(
                colors: [Color(red: 1.00, green: 0.55, blue: 0.45).opacity(0.10), .clear],
                center: .bottomTrailing, startRadius: 10, endRadius: 520
            )
        }
        .ignoresSafeArea()
    }
}
