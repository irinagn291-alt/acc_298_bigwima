import Foundation

/// Peel drops the latest WeaveMark or HandoffMark while Weaving. Served refuses it.
enum Peel {
    static func apply(to galley: inout Galley) -> FoldEffect {
        guard galley.phase == .weaving else { return .peelRefused }
        guard let last = galley.tape.popLast() else { return .peelRefused }
        switch last {
        case .weave(let mark):
            let index = min(max(mark.queueIndex, 0), galley.queue.count)
            galley.queue.insert(mark.node, at: index)
            galley.litID = mark.node.id
            return .peeled
        case .handoff(let mark):
            galley.keptHandoffs.removeAll { $0.id == mark.id }
            galley.litID = mark.fromNodeID
            return .peeled
        case .drift:
            galley.tape.append(last)
            return .peelRefused
        }
    }
}
