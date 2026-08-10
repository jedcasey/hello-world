# Side Quests — Design Language (Ascent)

One brand, two moods. By day the app is warm morning paper — cream,
peach light, soft shadows. By night it is a luminous indigo sky that
glows rather than broods (Oura, not a cave). Both moods share the same
sunrise-amber accent and the same vivid arena tones, so the app feels
like itself at any hour. Dark mode is never an inversion; it is the same
sunrise seen from the other side.

## Foundations

| Element | Light | Dark | Why |
| --- | --- | --- | --- |
| Ground | Warm cream `#FAF7F1` | Indigo-navy `#0D1120` | Morning paper / luminous night |
| Elevated | White cards, soft warm shadow | 5–10% white over indigo, glow shadows | Paper over paper / light over sky |
| Text | Warm near-black steps | Warm off-white steps | Hierarchy in steps of one tone |
| Accent | Burnt amber `#DE7D21` | Sunrise gold `#F7B859` | Deeper for contrast on cream; luminous on indigo |
| Display type | SF Pro (`.default`), bold, tight tracking | same | Typography does the work |
| Numbers | Rounded + monospaced digits | same | Precision without layout jitter |

The accent is reserved for XP, ranks, and reward moments — scarcity
keeps it meaningful. Chrome is hairlines and gentle fills, never boxes.

## Arena system

Each of the six arenas owns a two-stop vivid gradient and one
golden-hour photograph (generated with Nano Banana 2, single locked
prompt template: an aspirational moment mid-effort, warm low sun,
amber-and-honey palette, real place, no faces readable, 35mm grain).
The gradient colors every ring, bar, and button for that arena's
quests; the photograph IS the arena's identity — circular `ArenaThumb`
medallions and rounded `ArenaTile` squares replace symbol-in-a-circle
iconography everywhere. Film grain (shader) unifies photograph and UI.

- Physical — flame `#FF734D → #E34047` — trail runner on a sunrise ridge
- Mental — indigo `#8778FA → #5E4FDB` — open book in morning sunbeams
- Financial — amber `#FAA838 → #DE7A1C` — seedling growing from a coin jar
- Social — rose `#FA7094 → #D94275` — campfire toast at dusk
- Adventure — emerald `#29BF8C → #0D8C75` — arms raised above a sea of clouds
- Creative — violet `#B870F5 → #8C4ACF` — hands at a potter's wheel in morning light

## Motion vocabulary

Three springs, used everywhere (`Motion.swift`): `spring` (0.42/0.82) for
interface changes, `snappy` (0.30/0.78) for presses and toggles, `bouncy`
(0.52/0.66) for celebration and tab jumps. Nothing animates on a curve the
rest of the app doesn't use.

Signature moves:

- **Aurora** — full-screen fbm shader drifting at 24fps, scheme-aware:
  amber/violet/teal glows breathing through indigo by night; peach and
  honey washes over cream by day.
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
