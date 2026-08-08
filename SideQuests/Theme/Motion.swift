import SwiftUI

// MARK: - Motion constants
// One vocabulary of springs so every interaction shares the same physical feel.

enum Motion {
    /// Default interface spring — settles quickly, slight life.
    static let spring = Animation.spring(response: 0.42, dampingFraction: 0.82)
    /// For small, immediate reactions (presses, toggles).
    static let snappy = Animation.spring(response: 0.30, dampingFraction: 0.78)
    /// For celebratory or playful moments.
    static let bouncy = Animation.spring(response: 0.52, dampingFraction: 0.66)
}

// MARK: - Shimmer
// Periodic specular sweep, backed by the `shimmer` Metal shader.

struct ShimmerModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var start = Date()

    func body(content: Content) -> some View {
        if reduceMotion {
            content
        } else {
            TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
                let t = timeline.date.timeIntervalSince(start)
                content
                    .visualEffect { view, proxy in
                        view.colorEffect(
                            ShaderLibrary.shimmer(
                                .float2(proxy.size),
                                .float(t)
                            )
                        )
                    }
            }
        }
    }
}

extension View {
    /// Adds a slow, periodic gold sheen sweep. Use sparingly — XP bars, rank chrome.
    func shimmer() -> some View { modifier(ShimmerModifier()) }
}

// MARK: - Film grain

extension View {
    /// Static photographic grain; unifies generated artwork with the UI.
    func filmGrain(_ amount: Double = 0.045) -> some View {
        visualEffect { view, _ in
            view.colorEffect(ShaderLibrary.filmGrain(.float(0), .float(amount)))
        }
    }
}

// MARK: - Press styles

/// The standard press: scale + dim with a spring.
struct PressableStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.85 : 1)
            .animation(Motion.snappy, value: configuration.isPressed)
    }
}

/// Cards: a subtle 3D dip toward the thumb plus a shadow change,
/// so the surface feels like it has mass.
struct CardPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.965 : 1)
            .rotation3DEffect(
                .degrees(configuration.isPressed ? 2.4 : 0),
                axis: (x: 1, y: 0, z: 0),
                perspective: 0.6
            )
            .brightness(configuration.isPressed ? 0.03 : 0)
            .animation(Motion.snappy, value: configuration.isPressed)
    }
}

// MARK: - Scroll entrance
// Cards breathe in as they enter the viewport and recede as they leave.

extension View {
    func scrollEntrance() -> some View {
        scrollTransition { content, phase in
            content
                .opacity(phase.isIdentity ? 1 : 0.3)
                .scaleEffect(phase.isIdentity ? 1 : 0.94, anchor: .center)
                .blur(radius: phase.isIdentity ? 0 : 2.5)
        }
    }
}

// MARK: - Slow breathe
// A barely-there scale oscillation for hero imagery (digital Ken Burns).

struct BreatheModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var expanded = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(expanded && !reduceMotion ? 1.07 : 1.0)
            .onAppear {
                withAnimation(.easeInOut(duration: 16).repeatForever(autoreverses: true)) {
                    expanded = true
                }
            }
    }
}

extension View {
    func slowBreathe() -> some View { modifier(BreatheModifier()) }
}
