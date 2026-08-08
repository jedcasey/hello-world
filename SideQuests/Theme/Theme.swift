import SwiftUI
import UIKit

// MARK: - Palette

enum Palette {
    static let bg           = Color(red: 0.039, green: 0.043, blue: 0.055)
    static let bgElevated   = Color(red: 0.075, green: 0.08,  blue: 0.10)
    static let card         = Color.white.opacity(0.045)
    static let cardStrong   = Color.white.opacity(0.07)
    static let stroke       = Color.white.opacity(0.09)
    static let textPrimary  = Color(white: 0.96)
    static let textSecondary = Color(white: 0.64)
    static let textTertiary = Color(white: 0.42)
    static let gold         = Color(red: 0.94, green: 0.72, blue: 0.33)
}

// MARK: - Category colors

extension QuestCategory {
    var gradientColors: [Color] {
        switch self {
        case .physical:
            return [Color(red: 1.00, green: 0.44, blue: 0.22), Color(red: 0.88, green: 0.19, blue: 0.26)]
        case .mental:
            return [Color(red: 0.50, green: 0.46, blue: 1.00), Color(red: 0.30, green: 0.24, blue: 0.86)]
        case .financial:
            return [Color(red: 0.98, green: 0.76, blue: 0.30), Color(red: 0.86, green: 0.53, blue: 0.13)]
        case .social:
            return [Color(red: 1.00, green: 0.46, blue: 0.56), Color(red: 0.84, green: 0.22, blue: 0.45)]
        case .adventure:
            return [Color(red: 0.22, green: 0.85, blue: 0.61), Color(red: 0.10, green: 0.59, blue: 0.50)]
        case .creative:
            return [Color(red: 0.78, green: 0.45, blue: 1.00), Color(red: 0.51, green: 0.27, blue: 0.90)]
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
            )
    }
}

extension View {
    func cardChrome(radius: CGFloat = 24, fill: Color = Palette.card) -> some View {
        modifier(CardBackground(radius: radius, fill: fill))
    }
}

// MARK: - Ambient background

/// Near-black backdrop with two faint colored glows for depth.
struct AmbientBackground: View {
    var body: some View {
        ZStack {
            Palette.bg

            RadialGradient(
                colors: [Color(red: 0.30, green: 0.24, blue: 0.86).opacity(0.16), .clear],
                center: .topLeading, startRadius: 10, endRadius: 500
            )

            RadialGradient(
                colors: [Color(red: 0.88, green: 0.42, blue: 0.18).opacity(0.10), .clear],
                center: .bottomTrailing, startRadius: 10, endRadius: 520
            )
        }
        .ignoresSafeArea()
    }
}
