import Foundation

// MARK: - Category

enum QuestCategory: String, CaseIterable, Codable, Identifiable, Hashable {
    case physical, mental, financial, social, adventure, creative

    var id: String { rawValue }

    var title: String {
        switch self {
        case .physical:  return "Physical"
        case .mental:    return "Mental"
        case .financial: return "Financial"
        case .social:    return "Social"
        case .adventure: return "Adventure"
        case .creative:  return "Creative"
        }
    }

    var tagline: String {
        switch self {
        case .physical:  return "Build a body that obeys you."
        case .mental:    return "Sharpen the blade between your ears."
        case .financial: return "Make money a tool, not a master."
        case .social:    return "Invest in the people who matter."
        case .adventure: return "Collect stories, not stuff."
        case .creative:  return "Make things that didn't exist before you."
        }
    }

    var icon: String {
        switch self {
        case .physical:  return "figure.strengthtraining.traditional"
        case .mental:    return "brain.head.profile"
        case .financial: return "banknote.fill"
        case .social:    return "person.2.fill"
        case .adventure: return "mountain.2.fill"
        case .creative:  return "paintbrush.pointed.fill"
        }
    }
}

// MARK: - Difficulty

enum Difficulty: Int, Codable {
    case tier1 = 1
    case tier2 = 2
    case tier3 = 3

    var label: String {
        switch self {
        case .tier1: return "Tier I"
        case .tier2: return "Tier II"
        case .tier3: return "Tier III"
        }
    }

    var xp: Int {
        switch self {
        case .tier1: return 100
        case .tier2: return 250
        case .tier3: return 500
        }
    }
}

// MARK: - Quest

struct Quest: Identifiable, Codable, Hashable {
    let id: String
    let category: QuestCategory
    let title: String
    let flavor: String
    let target: Int
    let unit: String
    let difficulty: Difficulty

    var isMultiStep: Bool { target > 1 }

    /// Day-cadence quests can only be logged once per calendar day.
    var isDaily: Bool { unit == "days" || unit == "mornings" || unit == "weeks" }

    /// "days" → "day", "sketches" → "sketch", used for the log button label.
    var unitSingular: String {
        if unit.hasSuffix("ches") { return String(unit.dropLast(2)) }
        if unit.hasSuffix("s") { return String(unit.dropLast()) }
        return unit
    }
}

// MARK: - Progress

enum QuestState {
    case available, active, completed
}

struct QuestProgress: Codable, Identifiable {
    let questID: String
    var startedAt: Date
    var logged: [Date] = []
    var completedAt: Date?

    var id: String { questID }
    var count: Int { logged.count }
}

// MARK: - Rank

struct Rank: Equatable {
    let name: String
    let motto: String
    let xpRequired: Int

    static let all: [Rank] = [
        Rank(name: "Drifter",     motto: "Waiting for life to get interesting.",       xpRequired: 0),
        Rank(name: "Wanderer",    motto: "The first steps off the main road.",         xpRequired: 300),
        Rank(name: "Pathfinder",  motto: "Choosing hard things on purpose.",           xpRequired: 900),
        Rank(name: "Trailblazer", motto: "Living a life worth telling stories about.", xpRequired: 2000),
        Rank(name: "Vanguard",    motto: "Others now follow where you walked.",        xpRequired: 4000),
        Rank(name: "Legend",      motto: "The game was worth playing fully.",          xpRequired: 7000),
    ]

    static func rank(for xp: Int) -> Rank {
        all.last(where: { xp >= $0.xpRequired }) ?? all[0]
    }

    static func next(after rank: Rank) -> Rank? {
        guard let idx = all.firstIndex(of: rank), idx + 1 < all.count else { return nil }
        return all[idx + 1]
    }
}

// MARK: - Celebration payload

struct Celebration: Identifiable {
    let id = UUID()
    let quest: Quest
    let xpEarned: Int
    let newRank: Rank?
}

// MARK: - Seeded RNG (stable daily suggestions)

struct SeededRNG: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed &+ 0x9E3779B97F4A7C15
    }

    mutating func next() -> UInt64 {
        state ^= state << 13
        state ^= state >> 7
        state ^= state << 17
        return state
    }
}
