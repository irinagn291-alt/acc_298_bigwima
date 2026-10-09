import SwiftUI

/// Flush-left index. Main is the display line. Side is the quieter title. Seat and Begin fuse here.
struct BerthHeader: View {
    @ObservedObject var store: GalleyStore
    var onSeat: (WeaveLane) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: WeaveSpace.steps(2)) {
            HStack(alignment: .firstTextBaseline) {
                Text("Cook both tonight")
                    .font(WeaveType.caption)
                    .foregroundStyle(DesignTokens.ink)
                Spacer()
                statusChip
            }
            VStack(alignment: .leading, spacing: WeaveSpace.unit) {
                Text("Main")
                    .font(WeaveType.micro)
                    .foregroundStyle(DesignTokens.muted)
                Text(title(for: store.galley.main.recipeID) ?? "Open")
                    .font(WeaveType.display)
                    .foregroundStyle(DesignTokens.ink)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
            }
            HStack(alignment: .firstTextBaseline, spacing: WeaveSpace.steps(2)) {
                Text("Second")
                    .font(WeaveType.caption)
                    .foregroundStyle(DesignTokens.muted)
                Text(title(for: store.galley.side.recipeID) ?? "Open")
                    .font(WeaveType.title)
                    .foregroundStyle(DesignTokens.ink)
                    .lineLimit(1)
                    .layoutPriority(1)
            }
            HStack(spacing: WeaveSpace.unit) {
                Button("Place") { onSeat(openLane) }
                    .buttonStyle(WeaveQuietStyle(enabled: canSeat))
                    .disabled(!canSeat)
                    .accessibilityHint("Choose a saved meal for the open place.")
                Button("Start") { begin() }
                    .buttonStyle(WeaveVerbStyle())
                    .disabled(!store.galley.canBegin)
                    .accessibilityHint("Start the steps for both dishes.")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(WeaveSpace.steps(2))
    }

    private var statusChip: some View {
        switch store.galley.phase {
        case .seated: WeaveChip(word: "Seated")
        case .weaving: WeaveChip(word: "Lit")
        case .served: WeaveChip(word: "Served")
        case .bare: WeaveChip(word: "Open")
        }
    }

    private var canSeat: Bool {
        store.galley.main.recipeID == nil || store.galley.side.recipeID == nil
    }

    private var openLane: WeaveLane {
        store.galley.main.recipeID == nil ? .main : .side
    }

    private func title(for id: UUID?) -> String? {
        guard let id else { return nil }
        return store.cookbook.recipe(id: id)?.title
    }

    private func begin() {
        let before = store.galley.phase
        store.begin()
        if store.galley.phase == .weaving, before != .weaving {
            WeaveFeel.commit()
        }
    }
}
