import SwiftUI

enum Tab: String, CaseIterable {
    case today, quests, journey

    var title: String {
        switch self {
        case .today:   return "Today"
        case .quests:  return "Quests"
        case .journey: return "Journey"
        }
    }

    var icon: String {
        switch self {
        case .today:   return "flame.fill"
        case .quests:  return "map.fill"
        case .journey: return "medal.fill"
        }
    }
}

struct RootView: View {
    @EnvironmentObject private var store: QuestStore
    @State private var tab: Tab = .today

    var body: some View {
        ZStack {
            AuroraBackground()

            if store.hasOnboarded {
                ZStack(alignment: .bottom) {
                    Group {
                        switch tab {
                        case .today:   HomeView(tab: $tab)
                        case .quests:  ExploreView()
                        case .journey: JourneyView()
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                    TabBar(selection: $tab)
                        .padding(.bottom, 6)
                }
            } else {
                OnboardingView()
            }

            if let celebration = store.celebration {
                CelebrationView(celebration: celebration)
                    .transition(.opacity)
                    .zIndex(10)
            }
        }
        .animation(.easeOut(duration: 0.3), value: store.celebration?.id)
        .animation(.easeOut(duration: 0.4), value: store.hasOnboarded)
        .preferredColorScheme(.light)
    }
}

// MARK: - Floating liquid-glass tab bar

struct TabBar: View {
    @Binding var selection: Tab
    @Namespace private var pill
    @State private var start = Date()

    var body: some View {
        HStack(spacing: 4) {
            ForEach(Tab.allCases, id: \.self) { tab in
                let isSelected = tab == selection
                Button {
                    guard selection != tab else { return }
                    withAnimation(Motion.bouncy) {
                        selection = tab
                    }
                    Haptics.light()
                } label: {
                    HStack(spacing: 7) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 15, weight: .semibold))
                            .symbolEffect(.bounce, value: isSelected)
                        if isSelected {
                            Text(tab.title)
                                .font(.system(size: 14, weight: .bold))
                                .fixedSize()
                        }
                    }
                    .foregroundStyle(isSelected ? Palette.gold : Palette.textTertiary)
                    .padding(.horizontal, isSelected ? 18 : 14)
                    .padding(.vertical, 12)
                    .background {
                        if isSelected {
                            Capsule()
                                .fill(Palette.fill)
                                .shadow(color: Palette.gold.opacity(0.25), radius: 12)
                                .matchedGeometryEffect(id: "pill", in: pill)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(5)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay {
            // Living specular pass over the glass, clipped to the capsule.
            TimelineView(.animation(minimumInterval: 1.0 / 20.0)) { timeline in
                let t = timeline.date.timeIntervalSince(start)
                Capsule()
                    .fill(Color.white.opacity(0.055))
                    .visualEffect { view, proxy in
                        view.colorEffect(
                            ShaderLibrary.glassSheen(
                                .float2(proxy.size),
                                .float(t)
                            )
                        )
                    }
                    .allowsHitTesting(false)
            }
        }
        .overlay(Capsule().strokeBorder(Palette.stroke, lineWidth: 1))
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.12), radius: 20, y: 8)
    }
}

// MARK: - Celebration overlay

struct CelebrationView: View {
    @EnvironmentObject private var store: QuestStore
    let celebration: Celebration

    @State private var appeared = false
    @State private var shownAt = Date()
    @State private var xpShown = 0

    var body: some View {
        ZStack {
            Color.black.opacity(0.35).ignoresSafeArea()
            ConfettiView().ignoresSafeArea()

            TimelineView(.animation(minimumInterval: 1.0 / 60.0)) { timeline in
                let t = timeline.date.timeIntervalSince(shownAt)
                card
                    .visualEffect { view, proxy in
                        view.distortionEffect(
                            ShaderLibrary.shockwave(
                                .float2(proxy.size),
                                .float(min(1.3, t)),
                                .float(t < 1.3 ? 24 : 0)
                            ),
                            maxSampleOffset: CGSize(width: 40, height: 40)
                        )
                    }
            }
        }
        .onAppear {
            shownAt = Date()
            withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
                appeared = true
            }
            // Count the XP up once the card has landed.
            withAnimation(Motion.spring.delay(0.35)) {
                xpShown = celebration.xpEarned
            }
            if celebration.newRank != nil {
                Haptics.rankUp()
            } else {
                Haptics.questComplete()
            }
        }
    }

    private var card: some View {
        VStack(spacing: 18) {
            Image(systemName: celebration.quest.category.icon)
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 88, height: 88)
                .background(Circle().fill(celebration.quest.category.gradient))
                .shadow(color: celebration.quest.category.accent.opacity(0.5), radius: 24)

            Text("Quest complete")
                .font(.system(size: 13, weight: .bold))
                .tracking(3)
                .textCase(.uppercase)
                .foregroundStyle(Palette.gold)

            Text(celebration.quest.title)
                .font(.system(size: 28, weight: .bold, design: .default))
                .foregroundStyle(Palette.textPrimary)
                .multilineTextAlignment(.center)

            Text("+\(xpShown) XP")
                .font(.system(size: 24, weight: .heavy, design: .rounded))
                .foregroundStyle(Palette.gold)
                .monospacedDigit()
                .contentTransition(.numericText(value: Double(xpShown)))
                .shimmer()

            if let newRank = celebration.newRank {
                VStack(spacing: 4) {
                    Text("New rank unlocked")
                        .font(.system(size: 12, weight: .bold))
                        .tracking(2)
                        .textCase(.uppercase)
                        .foregroundStyle(Palette.textSecondary)
                    Text(newRank.name)
                        .font(.system(size: 24, weight: .bold, design: .default))
                        .foregroundStyle(Palette.textPrimary)
                    Text(newRank.motto)
                        .font(.system(size: 13))
                        .foregroundStyle(Palette.textSecondary)
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 24)
                .cardChrome(radius: 20, fill: Palette.cardStrong)
            }

            Button {
                store.celebration = nil
            } label: {
                Text("Onward")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 44)
                    .padding(.vertical, 15)
                    .background(Capsule().fill(Palette.gold))
            }
            .buttonStyle(PressableStyle())
            .padding(.top, 10)
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 36, style: .continuous)
                .fill(Palette.bg)
                .shadow(color: .black.opacity(0.18), radius: 40, y: 16)
        )
        .padding(.horizontal, 24)
        .scaleEffect(appeared ? 1 : 0.85)
        .opacity(appeared ? 1 : 0)
    }
}
