import Foundation

/// A node on the interleave rail: an ingredient check or a numbered step.
struct WeaveNode: Identifiable, Codable, Equatable, Sendable {
    enum Kind: String, Codable, Equatable, Sendable {
        case ingredient
        case step
    }

    var id: UUID
    var recipeID: UUID
    var lane: WeaveLane
    var kind: Kind
    var title: String
    var seconds: Int
    /// Step number for step nodes. Ingredient nodes use 0.
    var number: Int
}

enum WeaveQueue {
    /// Ingredients for Main, then Side, then steps by ascending timer.
    /// Untimed steps follow timed steps. Main precedes Side when timers match.
    static func interleave(main: Recipe, side: Recipe) -> [WeaveNode] {
        let ingredients = ingredientNodes(main, lane: .main) + ingredientNodes(side, lane: .side)
        let steps = (stepNodes(main, lane: .main) + stepNodes(side, lane: .side)).sorted { lhs, rhs in
            let lhsTimed = lhs.seconds > 0
            let rhsTimed = rhs.seconds > 0
            if lhsTimed != rhsTimed { return lhsTimed && !rhsTimed }
            if lhs.seconds != rhs.seconds { return lhs.seconds < rhs.seconds }
            if lhs.lane != rhs.lane { return lhs.lane == .main }
            return lhs.number < rhs.number
        }
        return ingredients + steps
    }

    /// Cook-mode invariant: every ingredient node sits before every step node.
    static func ingredientsPrecedeSteps(_ nodes: [WeaveNode]) -> Bool {
        guard let firstStep = nodes.firstIndex(where: { $0.kind == .step }) else { return true }
        return nodes[firstStep...].allSatisfy { $0.kind == .step }
    }

    private static func ingredientNodes(_ recipe: Recipe, lane: WeaveLane) -> [WeaveNode] {
        recipe.ingredients.map { line in
            WeaveNode(
                id: line.id,
                recipeID: recipe.id,
                lane: lane,
                kind: .ingredient,
                title: line.name,
                seconds: 0,
                number: 0
            )
        }
    }

    private static func stepNodes(_ recipe: Recipe, lane: WeaveLane) -> [WeaveNode] {
        recipe.steps.map { step in
            WeaveNode(
                id: step.id,
                recipeID: recipe.id,
                lane: lane,
                kind: .step,
                title: step.text,
                seconds: step.seconds,
                number: step.number
            )
        }
    }
}
