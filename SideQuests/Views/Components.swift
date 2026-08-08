import SwiftUI

// MARK: - Progress ring

struct ProgressRing: View {
    var progress: Double
    var colors: [Color]
    var lineWidth: CGFloat = 5

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.08), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: max(0.001, min(1, progress)))
                .stroke(
                    LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress)
        }
    }
}

// MARK: - XP bar

struct XPBar: View {
    var progress: Double
    var colors: [Color] = [Palette.gold, Color(red: 0.87, green: 0.49, blue: 0.16)]
    var height: CGFloat = 8

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.white.opacity(0.08))
                Capsule()
                    .fill(LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing))
                    .frame(width: max(height, geo.size.width * min(1, max(0, progress))))
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress)
            }
        }
        .frame(height: height)
    }
}

// MARK: - Chips

struct Chip: View {
    var text: String
    var icon: String? = nil
    var tint: Color = Palette.textSecondary

    var body: some View {
        HStack(spacing: 5) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .semibold))
            }
            Text(text)
                .font(.system(size: 12, weight: .semibold))
        }
        .foregroundStyle(tint)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Capsule().fill(Color.white.opacity(0.06)))
        .overlay(Capsule().strokeBorder(Color.white.opacity(0.08), lineWidth: 1))
    }
}

// MARK: - Section header

struct SectionHeader: View {
    var title: String
    var subtitle: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.system(size: 13, weight: .bold))
                .tracking(2.2)
                .textCase(.uppercase)
                .foregroundStyle(Palette.textTertiary)
            if let subtitle {
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundStyle(Palette.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Tier dots

struct TierDots: View {
    var difficulty: Difficulty
    var tint: Color = Palette.gold

    var body: some View {
        HStack(spacing: 3) {
            ForEach(1...3, id: \.self) { i in
                Circle()
                    .fill(i <= difficulty.rawValue ? tint : Color.white.opacity(0.14))
                    .frame(width: 5, height: 5)
            }
        }
    }
}

// MARK: - Confetti

struct ConfettiView: View {
    private struct Particle {
        let x0: Double        // 0...1 horizontal origin
        let delay: Double
        let speed: Double     // screen-heights per second
        let sway: Double
        let phase: Double
        let size: Double
        let spin: Double
        let color: Color

        init(index: Int) {
            var rng = SeededRNG(seed: UInt64(index &+ 1))
            let palette: [Color] = QuestCategory.allCases.flatMap { $0.gradientColors } + [Palette.gold, .white]
            x0    = Double.random(in: 0...1, using: &rng)
            delay = Double.random(in: 0...1.2, using: &rng)
            speed = Double.random(in: 0.25...0.55, using: &rng)
            sway  = Double.random(in: 14...44, using: &rng)
            phase = Double.random(in: 0...(2 * .pi), using: &rng)
            size  = Double.random(in: 6...12, using: &rng)
            spin  = Double.random(in: 1.5...5.5, using: &rng)
            color = palette[Int.random(in: 0..<palette.count, using: &rng)]
        }
    }

    private let particles: [Particle] = (0..<110).map { Particle(index: $0) }
    @State private var start = Date()

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let elapsed = timeline.date.timeIntervalSince(start)
                for p in particles {
                    let t = elapsed - p.delay
                    guard t > 0 else { continue }
                    let y = t * p.speed * size.height - 30
                    guard y < size.height + 30 else { continue }
                    let x = p.x0 * size.width + sin(t * 2.4 + p.phase) * p.sway

                    context.drawLayer { layer in
                        layer.translateBy(x: x, y: y)
                        layer.rotate(by: .radians(t * p.spin))
                        let rect = CGRect(x: -p.size / 2, y: -p.size * 0.3, width: p.size, height: p.size * 0.6)
                        layer.fill(Path(roundedRect: rect, cornerRadius: 1.5), with: .color(p.color))
                    }
                }
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Big gradient CTA button

struct PrimaryButton: View {
    var title: String
    var colors: [Color]
    var icon: String? = nil
    var disabled: Bool = false
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .bold))
                }
                Text(title)
                    .font(.system(size: 16, weight: .bold))
            }
            .foregroundStyle(disabled ? Palette.textTertiary : .white)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(
                Group {
                    if disabled {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color.white.opacity(0.06))
                    } else {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing))
                            .shadow(color: colors[0].opacity(0.35), radius: 16, y: 6)
                    }
                }
            )
        }
        .buttonStyle(PressableStyle())
        .disabled(disabled)
    }
}
