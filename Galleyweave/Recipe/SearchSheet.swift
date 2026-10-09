import SwiftUI

/// Catalog search. Page size lives in MealLookup. Failure falls back to the shelf.
struct SearchView: View {
    @ObservedObject var store: GalleyStore
    @Environment(\.dismiss) private var dismiss
    @State private var query = ""
    @State private var showSpinner = false
    @FocusState private var focused: Bool

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                TextField("Search meals", text: $query)
                    .font(WeaveType.body)
                    .textFieldStyle(.plain)
                    .focused($focused)
                    .submitLabel(.search)
                    .padding(WeaveSpace.steps(2))
                    .background {
                        RoundedRectangle(cornerRadius: WeaveRadius.plate, style: .continuous)
                            .fill(.thinMaterial)
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: WeaveRadius.plate, style: .continuous)
                            .strokeBorder(focused ? DesignTokens.accent : DesignTokens.ink.opacity(0.12), lineWidth: focused ? 2 : 1)
                    }
                    .padding(WeaveSpace.steps(2))
                    .onChange(of: query) { _, value in
                        store.search(query: value)
                    }
                content
            }
            .background {
                DesignTokens.bg
                    .contentShape(Rectangle())
                    .onTapGesture { focused = false }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { focused = false }
                }
            }
            .onChange(of: store.searchInFlight) { _, flying in
                guard flying else {
                    showSpinner = false
                    return
                }
                Task {
                    try? await Task.sleep(for: .milliseconds(150))
                    if store.searchInFlight { showSpinner = true }
                }
            }
        }
        .presentationDetents([.large])
        .presentationCornerRadius(WeaveRadius.plate)
    }

    @ViewBuilder
    private var content: some View {
        if showSpinner && store.searchInFlight && store.searchResults.isEmpty {
            ProgressView("Looking")
                .font(WeaveType.caption)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if store.searchFailed {
            miss
        } else if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            shelfList(store.localShelf(matching: ""), heading: "On this device")
        } else if store.searchResults.isEmpty && !store.searchInFlight {
            miss
        } else {
            shelfList(store.searchResults, heading: "Meals")
        }
    }

    private var miss: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: WeaveSpace.steps(2)) {
                Text("Search missed.")
                    .font(WeaveType.title)
                    .foregroundStyle(DesignTokens.ink)
                    .lineLimit(2)
                Text("The shelf on this device still has meals.")
                    .font(WeaveType.body)
                    .foregroundStyle(DesignTokens.muted)
                Button("Try again") {
                    store.search(query: query)
                }
                .buttonStyle(WeaveVerbStyle())
            }
            .padding(WeaveSpace.steps(2))
            shelfList(shelfAfterMiss, heading: "Shelf")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    /// Failed search already stored the cookbook and cached meals. Show that, not the bundled four alone.
    private var shelfAfterMiss: [Recipe] {
        if !store.searchResults.isEmpty {
            return store.searchResults
        }
        let matched = store.localShelf(matching: query)
        if !matched.isEmpty {
            return matched
        }
        return store.localShelf(matching: "")
    }

    private func shelfList(_ meals: [Recipe], heading: String) -> some View {
        List {
            Section(heading) {
                ForEach(Array(meals.enumerated()), id: \.element.id) { index, recipe in
                    mealRow(recipe)
                        .listRowInsets(EdgeInsets(
                            top: WeaveSpace.unit,
                            leading: WeaveSpace.unit,
                            bottom: WeaveSpace.unit,
                            trailing: WeaveSpace.unit
                        ))
                        .opacity(1)
                        .animation(rowAnimation(index), value: meals.count)
                }
            }
        }
        .listStyle(.plain)
        .scrollDismissesKeyboard(.interactively)
    }

    private func mealRow(_ recipe: Recipe) -> some View {
        HStack(alignment: .center, spacing: WeaveSpace.steps(2)) {
            thumb(recipe)
            VStack(alignment: .leading, spacing: WeaveSpace.unit) {
                Text(recipe.title)
                    .font(WeaveType.headline)
                    .foregroundStyle(DesignTokens.ink)
                    .lineLimit(2)
                Text(WeaveCount.text(recipe.steps.count))
                    .font(WeaveType.digits)
                    .foregroundStyle(DesignTokens.muted)
            }
            Spacer(minLength: WeaveSpace.unit)
            Button("Save") {
                store.saveToCookbook(recipe)
                WeaveFeel.commit()
            }
            .buttonStyle(WeaveQuietStyle())
        }
        .frame(minHeight: 44)
        .contentShape(Rectangle())
    }

    @ViewBuilder
    private func thumb(_ recipe: Recipe) -> some View {
        Group {
            if let raw = recipe.thumbnailURL, let url = URL(string: raw) {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    DesignTokens.ink.opacity(0.06)
                }
            } else {
                DesignTokens.accent.opacity(0.16)
            }
        }
        .frame(width: WeaveSpace.steps(7), height: WeaveSpace.steps(7))
        .clipShape(RoundedRectangle(cornerRadius: WeaveRadius.chip, style: .continuous))
        .accessibilityHidden(true)
    }

    private func rowAnimation(_ index: Int) -> Animation? {
        if UIAccessibility.isReduceMotionEnabled {
            return .easeOut(duration: 0.2)
        }
        let delay = min(Double(index) * 0.05, 0.36)
        return .easeOut(duration: 0.2).delay(delay)
    }
}
