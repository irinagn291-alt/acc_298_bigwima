import Foundation

/// Filed when Switch moves the lit lane without taking the current node off the queue.
struct HandoffMark: Identifiable, Codable, Equatable, Sendable {
    var id: UUID
    var fromNodeID: UUID
    var toNodeID: UUID
    var fromLane: WeaveLane
    var toLane: WeaveLane
    var filedAt: Date
    /// YYYYMMDD from `Calendar.startOfDay`, so history can group a night.
    var daykey: Int
}
