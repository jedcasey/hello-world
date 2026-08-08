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
                            .buttonStyle(PressableStyle())
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 120)
            }
            .scrollIndicators(.hidden)
            .background(AmbientBackground())
            .navigationDestination(for: QuestCategory.self) { category in
                CategoryDetailView(category: category)
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
    }
}

// MARK: - Category card

struct CategoryCard: View {
    @EnvironmentObject private var store: QuestStore
    let category: QuestCategory

    var body: some View {
        let total = QuestLibrary.quests(in: category).count
        let done = store.completedCount(in: category)

        VStack(alignment: .leading, spacing: 0) {
            Image(systemName: category.icon)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 42, height: 42)
                .background(RoundedRectangle(cornerRadius: 13, style: .continuous).fill(category.gradient))
                .shadow(color: category.accent.opacity(0.35), radius: 10, y: 4)

            Spacer(minLength: 14)

            Text(category.title)
                .font(.system(size: 19, weight: .bold, design: .serif))
                .foregroundStyle(Palette.textPrimary)

            Text("\(done) of \(total) complete")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Palette.textSecondary)
                .monospacedDigit()
                .padding(.top, 2)

            XPBar(progress: total > 0 ? Double(done) / Double(total) : 0,
                  colors: category.gradientColors, height: 5)
                .padding(.top, 10)
        }
        .padding(16)
        .frame(height: 158, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Palette.card)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [category.accent.opacity(0.12), .clear],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .strokeBorder(Palette.stroke, lineWidth: 1)
                )
        )
    }
}

// MARK: - Category detail

struct CategoryDetailView: View {
    @EnvironmentObject private var store: QuestStore
    let category: QuestCategory
    @State private var selectedQuest: Quest?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                hero

                VStack(spacing: 10) {
                    ForEach(QuestLibrary.quests(in: category)) { quest in
                        QuestRow(quest: quest) {
                            selectedQuest = quest
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 120)
        }
        .scrollIndicators(.hidden)
        .background(AmbientBackground())
        .toolbarBackground(.hidden, for: .navigationBar)
        .sheet(item: $selectedQuest) { quest in
            QuestDetailView(quest: quest)
        }
    }

    private var hero: some View {
        let total = QuestLibrary.quests(in: category).count
        let done = store.completedCount(in: category)

        return VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 14) {
                Image(systemName: category.icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 54, height: 54)
                    .background(RoundedRectangle(cornerRadius: 17, style: .continuous).fill(category.gradient))
                    .shadow(color: category.accent.opacity(0.4), radius: 14, y: 5)

                VStack(alignment: .leading, spacing: 2) {
                    Text(category.title)
                        .font(.system(size: 30, weight: .bold, design: .serif))
                        .foregroundStyle(Palette.textPrimary)
                    Text(category.tagline)
                        .font(.system(size: 14))
                        .foregroundStyle(Palette.textSecondary)
                }
            }

            HStack(spacing: 10) {
                XPBar(progress: total > 0 ? Double(done) / Double(total) : 0,
                      colors: category.gradientColors, height: 6)
                Text("\(done)/\(total)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Palette.textSecondary)
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
        .buttonStyle(PressableStyle())
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
