import os
import XCTest
@testable import Galleyweave

final class GalleyweaveTests: XCTestCase {
    func test_appModuleImports() {
        XCTAssertEqual(String(describing: GalleyweaveApp.self), "GalleyweaveApp")
    }

    func testCookModeIngredientsThenNumberedSteps() {
        var galley = seatedPair()
        let effect = galley.begin(mainRecipe: BundledShelf.herbChicken, sideRecipe: BundledShelf.lemonGreens)
        XCTAssertEqual(effect, .weaving)
        XCTAssertTrue(WeaveQueue.ingredientsPrecedeSteps(galley.queue))
        let steps = galley.queue.filter { $0.kind == .step }
        XCTAssertTrue(steps.allSatisfy { $0.number > 0 })
        let timed = steps.filter { $0.seconds > 0 }
        let untimed = steps.filter { $0.seconds == 0 }
        XCTAssertEqual(steps.map(\.seconds), timed.map(\.seconds) + untimed.map(\.seconds))
        XCTAssertEqual(timed.map(\.seconds), timed.map(\.seconds).sorted())
        XCTAssertEqual(timed.first?.seconds, 3 * 60)
        XCTAssertEqual(timed.first?.lane, .side)
    }

    func testBothBerthsBeforeBeginAndEarlyDrift() {
        var galley = Galley.cold()
        XCTAssertTrue(Cold.isResting(galley))
        XCTAssertEqual(galley.seat(recipeID: BundledShelf.herbChickenID, on: .main), .berthFilled)
        XCTAssertEqual(galley.phase, .bare)
        XCTAssertFalse(galley.canBegin)
        XCTAssertEqual(
            galley.begin(mainRecipe: BundledShelf.herbChicken, sideRecipe: BundledShelf.lemonGreens),
            .drift
        )
        XCTAssertEqual(galley.tape.count, 1)
        XCTAssertEqual(galley.phase, .bare)

        var bare = Galley.cold()
        XCTAssertEqual(bare.tick(), .drift)
        XCTAssertEqual(bare.phase, .bare)
    }

    func testSeatThenWeaveRefusesAThirdAndServesOnlyWhenBothFinish() {
        var galley = seatedPair()
        XCTAssertEqual(galley.phase, .seated)
        XCTAssertEqual(galley.seat(recipeID: BundledShelf.butterBeansID, on: .main), .refused)
        XCTAssertEqual(galley.begin(mainRecipe: BundledShelf.herbChicken, sideRecipe: BundledShelf.lemonGreens), .weaving)
        XCTAssertTrue(galley.holdsIdleSleep)
        XCTAssertFalse(Galley.cold().holdsIdleSleep)

        var servedCount = galley.served.count
        var guardRail = 0
        while galley.phase == .weaving && guardRail < 40 {
            guardRail += 1
            let before = galley.queue.count
            let effect = galley.tick()
            if case .arm(let nodeID, _) = effect {
                XCTAssertEqual(galley.queue.count, before)
                let finished = galley.completeArmedTick(nodeID: nodeID)
                if case .served = finished {
                    servedCount += 1
                }
            } else if case .served = effect {
                servedCount += 1
            }
            XCTAssertEqual(galley.served.count, servedCount)
        }
        XCTAssertEqual(galley.phase, .served)
        XCTAssertEqual(galley.served.count, 1)
        XCTAssertNil(galley.main.recipeID)
        XCTAssertNil(galley.side.recipeID)
        XCTAssertEqual(Peel.apply(to: &galley), .peelRefused)
    }

    func testHandoffLeavesTheQueueIntactAndPeelRestores() {
        var galley = seatedPair()
        _ = galley.begin(mainRecipe: BundledShelf.herbChicken, sideRecipe: BundledShelf.lemonGreens)
        let before = galley.queue.map(\.id)
        let lit = galley.litID
        XCTAssertEqual(galley.switchLane(), .handoff)
        XCTAssertEqual(galley.queue.map(\.id), before)
        XCTAssertNotEqual(galley.litID, lit)
        XCTAssertEqual(galley.keptHandoffs.count, 1)
        XCTAssertEqual(Peel.apply(to: &galley), .peeled)
        XCTAssertEqual(galley.litID, lit)
        XCTAssertTrue(galley.keptHandoffs.isEmpty)

        _ = galley.tick()
        XCTAssertEqual(Peel.apply(to: &galley), .peeled)
        XCTAssertEqual(galley.queue.map(\.id), before)
    }

