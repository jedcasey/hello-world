import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var store: QuestStore
    @State private var page = 0
    @State private var selected: Set<QuestCategory> = []

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $page) {
                manifesto.tag(0)
                howItWorks.tag(1)
                arenaPicker.tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeOut(duration: 0.3), value: page)

            pageDots
                .padding(.bottom, 20)

            footerButton
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
        }
    }

    // MARK: Pages

    private var manifesto: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                ZStack(alignment: .bottomLeading) {
                    Image("manifesto")
                        .resizable()
                        .scaledToFill()
                        .frame(height: 300)
                        .clipped()
                        .filmGrain(0.05)
                        .overlay {
                            LinearGradient(
                                stops: [
                                    .init(color: .clear, location: 0.4),
                                    .init(color: Palette.bg.opacity(0.95), location: 1),
                                ],
                                startPoint: .top, endPoint: .bottom
                            )
                        }

                    Text("Side Quests")
                        .font(.system(size: 13, weight: .bold))
                        .tracking(3.5)
                        .textCase(.uppercase)
                        .foregroundStyle(Palette.gold)
                        .padding(20)
                }
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .strokeBorder(Palette.stroke, lineWidth: 1)
                )

                Text("Most men are waiting for life to become interesting.")
                    .font(.system(size: 34, weight: .bold, design: .default))
                    .foregroundStyle(Palette.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Life becomes interesting the moment you treat it like a game worth playing fully.\n\nNot just the main quest. The side quests.")
                    .font(.system(size: 17))
                    .lineSpacing(5)
                    .foregroundStyle(Palette.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
    }

    private var howItWorks: some View {
        VStack(alignment: .leading, spacing: 28) {
            Text("How it works")
                .font(.system(size: 32, weight: .bold, design: .default))
                .foregroundStyle(Palette.textPrimary)

            explainRow(category: .adventure,
                       title: "Choose a quest",
                       body: "Sixty real-world challenges across six arenas of life. No busywork — every one changes you.")

            explainRow(category: .physical,
                       title: "Log honest progress",
                       body: "One step at a time. Some quests take an afternoon, some take ninety days of showing up.")

            explainRow(category: nil,
                       title: "Earn XP, climb the ranks",
                       body: "From Drifter to Legend. The rank is a mirror — the life you build along the way is the prize.")
        }
        .padding(.horizontal, 28)
        .frame(maxHeight: .infinity)
    }

    private func explainRow(category: QuestCategory?, title: String, body text: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            if let category {
                ArenaTile(category: category, size: 48, radius: 15)
            } else {
                // The summit photograph stands in for the climb itself.
                Image("manifesto")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 48, height: 48)
                    .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15, style: .continuous)
                            .strokeBorder(Palette.gold.opacity(0.55), lineWidth: 1)
                    )
            }

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
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Where do you want to grow?")
                        .font(.system(size: 30, weight: .bold, design: .default))
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
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
    }

    // Each arena introduces itself with its own photograph; selection is a
    // gradient ring and a check, not a flood fill.
    private func arenaTile(_ category: QuestCategory) -> some View {
        let isOn = selected.contains(category)
        return Button {
            if isOn { selected.remove(category) } else { selected.insert(category) }
            Haptics.light()
        } label: {
            ZStack(alignment: .topTrailing) {
                VStack(alignment: .leading) {
                    Spacer(minLength: 0)
                    Text(category.title)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(Palette.textPrimary)
                        .shadow(color: Palette.bg.opacity(0.7), radius: 3, y: 1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)

                Image(systemName: isOn ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 18))
                    .foregroundStyle(isOn ? category.accent : Palette.textTertiary)
                    .contentTransition(.symbolEffect(.replace))
                    .padding(6)
                    .background(Circle().fill(.ultraThinMaterial))
                    .padding(8)
            }
            .frame(height: 108)
            .background(ArenaImage(category: category))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(
                        isOn ? AnyShapeStyle(category.gradient) : AnyShapeStyle(Palette.stroke),
                        lineWidth: isOn ? 2 : 1
                    )
            )
        }
        .buttonStyle(CardPressStyle())
        .animation(Motion.snappy, value: isOn)
    }

    // MARK: Chrome

    private var pageDots: some View {
        HStack(spacing: 7) {
            ForEach(0..<3, id: \.self) { i in
                Capsule()
                    .fill(i == page ? Palette.gold : Palette.fillStrong)
                    .frame(width: i == page ? 22 : 7, height: 7)
                    .animation(Motion.snappy, value: page)
            }
        }
    }

    private var footerButton: some View {
        let isLast = page == 2
        let title = page == 0 ? "I'm ready" : (isLast ? "Begin my journey" : "Continue")
        return PrimaryButton(
            title: title,
            colors: [Palette.gold, Palette.goldDeep],
            icon: isLast ? "arrow.right" : nil,
            disabled: isLast && selected.isEmpty
        ) {
            if isLast {
                store.completeOnboarding(focus: selected)
                Haptics.success()
            } else {
                withAnimation { page += 1 }
            }
        }
    }
}
