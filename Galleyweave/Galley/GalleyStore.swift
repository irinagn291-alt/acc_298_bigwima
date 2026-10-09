import Foundation
import os

/// In-memory source of truth. Views talk to this type and never to UserDefaults.
/// Each mark schedules one save. Leaving the active scene and reset flush at once.
@MainActor
final class GalleyStore: ObservableObject {
    nonisolated static let chartKey = "glw.chart.v1"
    nonisolated static let demoKey = "glw.demo.v1"
    nonisolated static let saveDelay: Duration = .milliseconds(400)

    @Published private(set) var chart: GalleyChart
    @Published private(set) var loadError: String?
    @Published private(set) var searchResults: [Recipe] = []
    @Published private(set) var searchFailed = false
    @Published private(set) var searchInFlight = false
    @Published private(set) var opened = false

    private let defaults: UserDefaults
    private let suiteName: String?
    private let lookup: MealLookup
    private let gate = WorkGate()
    private let allowsDemoSeed: Bool

    init(suiteName: String?, lookup: MealLookup = MealLookup(), allowsDemoSeed: Bool = true) {
        let defaults = suiteName.flatMap { UserDefaults(suiteName: $0) } ?? .standard
        self.defaults = defaults
        self.suiteName = suiteName
        self.lookup = lookup
        self.allowsDemoSeed = allowsDemoSeed
        self.chart = .cold()
    }

    var galley: Galley { chart.galley }
    var cookbook: Cookbook { chart.cookbook }
    var onboardingComplete: Bool { chart.onboardingComplete }

    func open() async {
        let suite = suiteName
        let key = Self.chartKey
        let demo = Self.demoKey
        let snapshot = await Task.detached(priority: .utility) {
            // UserDefaults reads a file on disk. Keep that wait off the main actor.
            readChart(suiteName: suite, chartKey: key, demoKey: demo)
        }.value
        let data = snapshot.data
        if let data {
            do {
                chart = try GalleyChart.decoded(data)
                loadError = nil
            } catch {
                loadError = "This galley could not be read. Reset is the way forward."
                chart = .cold()
            }
            opened = true
            return
        }
        #if targetEnvironment(simulator)
        if allowsDemoSeed && !snapshot.demoAlready {
            chart = GalleyChart.simulatorSeed()
            defaults.set(true, forKey: Self.demoKey)
            await flush()
            opened = true
            return
        }
        #endif
        chart = .cold()
        loadError = nil
        opened = true
    }

    func replayOnboarding() {
        chart.onboardingComplete = false
        scheduleSave()
    }

    func markOnboardingComplete() {
        chart.onboardingComplete = true
        scheduleSave()
    }

    func seat(_ item: CookbookItem, on lane: WeaveLane) {
        guard cookbook.recipe(id: item.id) != nil else { return }
        let effect = chart.galley.seat(recipeID: item.id, on: lane)
        if effect == .refused { return }
        scheduleSave()
    }

    func begin(now: Date = Date()) {
        guard let mainID = chart.galley.main.recipeID,
              let sideID = chart.galley.side.recipeID,
              let main = cookbook.recipe(id: mainID),
              let side = cookbook.recipe(id: sideID)
        else {
            _ = chart.galley.begin(mainRecipe: Recipe(id: UUID(), title: "", ingredients: [], steps: []), sideRecipe: Recipe(id: UUID(), title: "", ingredients: [], steps: []), now: now)
            scheduleSave()
            return
        }
        _ = chart.galley.begin(mainRecipe: main, sideRecipe: side, now: now)
        scheduleSave()
    }

    func tick(now: Date = Date()) {
        let effect = chart.galley.tick(now: now)
        switch effect {
        case .arm(let nodeID, let seconds):
            scheduleSave()
            arm(nodeID: nodeID, seconds: seconds)
        case .drift, .advanced, .served:
            gate.clearTick()
            scheduleSave()
        case .refused:
            break
        default:
            scheduleSave()
        }
    }

    func switchLane(now: Date = Date()) {
        let effect = chart.galley.switchLane(now: now)
        if effect == .handoff {
            gate.clearTick()
            scheduleSave()
        }
    }

    func peel() {
        let effect = Peel.apply(to: &chart.galley)
        if effect == .peeled {
            gate.clearTick()
            scheduleSave()
        }
    }

    func saveToCookbook(_ recipe: Recipe) {
        if chart.cookbook.items.contains(where: { $0.recipe.catalogID == recipe.catalogID && recipe.catalogID != nil }) {
            return
        }
        var stored = recipe
        if chart.cookbook.recipe(id: stored.id) != nil {
            stored.id = UUID()
        }
        chart.cookbook.items.append(CookbookItem(recipe: stored))
        scheduleSave()
    }

    func cacheMeal(_ recipe: Recipe) {
        if let catalogID = recipe.catalogID,
           let index = chart.cachedMeals.firstIndex(where: { $0.catalogID == catalogID }) {
            chart.cachedMeals[index] = recipe
        } else {
            chart.cachedMeals.append(recipe)
        }
        scheduleSave()
    }

