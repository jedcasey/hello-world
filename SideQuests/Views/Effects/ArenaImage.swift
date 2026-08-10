import SwiftUI

/// Studio artwork for an arena: the generated photograph, unified with the UI
/// by film grain, a slow breathing zoom, and a scrim that guarantees text
/// legibility on top of it.
/// Circular photo medallion — the arena's photograph ringed with its
/// gradient. Replaces symbol-in-a-circle iconography everywhere a quest or
/// arena needs a face.
struct ArenaThumb: View {
    let category: QuestCategory
    var size: CGFloat = 44

    var body: some View {
        Image("arena-\(category.rawValue)")
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size)
            .clipShape(Circle())
            .overlay(
                Circle().strokeBorder(
                    LinearGradient(colors: category.gradientColors,
                                   startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: max(1.5, size * 0.035)
                )
            )
    }
}

/// Rounded-square photo tile for list rows and suggestion cards.
struct ArenaTile: View {
    let category: QuestCategory
    var size: CGFloat = 44
    var radius: CGFloat = 14

    var body: some View {
        Image("arena-\(category.rawValue)")
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .strokeBorder(category.accent.opacity(0.55), lineWidth: 1)
            )
    }
}

struct ArenaImage: View {
    let category: QuestCategory
    var scrim: Bool = true

    var body: some View {
        GeometryReader { geo in
            Image("arena-\(category.rawValue)")
                .resizable()
                .scaledToFill()
                .frame(width: geo.size.width, height: geo.size.height)
                .slowBreathe()
                .clipped()
                .filmGrain(0.05)
                .overlay {
                    if scrim {
                        LinearGradient(
                            stops: [
                                .init(color: .clear, location: 0),
                                .init(color: Palette.bg.opacity(0.25), location: 0.55),
                                .init(color: Palette.bg.opacity(0.9), location: 1),
                            ],
                            startPoint: .top, endPoint: .bottom
                        )
                    }
                }
        }
    }
}
