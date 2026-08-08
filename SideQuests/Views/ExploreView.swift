import SwiftUI

struct ExploreView: View {
    @EnvironmentObject private var store: QuestStore

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("The quest board")
                            .font(.system(size: 34, weight: .bold, design: .serif))
                            .foregroundStyle(Palette.textPrimary)
                        Text("Sixty ways to make life interesting again.")
                            .font(.system(size: 15))
                            .foregroundStyle(Palette.textSecondary)
                    }

                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                        ForEach(QuestCategory.allCases) { category in
                            NavigationLink(value: category) {
                                CategoryCard(category: category)
                            }
                            .buttonStyle(CardPressStyle())
                            .scrollEntrance()
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 120)
            }
            .scrollIndicators(.hidden)
            .background(AuroraBackground())
            .navigationDestination(for: QuestCategory.self) { category in
                CategoryDetailView(category: category)
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
    }
}

// MARK: - Category card
// The generated studio photograph fills the card; type sits on the scrim.

struct CategoryCard: View {
    @EnvironmentObject private var store: QuestStore
    let category: QuestCategory

    var body: some View {
        let total = QuestLibrary.quests(in: category).count
        let done = store.completedCount(in: category)

        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Image(systemName: category.icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(.ultraThinMaterial))
                    .overlay(Circle().strokeBorder(Color.white.opacity(0.15), lineWidth: 1))
                Spacer()
            }

            Spacer(minLength: 14)

            Text(category.title)
                .font(.system(size: 20, weight: .bold, design: .serif))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.5), radius: 4, y: 1)

            Text("\(done) of \(total) complete")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.white.opacity(0.75))
                .monospacedDigit()
                .padding(.top, 2)

            XPBar(progress: total > 0 ? Double(done) / Double(total) : 0,
                  colors: category.gradientColors, height: 5)
                .padding(.top, 10)
        }
        .padding(15)
        .frame(height: 172, alignment: .topLeading)
        .background {
            ArenaImage(category: category)
        }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(Color.white.opacity(0.10), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.35), radius: 14, y: 8)
    }
}

// MARK: - Category detail
// Stretchy photographic hero: pulling down scales the artwork instead of
// revealing a gap, like a well-made editorial app.

struct CategoryDetailView: View {
    @EnvironmentObject private var store: QuestStore
    let category: QuestCategory
    @State private var selectedQuest: Quest?

    private let heroHeight: CGFloat = 280

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                stretchyHero

                VStack(spacing: 10) {
                    ForEach(QuestLibrary.quests(in: category)) { quest in
                        QuestRow(quest: quest) {
                            selectedQuest = quest
                        }
                        .scrollEntrance()
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 120)
        }
        .scrollIndicators(.hidden)
        .ignoresSafeArea(edges: .top)
        .background(AuroraBackground())
        .toolbarBackground(.hidden, for: .navigationBar)
        .sheet(item: $selectedQuest) { quest in
            QuestDetailView(quest: quest)
        }
    }

    private var stretchyHero: some View {
        GeometryReader { geo in
            let minY = geo.frame(in: .global).minY
            let stretch = max(0, minY)

            ZStack(alignment: .bottomLeading) {
                ArenaImage(category: category)

                heroText
                    .padding(20)
            }
            .frame(width: geo.size.width, height: heroHeight + stretch)
            .clipped()
            .offset(y: -stretch)
        }
        .frame(height: heroHeight)
    }

    private var heroText: some View {
        let total = QuestLibrary.quests(in: category).count
        let done = store.completedCount(in: category)

        return VStack(alignment: .leading, spacing: 8) {
            Text(category.title)
                .font(.system(size: 34, weight: .bold, design: .serif))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.5), radius: 6, y: 2)

            Text(category.tagline)
                .font(.system(size: 15))
                .foregroundStyle(Color.white.opacity(0.85))
                .shadow(color: .black.opacity(0.5), radius: 4, y: 1)

            HStack(spacing: 10) {
                XPBar(progress: total > 0 ? Double(done) / Double(total) : 0,
                      colors: category.gradientColors, height: 6)
                Text("\(done)/\(total)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color.white.opacity(0.85))
                    .monospacedDigit()
            }
            .padding(.top, 4)
        }
    }
}

// MARK: - Quest row

struct QuestRow: View {
    @EnvironmentObject private var store: QuestStore
    let quest: Quest
    var onTap: () -> Void

    var body: some View {
        let state = store.state(of: quest)

        Button(action: onTap) {
            HStack(spacing: 13) {
                statusIcon(state)

                VStack(alignment: .leading, spacing: 3) {
                    Text(quest.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(state == .completed ? Palette.textSecondary : Palette.textPrimary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)

                    HStack(spacing: 8) {
                        TierDots(difficulty: quest.difficulty, tint: quest.category.accent)
                        if state == .completed {
                            Text("Complete · +\(quest.difficulty.xp) XP")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(Palette.gold)
                                .monospacedDigit()
                        } else if let p = store.progress(of: quest), quest.isMultiStep {
                            Text("\(p.count) of \(quest.target) \(quest.unit)")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(Palette.textSecondary)
                                .monospacedDigit()
                        } else {
                            Text("+\(quest.difficulty.xp) XP")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(Palette.textSecondary)
                                .monospacedDigit()
                        }
                    }
                }

                Spacer(minLength: 8)

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Palette.textTertiary)
            }
            .padding(14)
            .cardChrome(radius: 20)
            .opacity(state == .completed ? 0.72 : 1)
        }
        .buttonStyle(CardPressStyle())
    }

    @ViewBuilder
    private func statusIcon(_ state: QuestState) -> some View {
        switch state {
        case .available:
            Circle()
                .strokeBorder(Color.white.opacity(0.18), lineWidth: 1.8)
                .frame(width: 30, height: 30)
        case .active:
            let p = store.progress(of: quest)
            let fraction = quest.target > 0 ? Double(p?.count ?? 0) / Double(quest.target) : 0
            ProgressRing(progress: quest.isMultiStep ? fraction : 0.12,
                         colors: quest.category.gradientColors, lineWidth: 3.5)
                .frame(width: 30, height: 30)
        case .completed:
            Image(systemName: "checkmark")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 30, height: 30)
                .background(Circle().fill(quest.category.gradient))
        }
    }
}