    func resetAllData() async {
        gate.cancelAll()
        defaults.removeObject(forKey: Self.chartKey)
        chart = .cold()
        loadError = nil
        searchResults = []
        searchFailed = false
        await flushRemoval()
    }

    func scenePhaseChanged(isActive: Bool) async {
        if !isActive {
            await flush()
        }
    }

    func scheduleSave() {
        gate.setSave(Task { [weak self] in
            try? await Task.sleep(for: GalleyStore.saveDelay)
            guard !Task.isCancelled else { return }
            await self?.flush()
        })
    }

    func flush() async {
        gate.clearSave()
        let snapshot = chart
        let suite = suiteName
        let key = Self.chartKey
        let data: Data
        do {
            data = try snapshot.encoded()
        } catch {
            loadError = "This galley could not be saved."
            return
        }
        await Task.detached(priority: .utility) {
            // The chart is one blob. Writing it off the main actor keeps a flush from hitching the weave.
            writeChart(suiteName: suite, key: key, data: data)
        }.value
    }

    /// Search debounces, cancels the previous task, and keeps a stale page from landing.
    func search(query: String) {
        gate.clearSearch()
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            searchResults = []
            searchFailed = false
            searchInFlight = false
            return
        }
        searchInFlight = true
        searchFailed = false
        gate.setSearch(Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(500))
            guard !Task.isCancelled, let self else { return }
            do {
                let found = try await self.lookup.search(query: trimmed, page: 1)
                guard !Task.isCancelled else { return }
                for meal in found {
                    self.cacheMeal(meal)
                }
                self.searchResults = found
                self.searchFailed = false
            } catch is CancellationError {
                return
            } catch {
                guard !Task.isCancelled else { return }
                self.searchResults = self.localShelf(matching: trimmed)
                self.searchFailed = true
            }
            self.searchInFlight = false
        })
    }

    func localShelf(matching query: String) -> [Recipe] {
        let needle = query.lowercased()
        let pool = chart.cookbook.items.map(\.recipe) + chart.cachedMeals
        var seen: Set<String> = []
        return pool.filter { recipe in
            let key = recipe.catalogID ?? recipe.id.uuidString
            guard seen.insert(key).inserted else { return false }
            return recipe.title.lowercased().contains(needle)
        }
    }

    private func arm(nodeID: UUID, seconds: Int) {
        gate.setTick(Task { [weak self] in
            try? await Task.sleep(for: .seconds(seconds))
            guard !Task.isCancelled else { return }
            self?.finishArm(nodeID)
        })
    }

    private func finishArm(_ nodeID: UUID) {
        let effect = chart.galley.completeArmedTick(nodeID: nodeID)
        if effect != .refused {
            scheduleSave()
        }
    }

    private func flushRemoval() async {
        let suite = suiteName
        let key = Self.chartKey
        await Task.detached(priority: .utility) {
            removeChart(suiteName: suite, key: key)
        }.value
    }
}

/// Cancels debounced saves, armed ticks, and search when the store goes away.
/// The lock is the only shared mutable state, so the gate can cross actors.
final class WorkGate: Sendable {
    private struct Slot {
        var save: Task<Void, Never>?
        var tick: Task<Void, Never>?
        var search: Task<Void, Never>?
    }

    private let box = OSAllocatedUnfairLock(initialState: Slot())

    func setSave(_ task: Task<Void, Never>) {
        box.withLock { slot in
            slot.save?.cancel()
            slot.save = task
        }
    }

    func setTick(_ task: Task<Void, Never>) {
        box.withLock { slot in
            slot.tick?.cancel()
            slot.tick = task
        }
    }

    func setSearch(_ task: Task<Void, Never>) {
        box.withLock { slot in
            slot.search?.cancel()
            slot.search = task
        }
    }

    func clearSave() {
        box.withLock { $0.save?.cancel(); $0.save = nil }
    }

    func clearTick() {
        box.withLock { $0.tick?.cancel(); $0.tick = nil }
    }

    func clearSearch() {
        box.withLock { $0.search?.cancel(); $0.search = nil }
    }

    func cancelAll() {
        box.withLock { slot in
            slot.save?.cancel()
            slot.tick?.cancel()
            slot.search?.cancel()
            slot = Slot()
        }
    }

    deinit { cancelAll() }
}

private struct ChartSnapshot: Sendable {
    var data: Data?
    var demoAlready: Bool
}

private func readChart(suiteName: String?, chartKey: String, demoKey: String) -> ChartSnapshot {
    let defaults = suiteName.flatMap { UserDefaults(suiteName: $0) } ?? .standard
    return ChartSnapshot(data: defaults.data(forKey: chartKey), demoAlready: defaults.bool(forKey: demoKey))
}

private func writeChart(suiteName: String?, key: String, data: Data) {
    let defaults = suiteName.flatMap { UserDefaults(suiteName: $0) } ?? .standard
    defaults.set(data, forKey: key)
}

private func removeChart(suiteName: String?, key: String) {
    let defaults = suiteName.flatMap { UserDefaults(suiteName: $0) } ?? .standard
    defaults.removeObject(forKey: key)
}
