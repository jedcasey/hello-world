import SwiftUI

@main
struct SideQuestsApp: App {
    @StateObject private var store = QuestStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
        }
    }
}
