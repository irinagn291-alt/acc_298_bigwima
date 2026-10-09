import Foundation

/// The Side plate. Both this and Main must hold a recipe before Begin.
struct SideBerth: Equatable, Sendable, Codable {
    var recipeID: UUID?

    var berth: Berth { Berth(lane: .side, recipeID: recipeID) }
    var isOpen: Bool { recipeID == nil }
}
