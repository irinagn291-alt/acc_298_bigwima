import Foundation

/// Filed when Begin or Tick happens before the galley is ready to weave.
struct DriftMark: Identifiable, Codable, Equatable, Sendable {
    enum Cause: String, Codable, Equatable, Sendable {
        case begin
        case tick
    }

    var id: UUID
    var cause: Cause
    var filedAt: Date
}
