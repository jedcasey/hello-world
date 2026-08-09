# Side Quests

> Most men are waiting for life to become interesting. Life becomes interesting the moment you start treating it like a game worth playing fully. Not just the main quest — the side quests.

**Side Quests** is a native iOS app that turns a more meaningful life into a game you actually want to play. Pick real-world challenges across six arenas of life, log honest progress, earn XP, and climb from **Drifter** to **Legend**.

## The six arenas

| Arena | Tagline |
| --- | --- |
| 🏋️ Physical | Build a body that obeys you. |
| 🧠 Mental | Sharpen the blade between your ears. |
| 💰 Financial | Make money a tool, not a master. |
| 🤝 Social | Invest in the people who matter. |
| ⛰️ Adventure | Collect stories, not stuff. |
| 🎨 Creative | Make things that didn't exist before you. |

Sixty hand-curated quests — from *"Run a 5K without stopping"* to *"Host a dinner for people who matter to you"* to *"Cold plunge for 30 days straight."* Some take one decisive act; some take ninety days of showing up.

## Features

- **The quest board** — six arenas, sixty quests, each with difficulty tiers (I–III) and XP rewards
- **Honest progress tracking** — multi-step quests (10 meals, 30 days, 12 books) with per-day logging that locks daily quests until tomorrow
- **XP & ranks** — Drifter → Wanderer → Pathfinder → Trailblazer → Vanguard → Legend, each with its own motto
- **Streaks** — consecutive days of logged progress keep the flame alive
- **Daily calls to adventure** — three suggested quests, freshly picked (deterministically) each day
- **Celebration moments** — confetti, haptics, and rank-up reveals when a quest completes
- **Journey screen** — rank progress, arena mastery bars, lifetime stats, and a trophy log of everything you've finished
- **Considered design** — near-black, typographic “Nightfall” aesthetic; hierarchy in steps of white; dusty per-arena tones; AI-generated night photography with one locked cinematic style; a floating liquid-glass tab bar
- **Custom Metal shaders** — living aurora background, gold shimmer sweeps, film grain over artwork, a completion shockwave, and a glass sheen on the tab bar
- **Gestures & haptics** — swipe-to-log with rubber-banding and particle pops, CoreHaptics crescendos for completion and rank-ups, bouncy spring motion everywhere

## Tech

- SwiftUI, iOS 17+, portrait iPhone
- No dependencies — pure SwiftUI + Foundation + Metal + CoreHaptics
- State persisted locally via `Codable` JSON in `UserDefaults`
- Xcode 16 project (file-system-synchronized groups)
- Arena artwork generated with Nano Banana 2 (Google), one locked prompt template for a consistent studio look
- See `docs/DESIGN.md` for the design language and `docs/ARCHITECTURE.md` for structure

## Running it

1. Open `SideQuests.xcodeproj` in Xcode 16 or newer
2. Select the **SideQuests** scheme and an iPhone simulator (or your device — set your team under Signing & Capabilities)
3. **⌘R**

## Structure

```
SideQuests/
├── SideQuestsApp.swift        # Entry point
├── Models/
│   ├── Models.swift           # Quest, category, difficulty, rank, progress
│   ├── QuestLibrary.swift     # The 60-quest catalog
│   └── QuestStore.swift       # Source of truth + persistence + stats
├── Shaders/
│   └── Shaders.metal          # Aurora, shimmer, grain, shockwave, sheen
├── Theme/
│   ├── Theme.swift            # Palette, gradients, card chrome
│   ├── Motion.swift           # Spring vocabulary + motion modifiers
│   └── HapticsEngine.swift    # CoreHaptics patterns
└── Views/
    ├── RootView.swift         # Shell, floating tab bar, celebration overlay
    ├── OnboardingView.swift   # Manifesto → how it works → arena picker
    ├── HomeView.swift         # Today: rank, streak, active quests, suggestions
    ├── ExploreView.swift      # Quest board + arena detail
    ├── QuestDetailView.swift  # Quest sheet: accept / log / complete / abandon
    ├── JourneyView.swift      # Rank hero, stats, mastery, trophy log
    ├── Components.swift       # Rings, bars, chips, confetti, buttons
    └── Effects/               # Aurora, streamed text, bursts, artwork frame
```
