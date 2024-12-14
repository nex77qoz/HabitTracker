import Foundation

struct TrackerCategory: Equatable {
    let title: String
    var trackers: [Tracker]
    
    static let allCategories: [TrackerCategory] = [
        //        TrackerCategory(title: "Домашний уют", trackers: []),
        //        TrackerCategory(title: "Здоровье", trackers: []),
        //        TrackerCategory(title: "Важное", trackers: []),
    ]
}
