import Foundation

/// A saved or catalog meal. Seat copies one onto Main or Side. Steps and
/// ingredient lines are the only source the interleave queue is built from.
struct Recipe: Identifiable, Codable, Equatable, Sendable {
    var id: UUID
    var catalogID: String?
    var title: String
    var ingredients: [IngredientLine]
    var steps: [NumberedStep]
    var thumbnailURL: String?

    init(
        id: UUID,
        catalogID: String? = nil,
        title: String,
        ingredients: [IngredientLine],
        steps: [NumberedStep],
        thumbnailURL: String? = nil
    ) {
        self.id = id
        self.catalogID = catalogID
        self.title = title
        self.ingredients = ingredients
        self.steps = steps
        self.thumbnailURL = thumbnailURL
    }
}

/// One ingredient line on a recipe. Cook mode checks these before numbered steps.
struct IngredientLine: Identifiable, Codable, Equatable, Sendable {
    var id: UUID
    var name: String
    var measure: String
}

/// A numbered cook step. `seconds` is 0 when the line has no minute phrase.
struct NumberedStep: Identifiable, Codable, Equatable, Sendable {
    var id: UUID
    var number: Int
    var text: String
    var seconds: Int
}

enum ShelfUUID {
    static func make(_ tail: UInt8) -> UUID {
        UUID(uuid: (0x10, 0, 0, 0, 0, 0x40, 0, 0x80, 0, 0, 0, 0, 0, 0, 0, tail))
    }

    static func line(meal: UInt8, slot: UInt8) -> UUID {
        UUID(uuid: (0x11, meal, slot, 0, 0, 0x40, 0, 0x80, 0, 0, 0, 0, 0, 0, 0, 1))
    }
}

/// Bundled meals so search can fall back on this device. Seed seats the first two.
enum BundledShelf {
    static let herbChickenID = ShelfUUID.make(1)
    static let lemonGreensID = ShelfUUID.make(2)
    static let butterBeansID = ShelfUUID.make(3)
    static let ricePilafID = ShelfUUID.make(4)

    static let herbChicken = meal(
        herbChickenID,
        catalog: "shelf.herb-chicken",
        title: "Herb chicken",
        ingredients: [("Chicken thighs", "4"), ("Thyme", "4 sprigs"), ("Salt", "a pinch")],
        steps: [
            (1, "Pat the chicken dry and salt it.", 0),
            (2, "Sear the thighs for 8 minutes.", 8 * 60),
            (3, "Rest the chicken.", 0)
        ]
    )

    static let lemonGreens = meal(
        lemonGreensID,
        catalog: "shelf.lemon-greens",
        title: "Lemon greens",
        ingredients: [("Greens", "1 bunch"), ("Lemon", "1"), ("Oil", "1 spoon")],
        steps: [
            (1, "Rinse the greens.", 0),
            (2, "Wilt them for 3 minutes.", 3 * 60),
            (3, "Finish with lemon.", 0)
        ]
    )

    static let butterBeans = meal(
        butterBeansID,
        catalog: "shelf.butter-beans",
        title: "Butter beans",
        ingredients: [("Butter beans", "1 tin"), ("Garlic", "1 clove")],
        steps: [
            (1, "Warm the beans for 6 minutes.", 6 * 60),
            (2, "Stir in the garlic.", 0)
        ]
    )

    static let ricePilaf = meal(
        ricePilafID,
        catalog: "shelf.rice-pilaf",
        title: "Rice pilaf",
        ingredients: [("Rice", "1 cup"), ("Stock", "2 cups")],
        steps: [
            (1, "Rinse the rice.", 0),
            (2, "Simmer the rice for 15 minutes.", 15 * 60)
        ]
    )

    static let meals: [Recipe] = [herbChicken, lemonGreens, butterBeans, ricePilaf]
    static let shelfIDs: [String] = meals.compactMap(\.catalogID)

    private static func tail(of id: UUID) -> UInt8 {
        id.uuid.15
    }

    private static func meal(
        _ id: UUID,
        catalog: String,
        title: String,
        ingredients: [(String, String)],
        steps: [(Int, String, Int)]
    ) -> Recipe {
        Recipe(
            id: id,
            catalogID: catalog,
            title: title,
            ingredients: ingredients.enumerated().map { offset, pair in
                IngredientLine(id: ShelfUUID.line(meal: tail(of: id), slot: UInt8(offset)), name: pair.0, measure: pair.1)
            },
            steps: steps.enumerated().map { offset, step in
                NumberedStep(
                    id: ShelfUUID.line(meal: tail(of: id), slot: UInt8(20 + offset)),
                    number: step.0,
                    text: step.1,
                    seconds: step.2
                )
            }
        )
    }
}
