import SwiftUI

/// Studio artwork for an arena: the generated photograph, unified with the UI
/// by film grain, a slow breathing zoom, and a scrim that guarantees text
/// legibility on top of it.
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
