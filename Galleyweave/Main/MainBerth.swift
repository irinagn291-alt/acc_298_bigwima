import Foundation

/// The Main plate. Seat writes one cookbook recipe here and no second one until Serve.
struct MainBerth: Equatable, Sendable, Codable {
    var recipeID: UUID?

    var berth: Berth { Berth(lane: .main, recipeID: recipeID) }
    var isOpen: Bool { recipeID == nil }
}
