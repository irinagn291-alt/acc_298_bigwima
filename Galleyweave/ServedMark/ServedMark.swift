import Foundation

/// Filed when the last Tick finishes both recipes. Day edges use start of day.
struct ServedMark: Identifiable, Codable, Equatable, Sendable {
    var id: UUID
    var mainRecipeID: UUID
    var sideRecipeID: UUID
    var daykey: Int
    var filedAt: Date
}

enum Daykey {
    static func stamp(_ date: Date, calendar: Calendar = .current) -> Int {
        let start = calendar.startOfDay(for: date)
        let parts = calendar.dateComponents([.year, .month, .day], from: start)
        let year = parts.year ?? 0
        let month = parts.month ?? 0
        let day = parts.day ?? 0
        return year * 10000 + month * 100 + day
    }
}
