import SwiftUI

/// Dual-berth index plus the SceneKit rail. Search, cookbook, and settings stay sheets.
struct HomeView: View {
    @ObservedObject var store: GalleyStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var sheet: GalleySheet?
    @State private var reviewRead = false
    @State private var servedLine = false
    @State private var revealed = false
    @State private var confirmReset = false
    @State private var litAnchor: CGPoint?

    var body: some View {
        ZStack {
            DesignTokens.bg.ignoresSafeArea()
            if store.loadError != nil {
                errorPage
            } else if Cold.isResting(store.galley) && !servedLine {
                coldPage
            } else {
                galley
            }
        }
        .sheet(item: $sheet) { kind in
            switch kind {
            case .search:
                SearchView(store: store)
            case .cookbook(let lane):
                CookbookView(store: store, seatLane: lane)
            case .settings:
                SettingsView(store: store)
            }
        }
        .confirmationDialog(
            "Reset tonight?",
            isPresented: $confirmReset,
            titleVisibility: .visible
        ) {
            Button("Reset", role: .destructive) {
                Task { await store.resetAllData() }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Saved recipes and served nights on this device will be removed.")
        }
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = store.galley.holdsIdleSleep
            revealed = true
            openReviewIfNeeded()
        }
        .onChange(of: store.galley.phase) { _, phase in
            UIApplication.shared.isIdleTimerDisabled = phase == .weaving
            if phase == .served {
                servedLine = true
            }
        }
        .onChange(of: store.onboardingComplete) { _, done in
            if done { openReviewIfNeeded() }
        }
    }

