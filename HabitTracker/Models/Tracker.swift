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
