import SwiftUI

/// Full-screen living backdrop: a slow aurora drift rendered by the `aurora`
/// Metal shader. Falls back to the static gradient background when the user
/// prefers reduced motion.
struct AuroraBackground: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var start = Date()

    var body: some View {
        if reduceMotion {
            AmbientBackground()
        } else {
            TimelineView(.animation(minimumInterval: 1.0 / 24.0)) { timeline in
                let t = timeline.date.timeIntervalSince(start)
                Rectangle()
                    .fill(Palette.bg)
                    .visualEffect { view, proxy in
                        view.colorEffect(
                            ShaderLibrary.aurora(
                                .float2(proxy.size),
                                .float(t)
                            )
                        )
                    }
            }
            .ignoresSafeArea()
        }
    }
}
