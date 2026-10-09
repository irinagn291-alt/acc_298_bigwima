import Foundation

/// An empty galley at rest. Both berths are open and the phase is Bare.
enum Cold {
    static func isResting(_ galley: Galley) -> Bool {
        galley.phase == .bare && galley.main.recipeID == nil && galley.side.recipeID == nil
    }
}
