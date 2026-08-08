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
            AmbientBackground()

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
        .preferredColorScheme(.dark)
    }
}

// MARK: - Floating tab bar

struct TabBar: View {
    @Binding var selection: Tab
    @Namespace private var pill

    var body: some View {
        HStack(spacing: 4) {
            ForEach(Tab.allCases, id: \.self) { tab in
                let isSelected = tab == selection
                Button {
                    guard selection != tab else { return }
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        selection = tab
                    }
                    Haptics.light()
                } label: {
                    HStack(spacing: 7) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 15, weight: .semibold))
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
                                .fill(Color.white.opacity(0.10))
                                .matchedGeometryEffect(id: "pill", in: pill)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(5)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(Capsule().strokeBorder(Color.white.opacity(0.09), lineWidth: 1))
        .shadow(color: .black.opacity(0.4), radius: 20, y: 8)
    }
}

// MARK: - Celebration overlay

struct CelebrationView: View {
    @EnvironmentObject private var store: QuestStore
    let celebration: Celebration

    @State private var appeared = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.78).ignoresSafeArea()
            ConfettiView().ignoresSafeArea()

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
                    .font(.system(size: 28, weight: .bold, design: .serif))
                    .foregroundStyle(Palette.textPrimary)
                    .multilineTextAlignment(.center)

                Text("+\(celebration.xpEarned) XP")
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .foregroundStyle(Palette.gold)
                    .monospacedDigit()

                if let newRank = celebration.newRank {
                    VStack(spacing: 4) {
                        Text("New rank unlocked")
                            .font(.system(size: 12, weight: .bold))
                            .tracking(2)
                            .textCase(.uppercase)
                            .foregroundStyle(Palette.textSecondary)
                        Text(newRank.name)
                            .font(.system(size: 24, weight: .bold, design: .serif))
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
                        .foregroundStyle(.black)
                        .padding(.horizontal, 44)
                        .padding(.vertical, 15)
                        .background(Capsule().fill(Palette.gold))
                }
                .buttonStyle(PressableStyle())
                .padding(.top, 10)
            }
            .padding(32)
            .scaleEffect(appeared ? 1 : 0.85)
            .opacity(appeared ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
                appeared = true
            }
        }
    }
}
