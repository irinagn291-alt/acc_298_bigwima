import Foundation

/// Filed when Tick completes the lit node. Peel can put that node back.
struct WeaveMark: Identifiable, Codable, Equatable, Sendable {
    var id: UUID
    var node: WeaveNode
    var queueIndex: Int
    var filedAt: Date
}
