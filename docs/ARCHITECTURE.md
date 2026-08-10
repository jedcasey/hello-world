# Side Quests — Architecture

Pure SwiftUI, iOS 17+, no third-party dependencies. One module, small and
deliberate.

## Layers

```
Models/          Value types + the single source of truth
  Models.swift        Quest, QuestCategory, Difficulty, QuestProgress,
                      Rank, Celebration, SeededRNG
  QuestLibrary.swift  The 60-quest catalog (static data, id-stable slugs)
  QuestStore.swift    ObservableObject: lifecycle (accept/log/abandon),
                      persistence, derived stats (XP, rank, streak,
                      per-arena mastery, daily suggestions)

Theme/           Design tokens and cross-cutting feel
  Theme.swift         Palette, arena gradients, card chrome
  Motion.swift        Spring vocabulary, shimmer/grain/scroll/breathe
                      modifiers, press styles
  HapticsEngine.swift CoreHaptics conductor + pattern vocabulary

Shaders/         Metal, compiled into the app's default shader library
  Shaders.metal       aurora, shimmer, filmGrain, shockwave, glassSheen

Views/
  RootView.swift      App shell, tab switching, celebration overlay routing
  Effects/            Reusable effect views (AuroraBackground, StreamedText,
                      PopBurst, ArenaImage)
  + one file per screen, components colocated with their screen
```

## Data flow

`QuestStore` is injected once as an `@EnvironmentObject`. Views never
mutate progress directly — they call intent methods (`accept`, `logStep`,
`abandon`, `completeOnboarding`), and every derived number (rank, streak,
mastery) is computed from the single `progress` dictionary, so the UI can
never disagree with itself.

Completion is event-shaped: `logStep` detects target-reached, captures
rank-before/rank-after, and publishes a `Celebration` value. `RootView`
renders it as an overlay; the quest sheet observes the same signal and
dismisses itself so the overlay is never hidden behind a presentation layer.

Persistence is a versioned JSON blob in `UserDefaults`
(`sidequests.state.v1`) — right-sized for a catalog of 60 quests whose
progress is a list of dates. Swap for SwiftData/CloudKit behind the same
store API if sync is ever needed.

## Shader integration pattern

Every shader is wrapped in a modifier or effect view that owns its own
`TimelineView` clock and respects Reduce Motion:

```swift
TimelineView(.animation(minimumInterval: 1/30)) { timeline in
    let t = timeline.date.timeIntervalSince(start)
    content.visualEffect { view, proxy in
        view.colorEffect(ShaderLibrary.shimmer(.float2(proxy.size), .float(t)))
    }
}
```

Frame budgets are chosen per effect: aurora 24fps, sheen 20fps, shimmer
30fps, shockwave/confetti 60fps for the moments that deserve it.

## Determinism

Daily suggestions and confetti both use `SeededRNG` (xorshift) so a given
day always suggests the same quests and particle layouts are stable across
re-renders. No global randomness.

## The artwork pipeline

Arena photographs were generated with Nano Banana 2 (Google) through the
Higgsfield MCP integration using one locked prompt template per arena
(see docs/DESIGN.md). A one-shot CI workflow downloaded, resized (≤1024px,
JPEG q85) and committed them into the asset catalog; the workflow was
removed after the art landed. In-app, `ArenaImage` adds film grain, a
legibility scrim, and a 16s breathing zoom so photography and UI share
one finish.