    func testColdEmptyGalleyAndSeedBeginsEnabled() {
        XCTAssertTrue(Cold.isResting(.cold()))
        let seed = GalleyChart.simulatorSeed(now: Date(timeIntervalSince1970: 1_700_000_000))
        XCTAssertTrue(seed.onboardingComplete)
        XCTAssertEqual(seed.cookbook.items.map(\.recipe.title), [
            "Herb chicken", "Lemon greens", "Butter beans", "Rice pilaf"
        ])
        XCTAssertEqual(seed.galley.served.count, 1)
        XCTAssertEqual(seed.galley.keptHandoffs.count, 1)
        XCTAssertTrue(seed.galley.canBegin)
        XCTAssertFalse(seed.galley.holdsIdleSleep)
        XCTAssertGreaterThan(seed.galley.served[0].daykey, 20000101)
    }

    @MainActor
    func testChartRoundTripAndCorruptKeyStays() async throws {
        let suite = "galleyweave.tests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)
        defaults?.removePersistentDomain(forName: suite)
        let store = GalleyStore(suiteName: suite, allowsDemoSeed: false)
        await store.open()
        XCTAssertTrue(Cold.isResting(store.galley))
        store.saveToCookbook(BundledShelf.herbChicken)
        store.saveToCookbook(BundledShelf.lemonGreens)
        store.seat(CookbookItem(recipe: BundledShelf.herbChicken), on: .main)
        store.seat(CookbookItem(recipe: BundledShelf.lemonGreens), on: .side)
        await store.flush()

        let reloaded = GalleyStore(suiteName: suite, allowsDemoSeed: false)
        await reloaded.open()
        XCTAssertNil(reloaded.loadError)
        XCTAssertEqual(reloaded.galley.phase, .seated)
        XCTAssertEqual(reloaded.galley.main.recipeID, BundledShelf.herbChickenID)
        XCTAssertEqual(reloaded.cookbook.items.count, 2)

        defaults?.set(Data("not-a-chart".utf8), forKey: GalleyStore.chartKey)
        let broken = GalleyStore(suiteName: suite, allowsDemoSeed: false)
        await broken.open()
        XCTAssertNotNil(broken.loadError)
        XCTAssertTrue(Cold.isResting(broken.galley))
        XCTAssertEqual(defaults?.data(forKey: GalleyStore.chartKey), Data("not-a-chart".utf8))

        await broken.resetAllData()
        XCTAssertNil(defaults?.data(forKey: GalleyStore.chartKey))
        defaults?.removePersistentDomain(forName: suite)
    }

