# Side Quests — Design Language

The app should feel like a beautifully bound book about your own life: dark,
editorial, a little mythic. Every choice below serves that.

## Foundations

| Element | Choice | Why |
| --- | --- | --- |
| Ground | Near-black `#0A0B0E` with a living aurora shader | Depth without decoration; the app breathes |
| Display type | New York serif (`.serif`), bold | Stoic, editorial gravity for titles and rank names |
| Body type | SF Pro, 13–17pt | Quiet, legible counterpoint |
| Numbers | Rounded + monospaced digits | Game-y warmth, no layout jitter |
| Chrome | 4.5% white cards, 9% white hairlines, 20–24pt continuous radii | Surfaces feel milled, not drawn |
| Gold `#F0B854` | Reserved for XP, rank, and reward moments | Scarcity keeps it meaningful |

## Arena system

Each of the six arenas owns a two-stop gradient and one studio photograph
(generated with Nano Banana 2, single locked prompt template: charcoal
backdrop, golden key light upper-left, arena-accent glow right, haze).
The gradient colors every ring, bar, icon, and button for that arena's
quests; the photograph carries the card, the arena hero, and the quest
sheet backdrop. Film grain (shader) unifies photograph and UI.

- Physical — ember `#FF7038 → #E13042` — kettlebell and chalk dust
- Mental — indigo `#807AFF → #4D3DDB` — marble knight on old books
- Financial — gold `#FAC24D → #DB8721` — stacked antique coins
- Social — rose `#FF7590 → #D63873` — two glasses mid-toast
- Adventure — emerald `#38D99C → #1A9680` — brass compass on leather
- Creative — violet `#C773FF → #8245E6` — brush lifting molten gold

## Motion vocabulary

Three springs, used everywhere (`Motion.swift`): `spring` (0.42/0.82) for
interface changes, `snappy` (0.30/0.78) for presses and toggles, `bouncy`
(0.52/0.66) for celebration and tab jumps. Nothing animates on a curve the
rest of the app doesn't use.

Signature moves:

- **Aurora** — full-screen fbm shader drifting at 24fps; violet, ember and
  teal breathing through near-black.
- **Shimmer** — a specular band sweeps gold surfaces every 3.6s.
- **Glass sheen** — the tab bar is material + a shader that plays a bright
  top edge and a slow drifting highlight across it, like light on curved glass.
- **Shockwave** — the instant a quest completes, a radial distortion ripples
  through the celebration card (Metal `distortionEffect`).
- **Streamed text** — quest flavor arrives word by word, like a thought.
- **Scroll entrance** — cards fade/scale/deblur into the viewport.
- **Stretchy hero** — arena detail photographs stretch on overscroll.
- **Swipe to log** — drag an active quest right; rubber-bands, arms at 72pt
  with a medium haptic, releases into a particle pop and a logged step.

All continuous shader motion falls back to static equivalents under
Reduce Motion.

## Haptic vocabulary

CoreHaptics patterns (`HapticsEngine.swift`), UIKit fallbacks everywhere:

- `logStep` — crisp double-tick (0.70 then 0.45 intensity, 90ms apart)
- `questComplete` — five ascending transients into a 0.5s swell
- `rankUp` — long swell landing on a heavy strike and a bright after-tap
- `light/medium` — navigation and arming gestures

## Celebration choreography

1. Sheet (if any) dismisses itself; overlay fades in over 0.3s.
2. Card scales 0.85 → 1 on a 0.45/0.75 spring; shockwave ripples outward.
3. Confetti (110 seeded particles, category + gold palette) falls.
4. XP counts up from 0 with `numericText` after a 0.35s delay.
5. Haptic crescendo — `rankUp` if a rank boundary was crossed.
6. Rank-up card, when present, carries the new rank's motto.

## Voice

Second person, declarative, no exclamation marks, no emoji in-product.
The app talks like a laconic mentor: "Accepting a quest is a promise to
yourself." · "Only you know if it truly counts. Be honest." · "The clock
on this one is real."
