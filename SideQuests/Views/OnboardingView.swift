import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var store: QuestStore
    @State private var page = 0
    @State private var selected: Set<QuestCategory> = []

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)

            Group {
                switch page {
                case 0: manifesto
                case 1: howItWorks
                default: arenaPicker
                }
            }
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            ))

            Spacer(minLength: 0)

            pageDots
                .padding(.bottom, 24)

            footerButton
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.85), value: page)
    }

    // MARK: Pages

    private var manifesto: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Side Quests")
                .font(.system(size: 13, weight: .bold))
                .tracking(3.5)
                .textCase(.uppercase)
                .foregroundStyle(Palette.gold)

            Text("Most men are waiting for life to become interesting.")
                .font(.system(size: 36, weight: .bold, design: .serif))
                .foregroundStyle(Palette.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Text("Life becomes interesting the moment you treat it like a game worth playing fully.\n\nNot just the main quest. The side quests.")
                .font(.system(size: 17))
                .lineSpacing(5)
                .foregroundStyle(Palette.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 28)
    }

    private var howItWorks: some View {
        VStack(alignment: .leading, spacing: 28) {
            Text("How it works")
                .font(.system(size: 32, weight: .bold, design: .serif))
                .foregroundStyle(Palette.textPrimary)

            explainRow(icon: "scroll.fill", tint: QuestCategory.adventure.accent,
                       title: "Choose a quest",
                       body: "Sixty real-world challenges across six arenas of life. No busywork — every one changes you.")

            explainRow(icon: "flame.fill", tint: QuestCategory.physical.accent,
                       title: "Log honest progress",
                       body: "One step at a time. Some quests take an afternoon, some take ninety days of showing up.")

            explainRow(icon: "crown.fill", tint: Palette.gold,
                       title: "Earn XP, climb the ranks",
                       body: "From Drifter to Legend. The rank is a mirror — the life you build along the way is the prize.")
        }
        .padding(.horizontal, 28)
    }

    private func explainRow(icon: String, tint: Color, title: String, body text: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 48, height: 48)
                .background(RoundedRectangle(cornerRadius: 15, style: .continuous).fill(Color.white.opacity(0.06)))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Palette.textPrimary)
                Text(text)
                    .font(.system(size: 14))
                    .lineSpacing(3)
                    .foregroundStyle(Palette.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var arenaPicker: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Where do you want to grow?")
                    .font(.system(size: 30, weight: .bold, design: .serif))
                    .foregroundStyle(Palette.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                Text("Pick at least one arena. You can explore all of them anytime.")
                    .font(.system(size: 15))
                    .foregroundStyle(Palette.textSecondary)
            }

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                ForEach(QuestCategory.allCases) { category in
                    arenaTile(category)
                }
            }
        }
        .padding(.horizontal, 28)
    }

    private func arenaTile(_ category: QuestCategory) -> some View {
        let isOn = selected.contains(category)
        return Button {
            if isOn { selected.remove(category) } else { selected.insert(category) }
            Haptics.light()
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: category.icon)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(isOn ? Color.white : category.accent)
                    Spacer()
                    Image(systemName: isOn ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 17))
                        .foregroundStyle(isOn ? Color.white : Palette.textTertiary)
                }
                Spacer(minLength: 0)
                Text(category.title)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(isOn ? Color.white : Palette.textPrimary)
            }
            .padding(14)
            .frame(height: 96, alignment: .topLeading)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(isOn ? AnyShapeStyle(category.gradient) : AnyShapeStyle(Palette.card))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .strokeBorder(isOn ? Color.white.opacity(0.25) : Palette.stroke, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PressableStyle())
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isOn)
    }

    // MARK: Chrome

    private var pageDots: some View {
        HStack(spacing: 7) {
            ForEach(0..<3, id: \.self) { i in
                Capsule()
                    .fill(i == page ? Palette.gold : Color.white.opacity(0.15))
                    .frame(width: i == page ? 22 : 7, height: 7)
            }
        }
    }

    private var footerButton: some View {
        let isLast = page == 2
        let title = page == 0 ? "I'm ready" : (isLast ? "Begin my journey" : "Continue")
        return PrimaryButton(
            title: title,
            colors: [Palette.gold, Color(red: 0.87, green: 0.49, blue: 0.16)],
            icon: isLast ? "arrow.right" : nil,
            disabled: isLast && selected.isEmpty
        ) {
            if isLast {
                store.completeOnboarding(focus: selected)
                Haptics.success()
            } else {
                page += 1
            }
        }
    }
}
