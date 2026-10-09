import Foundation

/// Codable root for one UserDefaults blob. schemaVersion starts at 1.
/// Cached meals, cookbook, live fold, open tape, and served nights travel together.
struct GalleyChart: Equatable, Sendable {
    static let currentSchema = 1

    var schemaVersion: Int
    var onboardingComplete: Bool
    var cachedMeals: [Recipe]
    var shelfIDs: [String]
    var cookbook: Cookbook
    var galley: Galley

    static func cold() -> GalleyChart {
        GalleyChart(
            schemaVersion: currentSchema,
            onboardingComplete: false,
            cachedMeals: BundledShelf.meals,
            shelfIDs: BundledShelf.shelfIDs,
            cookbook: Cookbook(),
            galley: .cold()
        )
    }

    /// Simulator demo. Main and Side are seated so Begin is the first live tap.
    static func simulatorSeed(now: Date = Date(), calendar: Calendar = .current) -> GalleyChart {
        var chart = GalleyChart.cold()
        chart.onboardingComplete = true
        chart.cookbook = Cookbook(items: BundledShelf.meals.map(CookbookItem.init(recipe:)))
        var galley = Galley.cold()
        _ = galley.seat(recipeID: BundledShelf.herbChickenID, on: .main)
        _ = galley.seat(recipeID: BundledShelf.lemonGreensID, on: .side)
        let earlier = calendar.date(byAdding: .day, value: -1, to: now) ?? now
        let handoff = HandoffMark(
            id: ShelfUUID.make(90),
            fromNodeID: ShelfUUID.make(91),
            toNodeID: ShelfUUID.make(92),
            fromLane: .main,
            toLane: .side,
            filedAt: earlier,
            daykey: Daykey.stamp(earlier, calendar: calendar)
        )
        galley.keptHandoffs = [handoff]
        galley.served = [
            ServedMark(
                id: ShelfUUID.make(93),
                mainRecipeID: BundledShelf.butterBeansID,
                sideRecipeID: BundledShelf.ricePilafID,
                daykey: Daykey.stamp(earlier, calendar: calendar),
                filedAt: earlier
            )
        ]
        chart.galley = galley
        return chart
    }

    func encoded() throws -> Data {
        try JSONEncoder().encode(Payload(self))
    }

    static func decoded(_ data: Data) throws -> GalleyChart {
        let payload = try JSONDecoder().decode(Payload.self, from: data)
        return payload.chart
    }
}

/// Wire format. The five storage words exist only as coding keys.
private struct Payload: Codable {
    var schemaVersion: Int
    var onboardingComplete: Bool
    var islands: Islands
    var books: Books
    var sessions: Sessions
    var runs: Runs
    var rhumbs: Rhumbs

    struct Islands: Codable {
        var meals: [Recipe]
        var shelfIDs: [String]
    }

    struct Books: Codable {
        var items: [CookbookItem]
    }

    struct Sessions: Codable {
        var phase: GalleyPhase
        var mainRecipeID: UUID?
        var sideRecipeID: UUID?
        var queue: [WeaveNode]
        var litID: UUID?
    }

    struct Runs: Codable {
        var tape: [RunMark]
        var keptHandoffs: [HandoffMark]
    }

    struct Rhumbs: Codable {
        var served: [ServedMark]
    }

    enum CodingKeys: String, CodingKey {
        case schemaVersion
        case onboardingComplete
        case islands
        case books
        case sessions
        case runs
        case rhumbs
    }

    init(_ chart: GalleyChart) {
        schemaVersion = chart.schemaVersion
        onboardingComplete = chart.onboardingComplete
        islands = Islands(meals: chart.cachedMeals, shelfIDs: chart.shelfIDs)
        books = Books(items: chart.cookbook.items)
        sessions = Sessions(
            phase: chart.galley.phase,
            mainRecipeID: chart.galley.main.recipeID,
            sideRecipeID: chart.galley.side.recipeID,
            queue: chart.galley.queue,
            litID: chart.galley.litID
        )
        runs = Runs(tape: chart.galley.tape, keptHandoffs: chart.galley.keptHandoffs)
        rhumbs = Rhumbs(served: chart.galley.served)
    }

    var chart: GalleyChart {
        var galley = Galley.cold()
        galley.phase = sessions.phase
        galley.main.recipeID = sessions.mainRecipeID
        galley.side.recipeID = sessions.sideRecipeID
        galley.queue = sessions.queue
        galley.litID = sessions.litID
        galley.tape = runs.tape
        galley.keptHandoffs = runs.keptHandoffs
        galley.served = rhumbs.served
        return GalleyChart(
            schemaVersion: schemaVersion,
            onboardingComplete: onboardingComplete,
            cachedMeals: islands.meals,
            shelfIDs: islands.shelfIDs,
            cookbook: Cookbook(items: books.items),
            galley: galley
        )
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(schemaVersion, forKey: .schemaVersion)
        try container.encode(onboardingComplete, forKey: .onboardingComplete)
        try container.encode(islands, forKey: .islands)
        try container.encode(books, forKey: .books)
        try container.encode(sessions, forKey: .sessions)
        try container.encode(runs, forKey: .runs)
        try container.encode(rhumbs, forKey: .rhumbs)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let version = try container.decode(Int.self, forKey: .schemaVersion)
        switch version {
        case 1:
            schemaVersion = version
            onboardingComplete = try container.decodeIfPresent(Bool.self, forKey: .onboardingComplete) ?? false
            islands = try container.decode(Islands.self, forKey: .islands)
            books = try container.decode(Books.self, forKey: .books)
            sessions = try container.decode(Sessions.self, forKey: .sessions)
            runs = try container.decode(Runs.self, forKey: .runs)
            rhumbs = try container.decode(Rhumbs.self, forKey: .rhumbs)
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .schemaVersion,
                in: container,
                debugDescription: "Unknown galley schema."
            )
        }
    }
}
