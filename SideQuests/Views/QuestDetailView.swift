import SwiftUI

struct QuestDetailView: View {
    @EnvironmentObject private var store: QuestStore
    @Environment(\.dismiss) private var dismiss
    let quest: Quest

    @State private var confirmingAbandon = false

    var body: some View {
        ScrollView {
            VStack(spacing: 26) {
                hero
                metaChips
                statusSection
            }
            .padding(.horizontal, 24)
            .padding(.top, 34)
            .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
        .background(
            ZStack {
                Palette.bgElevated
                RadialGradient(
                    colors: [quest.category.accent.opacity(0.16), .clear],
                    center: .top, startRadius: 10, endRadius: 420
                )
            }
            .ignoresSafeArea()
        )
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .confirmationDialog(
            "Abandon this quest?",
            isPresented: $confirmingAbandon,
            titleVisibility: .visible
        ) {
            Button("Abandon quest", role: .destructive) {
                store.abandon(quest)
                dismiss()
            }
            Button("Keep going", role: .cancel) {}
        } message: {
            Text("Your progress will be lost. The quest returns to the board.")
        }
    }

    // MARK: Hero

    private var hero: some View {
        VStack(spacing: 16) {
            Image(systemName: quest.category.icon)
                .font(.system(size: 30, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 84, height: 84)
                .background(Circle().fill(quest.category.gradient))
                .shadow(color: quest.category.accent.opacity(0.45), radius: 22, y: 6)

            Text(quest.category.title)
                .font(.system(size: 12, weight: .bold))
                .tracking(3)
                .textCase(.uppercase)
                .foregroundStyle(quest.category.accent)

            Text(quest.title)
                .font(.system(size: 28, weight: .bold, design: .serif))
                .foregroundStyle(Palette.textPrimary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Text(quest.flavor)
                .font(.system(size: 16))
                .lineSpacing(5)
                .foregroundStyle(Palette.textSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var metaChips: some View {
        HStack(spacing: 8) {
            Chip(text: quest.difficulty.label, icon: "bolt.fill", tint: quest.category.accent)
            Chip(text: "+\(quest.difficulty.xp) XP", icon: "sparkles", tint: Palette.gold)
            if quest.isMultiStep {
                Chip(text: "\(quest.target) \(quest.unit)", icon: "target")
            } else {
                Chip(text: "One decisive act", icon: "target")
            }
        }
    }

    // MARK: Status

    @ViewBuilder
    private var statusSection: some View {
        switch store.state(of: quest) {
        case .available:
            availableSection
        case .active:
            activeSection
        case .completed:
            completedSection
        }
    }

    private var availableSection: some View {
        VStack(spacing: 12) {
            PrimaryButton(title: "Accept quest", colors: quest.category.gradientColors, icon: "scroll.fill") {
                store.accept(quest)
            }
            Text("Accepting a quest is a promise to yourself.")
                .font(.system(size: 13))
                .foregroundStyle(Palette.textTertiary)
        }
        .padding(.top, 6)
    }

    private var activeSection: some View {
        let progress = store.progress(of: quest)
        let count = progress?.count ?? 0
        let fraction = quest.target > 0 ? Double(count) / Double(quest.target) : 0
        let doneToday = store.loggedToday(quest)

        return VStack(spacing: 20) {
            if quest.isMultiStep {
                ZStack {
                    ProgressRing(progress: fraction, colors: quest.category.gradientColors, lineWidth: 9)
                        .frame(width: 132, height: 132)
                    VStack(spacing: 2) {
                        Text("\(count)")
                            .font(.system(size: 38, weight: .heavy, design: .rounded))
                            .foregroundStyle(Palette.textPrimary)
                            .monospacedDigit()
                        Text("of \(quest.target) \(quest.unit)")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Palette.textSecondary)
                    }
                }
                .padding(.top, 4)

                PrimaryButton(
                    title: doneToday ? "Logged — come back tomorrow" : "Log a \(quest.unitSingular)",
                    colors: quest.category.gradientColors,
                    icon: doneToday ? "checkmark" : "plus",
                    disabled: doneToday
                ) {
                    store.logStep(quest)
                }
            } else {
                PrimaryButton(title: "Mark complete", colors: quest.category.gradientColors, icon: "checkmark") {
                    store.logStep(quest)
                }
                Text("Only you know if it truly counts. Be honest.")
                    .font(.system(size: 13))
                    .foregroundStyle(Palette.textTertiary)
            }

            Button {
                confirmingAbandon = true
            } label: {
                Text("Abandon quest")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Palette.textTertiary)
            }
            .buttonStyle(.plain)
            .padding(.top, 2)
        }
        .padding(.top, 6)
    }

    private var completedSection: some View {
        let completedAt = store.progress(of: quest)?.completedAt

        return VStack(spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(Palette.gold)
                VStack(alignment: .leading, spacing: 1) {
                    Text("Quest complete")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Palette.textPrimary)
                    if let completedAt {
                        Text(completedAt.formatted(date: .abbreviated, time: .omitted) + " · +\(quest.difficulty.xp) XP")
                            .font(.system(size: 13))
                            .foregroundStyle(Palette.textSecondary)
                    }
                }
                Spacer()
            }
            .padding(16)
            .cardChrome(radius: 20, fill: Palette.cardStrong)

            Text("This one is part of your story now.")
                .font(.system(size: 13))
                .foregroundStyle(Palette.textTertiary)
        }
        .padding(.top, 6)
    }
}
