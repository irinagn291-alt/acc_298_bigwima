import SwiftUI

struct ContentView: View {
    @StateObject private var store = GalleyStore(suiteName: nil)
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        Group {
            if !store.opened {
                DesignTokens.bg.ignoresSafeArea()
            } else if store.onboardingComplete {
                HomeView(store: store)
            } else {
                OnboardingView(store: store)
            }
        }
        .tint(DesignTokens.accent)
        .task { await store.open() }
        .onChange(of: scenePhase) { _, phase in
            Task { await store.scenePhaseChanged(isActive: phase == .active) }
        }
    }
}

#Preview {
    ContentView()
}
