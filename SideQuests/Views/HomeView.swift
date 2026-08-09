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
                .font(.system(size: 38, weight: .bold, design: .default))
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
                    .background(Circle().fill(Palette.accentSoft))

                VStack(alignment: .leading, spacing: 2) {
                    Text(store.rank.name)
                        .font(.system(size: 20, weight: .bold, design: .default))
                        .foregroundStyle(Palette.textPrimary)
                    if let next = store.nextRank {
                        Text("\(store.totalXP.formatted()) / \(next.xpRequired.formatted()) XP to \(next.name)")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Palette.textSecondary)
                            .monospacedDigit()
                            .contentTransition(.numericText(value: Double(store.totalXP)))
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
                            .symbolEffect(.variableColor.iterative, options: .repeating)
                        Text("\(store.streak)")
                            .font(.system(size: 15, weight: .heavy, design: .rounded))
                            .foregroundStyle(Palette.textPrimary)
                            .monospacedDigit()
                            .contentTransition(.numericText(value: Double(store.streak)))
                    }
                    .frame(width: 46, height: 46)
                    .background(Circle().fill(Palette.accentSoft))
                }
            }

            XPBar(progress: store.rankProgress)
                .shimmer()
        }
        .padding(18)
        .cardChrome()
        .animation(Motion.spring, value: store.totalXP)
        .animation(Motion.spring, value: store.streak)
    }

    // MARK: Active quests

    private var activeSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "Active quests", subtitle: "Swipe a quest to log progress.")

            ForEach(store.activeQuests, id: \.quest.id) { pair in
                ActiveQuestCard(quest: pair.quest, progress: pair.progress) {
                    selectedQuest = pair.quest
                }
                .scrollEntrance()
            }
        }
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("No active quests")
                .font(.system(size: 22, weight: .bold, design: .default))
                .foregroundStyle(Palette.textPrimary)

            Text("Boredom is a choice. Pick one thing this week that your future self will thank you for.")
                .font(.system(size: 15))
                .lineSpacing(4)
                .foregroundStyle(Palette.textSecondary)

            PrimaryButton(
                title: "Browse the quest board",
                colors: [Palette.gold, Palette.goldDeep],
                icon: "map.fill"
            ) {
                withAnimation(Motion.bouncy) {
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
                        .scrollEntrance()
                    }
                }
            }
        }
    }
}

// MARK: - Active quest card
// Tap opens the quest. Swiping right drags the card against a spring and,
// past the threshold, logs a step with a particle pop — progress without
// ever leaving the home screen.

struct ActiveQuestCard: View {
    @EnvironmentObject private var store: QuestStore
    let quest: Quest
    let progress: QuestProgress
    var onTap: () -> Void

    @State private var dragX: CGFloat = 0
    @State private var armed = false
    @State private var burst = 0

    private let threshold: CGFloat = 72

    private var fraction: Double {
        quest.target > 0 ? Double(progress.count) / Double(quest.target) : 0
    }

    private var canLog: Bool {
        !store.loggedToday(quest)
    }

    var body: some View {
        ZStack(alignment: .leading) {
            swipeHint

            cardBody
                .offset(x: dragX)
                .contentShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .onTapGesture(perform: onTap)
        }
        .gesture(logSwipe)
    }

    private var cardBody: some View {
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
                        .contentTransition(.numericText(value: Double(progress.count)))
                } else {
                    Text(quest.category.title)
                        .font(.system(size: 13))
                        .foregroundStyle(Palette.textSecondary)
                }
            }

            Spacer(minLength: 8)

            logButton
                .overlay(PopBurst(trigger: burst, colors: quest.category.gradientColors))
        }
        .padding(14)
        .cardChrome(radius: 22)
        .animation(Motion.spring, value: progress.count)
    }

    private var logButton: some View {
        Button {
            guard canLog else { return }
            burst += 1
            store.logStep(quest)
        } label: {
            Image(systemName: canLog ? "plus" : "checkmark")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(canLog ? .white : quest.category.accent)
                .contentTransition(.symbolEffect(.replace))
                .frame(width: 40, height: 40)
                .background(
                    Circle().fill(
                        canLog
                            ? AnyShapeStyle(quest.category.gradient)
                            : AnyShapeStyle(Palette.fillStrong)
                    )
                )
        }
        .buttonStyle(PressableStyle())
        .disabled(!canLog)
    }

    private var swipeHint: some View {
        HStack(spacing: 6) {
            Image(systemName: armed ? "checkmark.circle.fill" : "plus.circle")
                .font(.system(size: 20, weight: .semibold))
                .contentTransition(.symbolEffect(.replace))
            Text("+1")
                .font(.system(size: 15, weight: .heavy, design: .rounded))
        }
        .foregroundStyle(quest.category.accent)
        .opacity(min(1, dragX / threshold))
        .scaleEffect(armed ? 1.15 : 1, anchor: .leading)
        .padding(.leading, 6)
        .animation(Motion.snappy, value: armed)
    }

    private var logSwipe: some Gesture {
        DragGesture(minimumDistance: 24)
            .onChanged { value in
                guard canLog,
                      abs(value.translation.width) > abs(value.translation.height) * 1.2,
                      value.translation.width > 0
                else { return }

                let x = value.translation.width
                // Rubber band past the threshold so the card feels alive.
                dragX = x <= threshold ? x : threshold + (x - threshold) * 0.3

                if dragX >= threshold && !armed {
                    armed = true
                    Haptics.medium()
                } else if dragX < threshold && armed {
                    armed = false
                }
            }
            .onEnded { _ in
                if armed && canLog {
                    burst += 1
                    store.logStep(quest)
                }
                armed = false
                withAnimation(Motion.snappy) { dragX = 0 }
            }
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
        .buttonStyle(CardPressStyle())
    }
}