    private var galley: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Spacer()
                settingsButton
            }
            .padding(.horizontal, WeaveSpace.unit)
            Image("glw_HeaderDecor")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: WeaveSpace.steps(6))
                .clipped()
                .padding(.horizontal, WeaveSpace.steps(2))
                .accessibilityHidden(true)
            BerthHeader(store: store) { lane in
                sheet = .cookbook(lane)
            }
            Rectangle()
                .fill(DesignTokens.muted.opacity(0.35))
                .frame(height: 1)
                .padding(.horizontal, WeaveSpace.steps(2))
            rail
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private var rail: some View {
        VStack(alignment: .leading, spacing: WeaveSpace.steps(2)) {
            if store.galley.phase == .weaving {
                weavingRail
            } else if !previewLine.isEmpty {
                cookStage
            }
            nightStrip
            if servedLine && store.galley.phase == .served {
                HStack(alignment: .center, spacing: WeaveSpace.steps(2)) {
                    Image("glw_SuccessMark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: WeaveSpace.steps(8), height: WeaveSpace.steps(8))
                        .clipped()
                        .accessibilityHidden(true)
                    Text("Both dishes are served.")
                        .font(WeaveType.body)
                        .foregroundStyle(DesignTokens.ink)
                        .lineLimit(2)
                }
                .padding(.horizontal, WeaveSpace.steps(2))
            }
            if store.galley.phase == .seated || store.galley.phase == .bare {
                Text(promptLine)
                    .font(WeaveType.body)
                    .foregroundStyle(DesignTokens.ink)
                    .lineLimit(3)
                    .minimumScaleFactor(0.8)
                    .padding(.horizontal, WeaveSpace.steps(2))
                    .padding(.bottom, WeaveSpace.steps(2))
            }
        }
    }

    /// Seated home: the stage is the interleaved line of both dishes. Start stays the next tap.
    private var cookStage: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("The line")
                    .font(WeaveType.caption)
                    .foregroundStyle(DesignTokens.ink)
                    .padding(.bottom, WeaveSpace.unit)
                ForEach(Array(previewLine.enumerated()), id: \.element.id) { index, node in
                    cookRow(node, index: index)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.horizontal, WeaveSpace.steps(2))
        .accessibilityElement(children: .contain)
        .accessibilityLabel("The line of both dishes")
    }

    private func cookRow(_ node: WeaveNode, index: Int) -> some View {
        VStack(alignment: .leading, spacing: WeaveSpace.unit) {
            HStack(alignment: .firstTextBaseline, spacing: WeaveSpace.unit) {
                Text(node.lane == .main ? "Main" : "Second")
                    .font(WeaveType.caption)
                    .foregroundStyle(DesignTokens.accent)
                    .lineLimit(1)
                Text(node.kind == .ingredient ? "Check" : "Step")
                    .font(WeaveType.micro)
                    .foregroundStyle(DesignTokens.muted)
                    .lineLimit(1)
                if node.seconds > 0 {
                    Text(WeaveCount.text(node.seconds / 60) + " min")
                        .font(WeaveType.micro)
                        .foregroundStyle(DesignTokens.ink)
                        .lineLimit(1)
                }
            }
            Text(node.title)
                .font(WeaveType.body)
                .foregroundStyle(DesignTokens.ink)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
                .fixedSize(horizontal: false, vertical: true)
            Rectangle()
                .fill(DesignTokens.muted.opacity(0.35))
                .frame(height: 1)
        }
        .padding(.vertical, WeaveSpace.unit)
        .frame(maxWidth: .infinity, alignment: .leading)
        .opacity(revealed ? 1 : 0)
        .animation(rowReveal(index), value: revealed)
        .accessibilityElement(children: .combine)
    }

    /// Preview of the fold. Begin still builds the live queue.
    private var previewLine: [WeaveNode] {
        guard let mainID = store.galley.main.recipeID,
              let sideID = store.galley.side.recipeID,
              let main = store.cookbook.recipe(id: mainID),
              let side = store.cookbook.recipe(id: sideID)
        else { return [] }
        return WeaveQueue.interleave(main: main, side: side)
    }

    private var weavingRail: some View {
        WeaveRailView(nodes: store.galley.queue, litID: store.galley.litID, litAnchor: $litAnchor)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Step rail")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                RoundedRectangle(cornerRadius: WeaveRadius.plate, style: .continuous)
                    .fill(.thinMaterial)
            }
            .overlay {
                RoundedRectangle(cornerRadius: WeaveRadius.plate, style: .continuous)
                    .strokeBorder(DesignTokens.ink.opacity(0.08), lineWidth: 1)
            }
            .overlay { litOnNode }
            .padding(WeaveSpace.steps(2))
    }

    /// Done and Other dish sit on the lit bead. They are not a card under the night strip.
    @ViewBuilder
    private var litOnNode: some View {
        GeometryReader { geo in
            if let node = store.galley.litNode, store.galley.phase == .weaving {
                litCluster(node)
                    .position(litPosition(in: geo.size))
            }
        }
        .allowsHitTesting(store.galley.phase == .weaving)
    }

    private func litPosition(in size: CGSize) -> CGPoint {
        let anchor = litAnchor ?? CGPoint(x: size.width / 2, y: size.height / 2)
        let half = WeaveSpace.steps(16)
        let aboveBead = WeaveSpace.steps(12)
        let x = min(max(anchor.x, half), max(half, size.width - half))
        let y = min(max(anchor.y - aboveBead, WeaveSpace.steps(8)), max(WeaveSpace.steps(8), size.height - WeaveSpace.steps(6)))
        return CGPoint(x: x, y: y)
    }

    private func litCluster(_ node: WeaveNode) -> some View {
        let timing = node.seconds > 0 && store.galley.armedNodeID == node.id
        return VStack(alignment: .leading, spacing: WeaveSpace.unit) {
            HStack(spacing: WeaveSpace.unit) {
                WeaveChip(word: "Lit")
                Text(node.lane == .main ? "Main" : "Second")
                    .font(WeaveType.caption)
                    .foregroundStyle(DesignTokens.muted)
                    .lineLimit(1)
                if node.seconds > 0 {
                    Text(WeaveCount.text(node.seconds))
                        .font(WeaveType.digits)
                        .foregroundStyle(DesignTokens.ink)
                        .lineLimit(1)
                }
            }
            Text(node.title)
                .font(WeaveType.playful)
                .foregroundStyle(DesignTokens.ink)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
            HStack(spacing: WeaveSpace.unit) {
                Button(timing ? "Timing" : "Done") { tick() }
                    .buttonStyle(WeaveVerbStyle(loading: timing, expands: false))
                    .disabled(timing)
                Button("Other dish") { switchLane() }
                    .buttonStyle(WeaveQuietStyle())
                Button("Undo") { peel() }
                    .buttonStyle(WeaveQuietStyle())
            }
        }
        .padding(WeaveSpace.unit)
        .fixedSize(horizontal: true, vertical: true)
        .background {
            RoundedRectangle(cornerRadius: WeaveRadius.plate, style: .continuous)
                .fill(.thinMaterial)
        }
    }

    private var promptLine: String {
        store.galley.phase == .seated
            ? "Both dishes are ready. Start when you are."
            : "Fill both dishes, then start."
    }

    private var nightStrip: some View {
        HStack(alignment: .firstTextBaseline, spacing: WeaveSpace.steps(3)) {
            VStack(alignment: .leading, spacing: WeaveSpace.unit) {
                Text(WeaveCount.text(store.galley.served.count))
                    .font(WeaveType.title)
                    .foregroundStyle(DesignTokens.accent)
                    .lineLimit(1)
                Text("Served nights")
                    .font(WeaveType.caption)
                    .foregroundStyle(DesignTokens.ink)
                    .lineLimit(1)
            }
            Spacer(minLength: WeaveSpace.steps(2))
            VStack(alignment: .trailing, spacing: WeaveSpace.unit) {
                Text(WeaveCount.text(store.galley.keptHandoffs.count))
                    .font(WeaveType.headline)
                    .foregroundStyle(DesignTokens.ink)
                    .lineLimit(1)
                Text("Lane changes")
                    .font(WeaveType.caption)
                    .foregroundStyle(DesignTokens.muted)
                    .lineLimit(1)
            }
        }
        .padding(WeaveSpace.steps(2))
        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: WeaveRadius.plate, style: .continuous)
                .fill(.regularMaterial)
        }
        .overlay {
            RoundedRectangle(cornerRadius: WeaveRadius.plate, style: .continuous)
                .strokeBorder(DesignTokens.ink.opacity(0.08), lineWidth: 1)
        }
        .padding(.horizontal, WeaveSpace.steps(2))
        .opacity(revealed ? 1 : 0)
        .animation(rowReveal(5), value: revealed)
        .accessibilityElement(children: .combine)
    }

    private func rowReveal(_ index: Int) -> Animation {
        let duration = 0.2
        if reduceMotion {
            return .easeOut(duration: duration)
        }
        let delay = min(Double(index) * 0.05, 0.36 - duration)
        return .easeOut(duration: duration).delay(delay)
    }

    private var errorPage: some View {
        VStack(alignment: .leading, spacing: WeaveSpace.steps(2)) {
            HStack {
                Spacer()
                settingsButton
            }
            Spacer(minLength: WeaveSpace.steps(4))
            Text("This night could not be read.")
                .font(WeaveType.display)
                .foregroundStyle(DesignTokens.ink)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
            Text("Reset is the way forward.")
                .font(WeaveType.body)
                .foregroundStyle(DesignTokens.muted)
            Spacer()
            Button("Reset") { confirmReset = true }
                .buttonStyle(WeaveDangerStyle())
        }
        .padding(WeaveSpace.steps(2))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private var settingsButton: some View {
        Button {
            sheet = .settings
        } label: {
            Image(systemName: "gearshape")
                .font(WeaveType.body)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .accessibilityLabel("Settings")
        .buttonStyle(WeaveQuietStyle())
        .foregroundStyle(DesignTokens.ink)
    }

    private var coldPage: some View {
        VStack(alignment: .leading, spacing: WeaveSpace.steps(2)) {
            HStack {
                Spacer()
                settingsButton
            }
            Spacer(minLength: WeaveSpace.steps(4))
            Image("glw_EmptyHome")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .frame(height: WeaveSpace.steps(20))
                .clipped()
                .accessibilityHidden(true)
            Text("The kitchen is clear.")
                .font(WeaveType.display)
                .foregroundStyle(DesignTokens.ink)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
            Text("Fill a main and a second dish.")
                .font(WeaveType.body)
                .foregroundStyle(DesignTokens.muted)
            Spacer()
            Button("Place") { sheet = .cookbook(.main) }
                .buttonStyle(WeaveVerbStyle())
        }
        .padding(WeaveSpace.steps(2))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private func tick() {
        let marks = store.galley.tape.count
        store.tick()
        if store.galley.phase == .served || store.galley.tape.count > marks {
            WeaveFeel.commit()
        }
    }

    private func switchLane() {
        let before = store.galley.litID
        store.switchLane()
        if store.galley.litID != before { WeaveFeel.commit() }
    }

    private func peel() {
        let count = store.galley.tape.count
        store.peel()
        if store.galley.tape.count < count { WeaveFeel.commit() }
    }

    private func openReviewIfNeeded() {
        guard store.onboardingComplete, !reviewRead else { return }
        reviewRead = true
        switch ReviewLaunch.screen {
        case "log", "cookbook": sheet = .cookbook(nil)
        case "goals", "settings": sheet = .settings
        case "search": sheet = .search
        case "onboarding": store.replayOnboarding()
        default: break
        }
    }
}

enum GalleySheet: Identifiable {
    case search
    case cookbook(WeaveLane?)
    case settings

    var id: String {
        switch self {
        case .search: "search"
        case .cookbook: "cookbook"
        case .settings: "settings"
        }
    }
}
