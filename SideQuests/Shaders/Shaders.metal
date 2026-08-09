//
//  Shaders.metal
//  SideQuests
//
//  SwiftUI shader effects: aurora background, gold shimmer, film grain,
//  celebration shockwave, and the tab bar's glass sheen.
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

// MARK: - Noise helpers

static float hash21(float2 p) {
    p = fract(p * float2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

static float vnoise(float2 p) {
    float2 i = floor(p);
    float2 f = fract(p);
    float2 u = f * f * (3.0 - 2.0 * f);
    float a = hash21(i);
    float b = hash21(i + float2(1.0, 0.0));
    float c = hash21(i + float2(0.0, 1.0));
    float d = hash21(i + float2(1.0, 1.0));
    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

static float fbm(float2 p) {
    float v = 0.0;
    float a = 0.5;
    for (int i = 0; i < 4; i++) {
        v += a * vnoise(p);
        p = p * 2.03 + float2(17.3, 9.1);
        a *= 0.5;
    }
    return v;
}

// MARK: - Aurora
// Daybreak: slow-drifting morning light over warm ivory — amber sun, a blush
// of rose, and a whisper of airy violet. Applied as a colorEffect on a
// full-screen rectangle.

[[ stitchable ]] half4 aurora(float2 position, half4 color, float2 size, float time) {
    float2 uv = position / max(size.x, size.y);
    float t = time * 0.03;

    float n1 = fbm(uv * 1.8 + float2(t, -t * 0.6));
    float n2 = fbm(uv * 2.6 + float2(-t * 0.8, t * 0.5) + 4.7);
    float n3 = fbm(uv * 2.2 - t);

    half3 c = half3(0.984h, 0.978h, 0.960h);
    c = mix(c, half3(1.00h, 0.85h, 0.62h), half(smoothstep(0.55, 0.95, n1)) * 0.30h);
    c = mix(c, half3(1.00h, 0.80h, 0.76h), half(smoothstep(0.60, 1.00, n2)) * 0.18h);
    c = mix(c, half3(0.88h, 0.88h, 1.00h), half(smoothstep(0.70, 1.05, n3)) * 0.12h);

    // Gentle vignette so edges settle into deeper cream.
    float2 centered = position / size - 0.5;
    c *= half(1.0 - dot(centered, centered) * 0.10);

    return half4(c, color.a);
}

// MARK: - Shimmer
// A soft diagonal specular band that sweeps across gold surfaces every few seconds.

[[ stitchable ]] half4 shimmer(float2 position, half4 color, float2 size, float time) {
    if (color.a < 0.01h) { return color; }

    float period = 3.6;
    float phase = fmod(time, period) / period;      // 0...1
    float sweep = phase * 2.2 - 0.6;                // travel past both edges

    float2 uv = position / size;
    float d = uv.x * 0.8 + uv.y * 0.2 - sweep;
    float band = exp(-d * d * 260.0);

    half3 boosted = color.rgb + half3(1.00h, 0.92h, 0.70h) * half(band * 0.45) * color.a;
    return half4(boosted, color.a);
}

// MARK: - Film grain
// Static (or animated) photographic grain, used to unify generated artwork.

[[ stitchable ]] half4 filmGrain(float2 position, half4 color, float time, float amount) {
    float g = hash21(position + fract(time) * 100.0) - 0.5;
    half3 c = color.rgb + half(g * amount);
    return half4(c, color.a);
}

// MARK: - Shockwave
// Radial ripple used the instant a quest completes. `progress` runs 0 -> ~1.2,
// `amplitude` is in points (0 disables).

[[ stitchable ]] float2 shockwave(float2 position, float2 size, float progress, float amplitude) {
    if (amplitude < 0.5) { return position; }

    float2 center = size * 0.5;
    float2 d = position - center;
    float r = length(d);
    float maxR = length(size) * 0.5;

    float waveR = progress * maxR * 1.6;
    float x = (r - waveR) / 60.0;
    float fall = exp(-x * x);
    float decay = exp(-progress * 2.2);

    float2 dir = r > 0.001 ? d / r : float2(0.0, 0.0);
    return position + dir * fall * amplitude * decay;
}

// MARK: - Glass sheen
// Specular life for the floating tab bar: a bright top edge plus a slow
// drifting soft highlight, as if light were playing across curved glass.

[[ stitchable ]] half4 glassSheen(float2 position, half4 color, float2 size, float time) {
    float2 uv = position / size;

    float top = exp(-uv.y * uv.y * 18.0) * 0.30;

    float s = sin(time * 0.5);
    float d = uv.x - (0.5 + s * 0.42);
    float blob = exp(-d * d * 9.0) * 0.16 * (0.6 + 0.4 * sin(time * 0.5 + 1.7));

    half boost = half(top + blob);
    return half4(color.rgb + boost * color.a, color.a);
}
