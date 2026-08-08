import Foundation
import SwiftUI

/// Single source of truth for the player's journey. Persists to UserDefaults as JSON.
final class QuestStore: ObservableObject {

    @Published private(set) var progress: [String: QuestProgress] = [:]
    @Published private(set) var hasOnboarded: Bool = false
    @Published private(set) var focus: Set<QuestCategory> = []
    @Published var celebration: Celebration?

    private let saveKey = "sidequests.state.v1"

    private struct Persisted: Codable {
        var progress: [String: QuestProgress]
        var hasOnboarded: Bool
        var focus: [QuestCategory]
    }

    init() {
        load()
    }

    // MARK: - Persistence

    private func load() {
        guard
            let data = UserDefaults.standard.data(forKey: saveKey),
            let state = try? JSONDecoder().decode(Persisted.self, from: data)
        else { return }
        progress = state.progress
        hasOnboarded = state.hasOnboarded
        focus = Set(state.focus)
    }

    private func save() {
        let state = Persisted(progress: progress, hasOnboarded: hasOnboarded, focus: Array(focus))
        if let data = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(data, forKey: saveKey)
        }
    }

    // MARK: - Onboarding

    func completeOnboarding(focus: Set<QuestCategory>) {
        self.focus = focus
        hasOnboarded = true
        save()
    }

    // MARK: - Quest lifecycle

    func state(of quest: Quest) -> QuestState {
        guard let p = progress[quest.id] else { return .available }
        return p.completedAt == nil ? .active : .completed
    }

    func progress(of quest: Quest) -> QuestProgress? {
        progress[quest.id]
    }

    func accept(_ quest: Quest) {
        guard progress[quest.id] == nil else { return }
        progress[quest.id] = QuestProgress(questID: quest.id, startedAt: Date())
        save()
        Haptics.medium()
    }

    func abandon(_ quest: Quest) {
        guard let p = progress[quest.id], p.completedAt == nil else { return }
        progress[quest.id] = nil
        save()
        Haptics.light()
    }

    /// True when a daily-cadence quest has already been logged today.
    func loggedToday(_ quest: Quest) -> Bool {
        guard quest.isDaily, let p = progress[quest.id], let last = p.logged.last else { return false }
        return Calendar.current.isDateInToday(last)
    }

    func logStep(_ quest: Quest) {
        guard var p = progress[quest.id], p.completedAt == nil else { return }
        if quest.isDaily && loggedToday(quest) { return }

        let rankBefore = rank
        p.logged.append(Date())

        if p.count >= quest.target {
            p.completedAt = Date()
            progress[quest.id] = p
            let rankAfter = rank
            celebration = Celebration(
                quest: quest,
                xpEarned: quest.difficulty.xp,
                newRank: rankAfter != rankBefore ? rankAfter : nil
            )
            Haptics.success()
        } else {
            progress[quest.id] = p
            Haptics.light()
        }
        save()
    }

    // MARK: - Derived stats

    var activeQuests: [(quest: Quest, progress: QuestProgress)] {
        progress.values
            .filter { $0.completedAt == nil }
            .compactMap { p in QuestLibrary.quest(id: p.questID).map { ($0, p) } }
            .sorted { $0.1.startedAt > $1.1.startedAt }
    }

    var completedQuests: [(quest: Quest, progress: QuestProgress)] {
        progress.values
            .filter { $0.completedAt != nil }
            .compactMap { p in QuestLibrary.quest(id: p.questID).map { ($0, p) } }
            .sorted { ($0.1.completedAt ?? .distantPast) > ($1.1.completedAt ?? .distantPast) }
    }

    var totalXP: Int {
        completedQuests.reduce(0) { $0 + $1.quest.difficulty.xp }
    }

    var rank: Rank { Rank.rank(for: totalXP) }

    var nextRank: Rank? { Rank.next(after: rank) }

    /// Progress from the current rank threshold toward the next, 0...1.
    var rankProgress: Double {
        guard let next = nextRank else { return 1 }
        let span = Double(next.xpRequired - rank.xpRequired)
        guard span > 0 else { return 1 }
        return min(1, Double(totalXP - rank.xpRequired) / span)
    }

    /// Consecutive days (ending today or yesterday) with at least one logged step.
    var streak: Int {
        let cal = Calendar.current
        let days = Set(progress.values.flatMap { $0.logged }.map { cal.startOfDay(for: $0) })
        guard !days.isEmpty else { return 0 }

        var day = cal.startOfDay(for: Date())
        if !days.contains(day) {
            guard let yesterday = cal.date(byAdding: .day, value: -1, to: day),
                  days.contains(yesterday) else { return 0 }
            day = yesterday
        }
        var count = 0
        while days.contains(day) {
            count += 1
            guard let previous = cal.date(byAdding: .day, value: -1, to: day) else { break }
            day = previous
        }
        return count
    }

    func completedCount(in category: QuestCategory) -> Int {
        completedQuests.filter { $0.quest.category == category }.count
    }

    /// Three quests to nudge the player toward today. Stable for a given day.
    func suggestions(count: Int = 3) -> [Quest] {
        var pool = QuestLibrary.all.filter { state(of: $0) == .available }
        if !focus.isEmpty {
            let focused = pool.filter { focus.contains($0.category) }
            if focused.count >= count { pool = focused }
        }
        guard !pool.isEmpty else { return [] }
        let day = Calendar.current.ordinality(of: .day, in: .era, for: Date()) ?? 1
        var rng = SeededRNG(seed: UInt64(day))
        return Array(pool.shuffled(using: &rng).prefix(count))
    }
}
