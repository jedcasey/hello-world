import SwiftUI

struct JourneyView: View {
    @EnvironmentObject private var store: QuestStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 26) {
                Text("Your journey")
                    .font(.system(size: 34, weight: .bold, design: .serif))
                    .foregroundStyle(Palette.textPrimary)

                rankHero.scrollEntrance()
                statsGrid.scrollEntrance()
                masterySection.scrollEntrance()
                trophyLog.scrollEntrance()
            }
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 120)
        }
        .scrollIndicators(.hidden)
    }

    // MARK: Rank hero

    private var rankHero: some View {
        VStack(spacing: 14) {
            Text("Current rank")
                .font(.system(size: 12, weight: .bold))
                .tracking(3)
                .textCase(.uppercase)
                .foregroundStyle(Palette.textTertiary)

            Text(store.rank.name)
                .font(.system(size: 40, weight: .bold, design: .serif))
                .foregroundStyle(Palette.textPrimary)

            Text("“\(store.rank.motto)”")
                .font(.system(size: 14, design: .serif))
                .italic()
                .foregroundStyle(Palette.textSecondary)
                .multilineTextAlignment(.center)

            VStack(spacing: 8) {
                XPBar(progress: store.rankProgress)
                    .shimmer()
                HStack {
                    Text("\(store.totalXP.formatted()) XP")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Palette.gold)
                        .monospacedDigit()
                        .contentTransition(.numericText(value: Double(store.totalXP)))
                    Spacer()
                    if let next = store.nextRank {
                        Text("\(next.name) at \(next.xpRequired.formatted())")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Palette.textTertiary)
                            .monospacedDigit()
                    } else {
                        Text("Highest rank achieved")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Palette.textTertiary)
                    }
                }
            }
            .padding(.top, 6)
        }
        .frame(maxWidth: .infinity)
        .padding(22)
        .cardChrome()
    }

    // MARK: Stats

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
            StatTile(value: "\(store.completedQuests.count)", label: "Quests complete", icon: "checkmark.seal.fill", tint: Palette.gold)
            StatTile(value: "\(store.activeQuests.count)", label: "In progress", icon: "scroll.fill", tint: QuestCategory.mental.accent)
            StatTile(value: "\(store.streak)", label: "Day streak", icon: "flame.fill", tint: QuestCategory.physical.accent)
            StatTile(value: store.totalXP.formatted(), label: "Total XP", icon: "sparkles", tint: QuestCategory.adventure.accent)
        }
    }

    // MARK: Mastery

    private var masterySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "Arena mastery")

            VStack(spacing: 14) {
                ForEach(QuestCategory.allCases) { category in
                    let total = QuestLibrary.quests(in: category).count
                    let done = store.completedCount(in: category)

                    HStack(spacing: 12) {
                        Image(systemName: category.icon)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(category.accent)
                            .frame(width: 30, height: 30)
                            .background(RoundedRectangle(cornerRadius: 9, style: .continuous).fill(Color.white.opacity(0.06)))

                        Text(category.title)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Palette.textPrimary)
                            .frame(width: 76, alignment: .leading)

                        XPBar(progress: total > 0 ? Double(done) / Double(total) : 0,
                              colors: category.gradientColors, height: 6)

                        Text("\(done)/\(total)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Palette.textSecondary)
                            .monospacedDigit()
                            .frame(width: 34, alignment: .trailing)
                    }
                }
            }
            .padding(16)
            .cardChrome()
        }
    }

    // MARK: Trophy log

    private var trophyLog: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "Trophy log")

            if store.completedQuests.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "trophy")
                        .font(.system(size: 26))
                        .foregroundStyle(Palette.textTertiary)
                    Text("Nothing here yet")
                        .font(.system(size: 16, weight: .bold, design: .serif))
                        .foregroundStyle(Palette.textPrimary)
                    Text("The list of things you're proud of starts with one completed quest.")
                        .font(.system(size: 13))
                        .foregroundStyle(Palette.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(26)
                .cardChrome()
            } else {
                VStack(spacing: 10) {
                    ForEach(store.completedQuests, id: \.quest.id) { pair in
                        HStack(spacing: 12) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 26, height: 26)
                                .background(Circle().fill(pair.quest.category.gradient))

                            VStack(alignment: .leading, spacing: 2) {
                                Text(pair.quest.title)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(Palette.textPrimary)
                                    .lineLimit(2)
                                if let date = pair.progress.completedAt {
                                    Text(date.formatted(date: .abbreviated, time: .omitted))
                                        .font(.system(size: 12))
                                        .foregroundStyle(Palette.textTertiary)
                                }
                            }

                            Spacer(minLength: 8)

                            Text("+\(pair.quest.difficulty.xp)")
                                .font(.system(size: 13, weight: .heavy, design: .rounded))
                                .foregroundStyle(Palette.gold)
                                .monospacedDigit()
                        }
                        .padding(13)
                        .cardChrome(radius: 18)
                    }
                }
            }
        }
    }
}

// MARK: - Stat tile

struct StatTile: View {
    var value: String
    var label: String
    var icon: String
    var tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(tint)

            Text(value)
                .font(.system(size: 26, weight: .heavy, design: .rounded))
                .foregroundStyle(Palette.textPrimary)
                .monospacedDigit()
                .contentTransition(.numericText())

            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Palette.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .cardChrome(radius: 20)
    }
}
