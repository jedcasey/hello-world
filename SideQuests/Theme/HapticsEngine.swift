import CoreHaptics
import UIKit

/// Haptic vocabulary for the whole app.
///
/// Backed by CoreHaptics for composed patterns (quest completion crescendo,
/// rank-up swell); falls back to UIKit feedback generators on hardware
/// without haptic engine support.
enum Haptics {

    // MARK: Simple taps

    static func light()  { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
    static func medium() { UIImpactFeedbackGenerator(style: .medium).impactOccurred() }
    static func success() { UINotificationFeedbackGenerator().notificationOccurred(.success) }

    /// A crisp double-tick when a progress step is logged.
    static func logStep() {
        guard let engine = Conductor.shared.engine else {
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
            return
        }
        let events = [
            transient(time: 0.00, intensity: 0.70, sharpness: 0.65),
            transient(time: 0.09, intensity: 0.45, sharpness: 0.85),
        ]
        Conductor.shared.play(events, on: engine)
    }

    /// Rising crescendo: quick ascending transients into a soft swell.
    static func questComplete() {
        guard let engine = Conductor.shared.engine else {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            return
        }
        var events: [CHHapticEvent] = []
        for i in 0..<5 {
            events.append(transient(
                time: Double(i) * 0.07,
                intensity: 0.35 + Double(i) * 0.15,
                sharpness: 0.3 + Double(i) * 0.12
            ))
        }
        events.append(CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.25),
            ],
            relativeTime: 0.38,
            duration: 0.5
        ))
        Conductor.shared.play(events, on: engine)
    }

    /// The big one: long swell that lands on a heavy strike.
    static func rankUp() {
        guard let engine = Conductor.shared.engine else {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            return
        }
        var events: [CHHapticEvent] = [
            CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.55),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2),
                ],
                relativeTime: 0,
                duration: 0.7
            ),
        ]
        events.append(transient(time: 0.75, intensity: 1.0, sharpness: 0.55))
        events.append(transient(time: 0.88, intensity: 0.6, sharpness: 0.9))
        Conductor.shared.play(events, on: engine)
    }

    // MARK: Internals

    private static func transient(time: TimeInterval, intensity: Double, sharpness: Double) -> CHHapticEvent {
        CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(intensity)),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: Float(sharpness)),
            ],
            relativeTime: time
        )
    }

    private final class Conductor {
        static let shared = Conductor()
        let engine: CHHapticEngine?

        init() {
            guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
                engine = nil
                return
            }
            engine = try? CHHapticEngine()
            engine?.isAutoShutdownEnabled = true
            engine?.resetHandler = { [weak engine] in
                try? engine?.start()
            }
        }

        func play(_ events: [CHHapticEvent], on engine: CHHapticEngine) {
            do {
                try engine.start()
                let pattern = try CHHapticPattern(events: events, parameters: [])
                let player = try engine.makePlayer(with: pattern)
                try player.start(atTime: CHHapticTimeImmediate)
            } catch {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }
        }
    }
}
