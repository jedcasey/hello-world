import SwiftUI

/// A small radial particle pop. Overlay it on a control and bump `trigger`
/// to fire — eight sparks fly out and a ring expands, then everything fades.
struct PopBurst: View {
    let trigger: Int
    var colors: [Color]

    var body: some View {
        ZStack {
            if trigger > 0 {
                BurstInstance(colors: colors)
                    .id(trigger)   // new identity per trigger -> onAppear re-runs
            }
        }
        .allowsHitTesting(false)
    }

    private struct BurstInstance: View {
        var colors: [Color]
        @State private var flown = false

        var body: some View {
            ZStack {
                Circle()
                    .stroke(colors.first ?? .white, lineWidth: flown ? 0.5 : 3)
                    .frame(width: flown ? 66 : 10, height: flown ? 66 : 10)
                    .opacity(flown ? 0 : 0.9)

                ForEach(0..<8, id: \.self) { i in
                    let angle = Double(i) / 8 * 2 * .pi
                    Circle()
                        .fill(colors[i % max(1, colors.count)])
                        .frame(width: 5, height: 5)
                        .offset(
                            x: flown ? cos(angle) * 34 : 0,
                            y: flown ? sin(angle) * 34 : 0
                        )
                        .opacity(flown ? 0 : 1)
                        .scaleEffect(flown ? 0.4 : 1)
                }
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.55)) {
                    flown = true
                }
            }
        }
    }
}
