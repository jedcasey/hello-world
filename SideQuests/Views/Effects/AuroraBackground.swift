import SwiftUI

/// Full-screen living backdrop: a slow aurora drift rendered by the `aurora`
/// Metal shader. Falls back to the static gradient background when the user
/// prefers reduced motion.
struct AuroraBackground: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var scheme
    @State private var start = Date()

    var body: some View {
        if reduceMotion {
            AmbientBackground()
        } else {
            let dark: Float = scheme == .dark ? 1 : 0
            TimelineView(.animation(minimumInterval: 1.0 / 24.0)) { timeline in
                let t = timeline.date.timeIntervalSince(start)
                Rectangle()
                    .fill(Palette.bg)
                    .visualEffect { view, proxy in
                        view.colorEffect(
                            ShaderLibrary.aurora(
                                .float2(proxy.size),
                                .float(t),
                                .float(dark)
                            )
                        )
                    }
            }
            .ignoresSafeArea()
        }
    }
}
