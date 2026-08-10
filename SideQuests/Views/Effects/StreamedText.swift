import SwiftUI

/// Text that arrives the way thoughts do — word by word, each fading in.
/// Used for quest flavor text so reading it feels like receiving it.
struct StreamedText: View {
    let text: String
    var font: Font = .system(size: 16)
    var color: Color = Palette.textSecondary
    var wordDelay: Double = 0.055
    var fade: Double = 0.4

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var start: Date?
    @State private var finished = false

    private var words: [String] {
        text.split(separator: " ", omittingEmptySubsequences: false).map(String.init)
    }

    private var totalDuration: Double {
        Double(words.count) * wordDelay + fade + 0.1
    }

    var body: some View {
        Group {
            if reduceMotion || finished {
                Text(text)
                    .font(font)
                    .foregroundStyle(color)
            } else {
                TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
                    let t = start.map { timeline.date.timeIntervalSince($0) } ?? 0
                    assembled(elapsed: t)
                }
            }
        }
        .onAppear {
            guard start == nil else { return }
            start = Date()
            DispatchQueue.main.asyncAfter(deadline: .now() + totalDuration) {
                finished = true
            }
        }
    }

    private func assembled(elapsed: Double) -> Text {
        var result = Text(verbatim: "")
        for (i, word) in words.enumerated() {
            let alpha = max(0.0, min(1.0, (elapsed - Double(i) * wordDelay) / fade))
            let piece = Text(verbatim: word + (i == words.count - 1 ? "" : " "))
                .font(font)
                .foregroundColor(color.opacity(alpha))
            result = result + piece
        }
        return result
    }
}
