//
//  Structs.swift
import Foundation

struct Tracker: Equatable {
    let id: UUID
    let name: String
    let color: String
    let emoji: String
    let schedule: Schedule?
    let isIrregular: Bool
    
    init(id: UUID, name: String, color: String, emoji: String, schedule: Schedule?) {
        self.id = id
        self.name = name
        self.color = color
        self.emoji = emoji
        self.schedule = schedule
        self.isIrregular = schedule == nil
    }
}


struct TrackerCategory: Equatable {
    let title: String
    var trackers: [Tracker]
    
    static let allCategories: [TrackerCategory] = [
        TrackerCategory(title: "Домашний уют", trackers: []),
        TrackerCategory(title: "Здоровье", trackers: []),
        TrackerCategory(title: "Важное", trackers: []),
    ]
}

struct TrackerRecord {
    let trackerId: UUID
    let date: Date
}

struct Schedule: Equatable {
    let daysOfWeek: [Bool]
}
struct Emojis {
    static let list: [String] = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱",
        "😇", "😡", "🥶", "🤔", "🙌", "🍔",
        "🥦", "🏓", "🥇", "🎸", "🏝", "😪"
    ]
}
struct Colors {
        static let list: [String] = (1...18).map { "Color selection \($0)" }
}
