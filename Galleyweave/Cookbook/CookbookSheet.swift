import SwiftUI

/// Saved recipes plus served nights and handoffs, grouped by daykey.
struct CookbookView: View {
    @ObservedObject var store: GalleyStore
    var seatLane: WeaveLane?
    @Environment(\.dismiss) private var dismiss
    @State private var search = false

    var body: some View {
        NavigationStack {
            Group {
                if store.cookbook.isEmpty && store.galley.served.isEmpty && store.galley.keptHandoffs.isEmpty {
                    empty
                } else {
                    index
                }
            }
            .background(DesignTokens.bg)
            .navigationTitle("Saved meals")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Search") { search = true }
                }
            }
            .sheet(isPresented: $search) {
                SearchView(store: store)
            }
        }
        .presentationDetents([.large])
        .presentationCornerRadius(WeaveRadius.plate)
    }

    private var empty: some View {
        VStack(alignment: .leading, spacing: WeaveSpace.steps(2)) {
            Spacer()
            Image("glw_EmptyList")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .frame(height: WeaveSpace.steps(20))
                .clipped()
                .accessibilityHidden(true)
            Text("Nothing is saved yet.")
                .font(WeaveType.display)
                .foregroundStyle(DesignTokens.ink)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
            Text("Save a meal, then place it.")
                .font(WeaveType.body)
                .foregroundStyle(DesignTokens.muted)
            Spacer()
            Button("Search") { search = true }
                .buttonStyle(WeaveVerbStyle())
        }
        .padding(WeaveSpace.steps(2))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private var index: some View {
        List {
            if !store.cookbook.items.isEmpty {
                Section("Saved") {
                    ForEach(store.cookbook.items) { item in
                        if seatLane != nil {
                            Button {
                                seat(item)
                            } label: {
                                mealLine(item, placing: true)
                            }
                            .buttonStyle(.plain)
                        } else {
                            mealLine(item, placing: false)
                        }
                    }
                }
            }
            history
        }
        .listStyle(.plain)
    }

    @ViewBuilder
    private var history: some View {
        let days = groupedDays
        if !days.isEmpty {
            Section("Nights") {
                ForEach(days, id: \.self) { day in
                    VStack(alignment: .leading, spacing: WeaveSpace.unit) {
                        Text(WeaveCount.day(day))
                            .font(WeaveType.digits)
                            .foregroundStyle(DesignTokens.ink)
                        Text(nightLine(day))
                            .font(WeaveType.caption)
                            .foregroundStyle(DesignTokens.muted)
                    }
                    .frame(minHeight: 44)
                }
            }
        }
    }

    private var groupedDays: [Int] {
        let served = store.galley.served.map(\.daykey)
        let hands = store.galley.keptHandoffs.map(\.daykey)
        return Array(Set(served + hands)).sorted(by: >)
    }

    private func mealLine(_ item: CookbookItem, placing: Bool) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: WeaveSpace.unit) {
                Text(item.recipe.title)
                    .font(WeaveType.headline)
                    .foregroundStyle(DesignTokens.ink)
                    .lineLimit(2)
                Text(WeaveCount.text(item.recipe.steps.count))
                    .font(WeaveType.digits)
                    .foregroundStyle(DesignTokens.muted)
            }
            Spacer(minLength: WeaveSpace.unit)
            if placing {
                Text("Place")
                    .font(WeaveType.caption)
                    .foregroundStyle(DesignTokens.ink)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
        .contentShape(Rectangle())
    }

    private func nightLine(_ day: Int) -> String {
        let served = WeaveCount.text(servedCount(day))
        let hands = WeaveCount.text(handoffCount(day))
        return "Served \(served), handoffs \(hands)"
    }

    private func servedCount(_ day: Int) -> Int {
        store.galley.served.filter { $0.daykey == day }.count
    }

    private func handoffCount(_ day: Int) -> Int {
        store.galley.keptHandoffs.map { $0.daykey == day }.filter { $0 }.count
    }

    private func seat(_ item: CookbookItem) {
        guard let seatLane else { return }
        let before = store.galley.phase
        store.seat(item, on: seatLane)
        if store.galley.phase != before || store.galley.main.recipeID == item.id || store.galley.side.recipeID == item.id {
            WeaveFeel.commit()
        }
        dismiss()
    }
}
