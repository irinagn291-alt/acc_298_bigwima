import Foundation

/// Closed phase set for the galley fold. Cold is Bare with both berths empty, not a fifth case.
enum GalleyPhase: String, Codable, Equatable, Sendable {
    case bare
    case seated
    case weaving
    case served
}

/// One entry on the open weave tape. Served nights live apart from this tape.
enum RunMark: Codable, Equatable, Sendable {
    case weave(WeaveMark)
    case handoff(HandoffMark)
    case drift(DriftMark)
}

/// What a fold step did. The store persists after a mark. Drift is not a success.
enum FoldEffect: Equatable, Sendable {
    case seated
    case berthFilled
    case refused
    case drift
    case weaving
    case arm(nodeID: UUID, seconds: Int)
    case advanced
    case served(ServedMark)
    case handoff
    case peeled
    case peelRefused
}

/// In-memory galley. Pure fold over the two berths and the remaining weave nodes.
struct Galley: Equatable, Sendable {
    var phase: GalleyPhase
    var main: MainBerth
    var side: SideBerth
    var queue: [WeaveNode]
    var litID: UUID?
    var tape: [RunMark]
    var keptHandoffs: [HandoffMark]
    var served: [ServedMark]
    /// Node waiting on a local timer. Not persisted. Idle sleep is derived from phase.
    var armedNodeID: UUID?

    static func cold() -> Galley {
        Galley(
            phase: .bare,
            main: MainBerth(recipeID: nil),
            side: SideBerth(recipeID: nil),
            queue: [],
            litID: nil,
            tape: [],
            keptHandoffs: [],
            served: [],
            armedNodeID: nil
        )
    }

    var holdsIdleSleep: Bool { phase == .weaving }

    var canBegin: Bool {
        phase == .seated && main.recipeID != nil && side.recipeID != nil
    }

    var litNode: WeaveNode? {
        guard let litID else { return nil }
        return queue.first { $0.id == litID }
    }

    /// Seat one cookbook recipe onto an empty berth. A third recipe is refused.
    mutating func seat(recipeID: UUID, on lane: WeaveLane) -> FoldEffect {
        if main.recipeID != nil && side.recipeID != nil {
            return .refused
        }
        switch lane {
        case .main:
            if main.recipeID != nil { return .refused }
            main.recipeID = recipeID
        case .side:
            if side.recipeID != nil { return .refused }
            side.recipeID = recipeID
        }
        if main.recipeID != nil && side.recipeID != nil {
            phase = .seated
            queue = []
            litID = nil
            armedNodeID = nil
            return .seated
        }
        phase = .bare
        return .berthFilled
    }

    /// Begin builds the interleave only from Seated. An empty berth writes DriftMark.
    mutating func begin(mainRecipe: Recipe, sideRecipe: Recipe, now: Date = Date()) -> FoldEffect {
        if main.recipeID == nil || side.recipeID == nil {
            tape.append(.drift(DriftMark(id: UUID(), cause: .begin, filedAt: now)))
            return .drift
        }
        guard phase == .seated,
              main.recipeID == mainRecipe.id,
              side.recipeID == sideRecipe.id
        else {
            tape.append(.drift(DriftMark(id: UUID(), cause: .begin, filedAt: now)))
            return .drift
        }
        queue = WeaveQueue.interleave(main: mainRecipe, side: sideRecipe)
        litID = queue.first?.id
        armedNodeID = nil
        phase = .weaving
        return .weaving
    }

    /// Tick files an untimed lit node, or arms a timed one. Outside Weaving it drifts.
    mutating func tick(now: Date = Date(), calendar: Calendar = .current) -> FoldEffect {
        guard phase == .weaving else {
            tape.append(.drift(DriftMark(id: UUID(), cause: .tick, filedAt: now)))
            return .drift
        }
        guard let node = litNode, let index = queue.firstIndex(where: { $0.id == node.id }) else {
            return .refused
        }
        if node.seconds > 0 && armedNodeID != node.id {
            armedNodeID = node.id
            return .arm(nodeID: node.id, seconds: node.seconds)
        }
        return file(node: node, index: index, now: now, calendar: calendar)
    }

    /// The local timer finished. Files the armed node if it is still lit.
    mutating func completeArmedTick(nodeID: UUID, now: Date = Date(), calendar: Calendar = .current) -> FoldEffect {
        guard phase == .weaving, armedNodeID == nodeID, litID == nodeID else {
            return .refused
        }
        guard let node = litNode, let index = queue.firstIndex(where: { $0.id == node.id }) else {
            return .refused
        }
        return file(node: node, index: index, now: now, calendar: calendar)
    }

    /// Switch writes a HandoffMark and moves the lit lane. The current node stays queued.
    mutating func switchLane(now: Date = Date(), calendar: Calendar = .current) -> FoldEffect {
        guard phase == .weaving, let current = litNode else { return .refused }
        guard let other = queue.first(where: { $0.lane != current.lane && $0.id != current.id }) else {
            return .refused
        }
        let mark = HandoffMark(
            id: UUID(),
            fromNodeID: current.id,
            toNodeID: other.id,
            fromLane: current.lane,
            toLane: other.lane,
            filedAt: now,
            daykey: Daykey.stamp(now, calendar: calendar)
        )
        tape.append(.handoff(mark))
        keptHandoffs.append(mark)
        litID = other.id
        armedNodeID = nil
        return .handoff
    }

    private mutating func file(node: WeaveNode, index: Int, now: Date, calendar: Calendar) -> FoldEffect {
        queue.remove(at: index)
        armedNodeID = nil
        tape.append(.weave(WeaveMark(id: UUID(), node: node, queueIndex: index, filedAt: now)))
        if queue.isEmpty {
            let servedMark = ServedMark(
                id: UUID(),
                mainRecipeID: main.recipeID ?? node.recipeID,
                sideRecipeID: side.recipeID ?? node.recipeID,
                daykey: Daykey.stamp(now, calendar: calendar),
                filedAt: now
            )
            served.append(servedMark)
            main.recipeID = nil
            side.recipeID = nil
            litID = nil
            phase = .served
            tape.removeAll()
            return .served(servedMark)
        }
        litID = queue.first?.id
        return .advanced
    }
}
