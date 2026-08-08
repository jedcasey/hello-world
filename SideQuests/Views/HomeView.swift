import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: QuestStore
    @Binding var tab: Tab
    @State private var selectedQuest: Quest?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                header
                rankCard

                if store.activeQuests.isEmpty {
                    emptyState
                } else {
                    activeSection
                }

                suggestionsSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 120)
        }
        .scrollIndicators(.hidden)
        .sheet(item: $selectedQuest) { quest in
            QuestDetailView(quest: quest)
        }
    }

    // MARK: Header

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  return "Good morning."
        case 12..<17: return "Good afternoon."
        case 17..<22: return "Good evening."
        default:      return "Still awake."
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(Date.now.formatted(.dateTime.weekday(.wide).month(.wide).day()))
                .font(.system(size: 13, weight: .bold))
                .tracking(2)
                .textCase(.uppercase)
                .foregroundStyle(Palette.textTertiary)

            Text(greeting)
                .font(.system(size: 38, weight: .bold, design: .serif))
                .foregroundStyle(Palette.textPrimary)

            Text("The day is a quest board. Take something from it.")
                .font(.system(size: 15))
                .foregroundStyle(Palette.textSecondary)
        }
    }

    // MARK: Rank card

    private var rankCard: some View {
        VStack(spacing: 14) {
            HStack(alignment: .center, spacing: 14) {
                Image(systemName: "shield.lefthalf.filled")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Palette.gold)
                    .frame(width: 48, height: 48)
                    .background(Circle().fill(Color.white.opacity(0.06)))

                VStack(alignment: .leading, spacing: 2) {
                    Text(store.rank.name)
                        .font(.system(size: 20, weight: .bold, design: .serif))
                        .foregroundStyle(Palette.textPrimary)
                    if let next = store.nextRank {
                        Text("\(store.totalXP.formatted()) / \(next.xpRequired.formatted()) XP to \(next.name)")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Palette.textSecondary)
                            .monospacedDigit()
                    } else {
                        Text("\(store.totalXP.formatted()) XP — the summit")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Palette.textSecondary)
                    }
                }

                Spacer()

                if store.streak > 0 {
                    VStack(spacing: 1) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 15))
                            .foregroundStyle(QuestCategory.physical.accent)
                        Text("\(store.streak)")
                            .font(.system(size: 15, weight: .heavy, design: .rounded))
                            .foregroundStyle(Palette.textPrimary)
                            .monospacedDigit()
                    }
                    .frame(width: 46, height: 46)
                    .background(Circle().fill(Color.white.opacity(0.06)))
                }
            }

            XPBar(progress: store.rankProgress)
        }
        .padding(18)
        .cardChrome()
    }

    // MARK: Active quests

    private var activeSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "Active quests")

            ForEach(store.activeQuests, id: \.quest.id) { pair in
                ActiveQuestCard(quest: pair.quest, progress: pair.progress) {
                    selectedQuest = pair.quest
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("No active quests")
                .font(.system(size: 22, weight: .bold, design: .serif))
                .foregroundStyle(Palette.textPrimary)

            Text("Boredom is a choice. Pick one thing this week that your future self will thank you for.")
                .font(.system(size: 15))
                .lineSpacing(4)
                .foregroundStyle(Palette.textSecondary)

            PrimaryButton(
                title: "Browse the quest board",
                colors: [Palette.gold, Color(red: 0.87, green: 0.49, blue: 0.16)],
                icon: "map.fill"
            ) {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    tab = .quests
                }
            }
        }
        .padding(20)
        .cardChrome()
    }

    // MARK: Suggestions

    private var suggestionsSection: some View {
        let suggestions = store.suggestions()
        return Group {
            if !suggestions.isEmpty {
                VStack(alignment: .leading, spacing: 14) {
                    SectionHeader(title: "Today's calls to adventure", subtitle: "Three quests chosen for you. New ones tomorrow.")

                    ForEach(suggestions) { quest in
                        SuggestionCard(quest: quest) {
                            selectedQuest = quest
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Active quest card

struct ActiveQuestCard: View {
    @EnvironmentObject private var store: QuestStore
    let quest: Quest
    let progress: QuestProgress
    var onTap: () -> Void

    private var fraction: Double {
        quest.target > 0 ? Double(progress.count) / Double(quest.target) : 0
    }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                ProgressRing(progress: fraction, colors: quest.category.gradientColors, lineWidth: 4.5)
                    .frame(width: 46, height: 46)
                Image(systemName: quest.category.icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(quest.category.accent)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(quest.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Palette.textPrimary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)

                if quest.isMultiStep {
                    Text("\(progress.count) of \(quest.target) \(quest.unit)")
                        .font(.system(size: 13))
                        .foregroundStyle(Palette.textSecondary)
                        .monospacedDigit()
                } else {
                    Text(quest.category.title)
                        .font(.system(size: 13))
                        .foregroundStyle(Palette.textSecondary)
                }
            }

            Spacer(minLength: 8)

            logButton
        }
        .padding(14)
        .cardChrome(radius: 22)
        .contentShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .onTapGesture(perform: onTap)
    }

    private var logButton: some View {
        let doneToday = store.loggedToday(quest)
        return Button {
            store.logStep(quest)
        } label: {
            Image(systemName: doneToday ? "checkmark" : "plus")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(doneToday ? quest.category.accent : .white)
                .frame(width: 40, height: 40)
                .background(
                    Circle().fill(
                        doneToday
                            ? AnyShapeStyle(Color.white.opacity(0.07))
                            : AnyShapeStyle(quest.category.gradient)
                    )
                )
        }
        .buttonStyle(PressableStyle())
        .disabled(doneToday)
    }
}

// MARK: - Suggestion card

struct SuggestionCard: View {
    let quest: Quest
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                Image(systemName: quest.category.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(quest.category.gradient))

                VStack(alignment: .leading, spacing: 3) {
                    Text(quest.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Palette.textPrimary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                    HStack(spacing: 8) {
                        Text(quest.category.title)
                            .font(.system(size: 13))
                            .foregroundStyle(Palette.textSecondary)
                        TierDots(difficulty: quest.difficulty)
                        Text("+\(quest.difficulty.xp) XP")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Palette.gold)
                            .monospacedDigit()
                    }
                }

                Spacer(minLength: 8)

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Palette.textTertiary)
            }
            .padding(14)
            .cardChrome(radius: 22)
        }
        .buttonStyle(PressableStyle())
    }
}
