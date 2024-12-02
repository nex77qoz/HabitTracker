import Foundation

struct Tracker {
    let id: UUID
    let name: String
    let color: String
    let emoji: String
    let schedule: Schedule
}

struct TrackerCategory {
    let title: String
    let trackers: [Tracker]
}

struct TrackerRecord {
    let trackerId: UUID
    let date: Date
}

struct Schedule {
    let daysOfWeek: [Bool] // Массив из 7 элементов, где true означает, что трекер активен в этот день недели
}

