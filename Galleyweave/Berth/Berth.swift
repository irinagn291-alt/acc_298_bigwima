import Foundation

/// Which plate a recipe sits on. Main sorts ahead of Side when step timers tie.
enum WeaveLane: String, Codable, Equatable, Sendable {
    case main
    case side
}

/// One open plate. Empty means the cook still has to Seat a recipe there.
struct Berth: Equatable, Sendable, Codable {
    var lane: WeaveLane
    var recipeID: UUID?

    var isOpen: Bool { recipeID == nil }
}