    func testSchemaRejectsAnUnknownVersion() {
        let junk = Data(#"{"schemaVersion":9}"#.utf8)
        XCTAssertThrowsError(try GalleyChart.decoded(junk))
    }

    func testReviewLaunchParsesScreenArgument() {
        XCTAssertEqual(ReviewLaunch.screen(from: ["Galleyweave", "-ReviewScreen", "log"]), "log")
        XCTAssertEqual(ReviewLaunch.screen(from: ["Galleyweave", "-ReviewScreen", "goals"]), "goals")
        XCTAssertNil(ReviewLaunch.screen(from: ["Galleyweave"]))
        XCTAssertNil(ReviewLaunch.screen(from: ["-ReviewScreen"]))
    }

    func testMinutePhraseAndPageSlice() async throws {
        XCTAssertEqual(MealMapping.seconds(in: "Sear the thighs for 8 minutes."), 480)
        XCTAssertEqual(MealMapping.seconds(in: "Simmer 1 hour 15 minutes."), 4500)
        XCTAssertEqual(MealMapping.seconds(in: "Rest the chicken."), 0)
        let steps = MealMapping.numberedSteps(from: "Rinse.\nWilt for 3 minutes.")
        XCTAssertEqual(steps.map(\.number), [1, 2])
        XCTAssertEqual(steps.map(\.seconds), [0, 180])

        let lookup = MealLookup(session: MealFixtures.session())
        MealFixtures.box.withLock { $0 = MealFixtures.State(status: 200, body: MealFixtures.tenMeals(), hits: 0) }
        let page = try await lookup.search(query: "chicken", page: 2)
        XCTAssertEqual(page.count, 2)
        XCTAssertEqual(page.first?.title, "Meal 9")
        let hits = MealFixtures.box.withLock { $0.hits }
        XCTAssertEqual(hits, 1)
        let header = MealFixtures.box.withLock { $0.userAgent }
        XCTAssertEqual(header, MealLookup.userAgent)

        MealFixtures.box.withLock { state in
            state.hits = 0
        }
        let empty = try await lookup.search(query: "   ", page: 1)
        XCTAssertTrue(empty.isEmpty)
        XCTAssertEqual(MealFixtures.box.withLock { $0.hits }, 0)
    }

    func testLookupDoesNotRetryNotFoundAndRetriesTransport() async throws {
        let lookup = MealLookup(session: MealFixtures.session())
        MealFixtures.box.withLock { $0 = MealFixtures.State(status: 404, body: Data("{}".utf8), hits: 0) }
        do {
            _ = try await lookup.lookup(id: "missing")
            XCTFail("Missing meal should throw")
        } catch let error as MealLookupError {
            XCTAssertEqual(error, .notFound)
        }
        XCTAssertEqual(MealFixtures.box.withLock { $0.hits }, 1)

        MealFixtures.box.withLock {
            $0 = MealFixtures.State(status: 503, body: Data(), hits: 0, thenStatus: 200, thenBody: MealFixtures.oneMeal())
        }
        let recipe = try await lookup.lookup(id: "52772")
        XCTAssertEqual(recipe.title, "Herb chicken")
        XCTAssertEqual(recipe.ingredients.count, 1)
        XCTAssertEqual(MealFixtures.box.withLock { $0.hits }, 2)

        MealFixtures.box.withLock { $0 = MealFixtures.State(status: 200, body: Data("[]".utf8), hits: 0) }
        do {
            _ = try await lookup.search(query: "beans", page: 1)
            XCTFail("Bad JSON should throw")
        } catch let error as MealLookupError {
            XCTAssertEqual(error, .malformed)
        }
    }
}

private func seatedPair() -> Galley {
    var galley = Galley.cold()
    _ = galley.seat(recipeID: BundledShelf.herbChickenID, on: .main)
    _ = galley.seat(recipeID: BundledShelf.lemonGreensID, on: .side)
    return galley
}

enum MealFixtures {
    struct State: Sendable {
        var status: Int
        var body: Data
        var hits: Int
        var userAgent: String?
        var thenStatus: Int?
        var thenBody: Data?
    }

    static let box = OSAllocatedUnfairLock(initialState: State(status: 200, body: Data(), hits: 0))

    static func session() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MealURLStub.self]
        return URLSession(configuration: configuration)
    }

    static func oneMeal() -> Data {
        Data(#"{"meals":[{"idMeal":"52772","strMeal":"Herb chicken","strInstructions":"Sear for 8 minutes.","strIngredient1":"Thyme","strMeasure1":"4 sprigs","strMealThumb":"https://example.test/herb.jpg"}]}"#.utf8)
    }

    static func tenMeals() -> Data {
        let meals = (1...10).map { index in
            #"{"idMeal":"\#(index)","strMeal":"Meal \#(index)","strInstructions":"Cook.","strIngredient1":"Salt","strMeasure1":"1"}"#
        }.joined(separator: ",")
        return Data("{\"meals\":[\(meals)]}".utf8)
    }
}

final class MealURLStub: URLProtocol, @unchecked Sendable {
    // URLProtocol has no instance injection. The lock above is the only mutable state.
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        let reply = MealFixtures.box.withLock { state -> (Int, Data) in
            state.hits += 1
            state.userAgent = request.value(forHTTPHeaderField: "User-Agent")
            let status = state.status
            let body = state.body
            if let next = state.thenStatus {
                state.status = next
                state.body = state.thenBody ?? Data()
                state.thenStatus = nil
            }
            return (status, body)
        }
        guard let url = request.url else {
            client?.urlProtocol(self, didFailWithError: MealLookupError.transport)
            return
        }
        let response = HTTPURLResponse(url: url, statusCode: reply.0, httpVersion: nil, headerFields: nil)
        if let response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        client?.urlProtocol(self, didLoad: reply.1)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
