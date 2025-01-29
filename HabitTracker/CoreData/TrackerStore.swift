import CoreData

final class TrackerStore: NSObject {
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>?
    weak var delegate: TrackerStoreDelegate?
    
    override init() {
        self.context = CoreDataManager.shared.context
        super.init()
        
        let request = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        request.sortDescriptors = [
            NSSortDescriptor(key: "category.title", ascending: true),
            NSSortDescriptor(key: "name", ascending: true)
        ]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: "category.title",
            cacheName: nil
        )
        fetchedResultsController?.delegate = self
        
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print("Failed to fetch trackers: \(error)")
        }
    }
    
    var trackers: [TrackerCoreData] {
        return fetchedResultsController?.fetchedObjects ?? []
    }
    
    func trackersForCategory(_ category: TrackerCategoryCoreData) -> [TrackerCoreData] {
        return fetchedResultsController?.fetchedObjects?.filter { $0.category == category } ?? []
    }
    
    func addTracker(_ tracker: Tracker, category: TrackerCategoryCoreData) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.color = tracker.color
        trackerCoreData.emoji = tracker.emoji
        if let schedule = tracker.schedule {
            let encoder = JSONEncoder()
            if let data = try? encoder.encode(schedule) {
                trackerCoreData.schedule = data as NSObject
            } else {
                print("Failed to encode schedule")
            }
        } else {
            trackerCoreData.schedule = nil
        }
        trackerCoreData.isIrregular = tracker.isIrregular
        trackerCoreData.category = category
        try CoreDataManager.shared.saveContext()
    }
    
    func fetchTrackers() throws -> [TrackerCoreData] {
        let request = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        return try context.fetch(request)
    }
    
    func deleteTracker(_ tracker: TrackerCoreData) throws {
        context.delete(tracker)
        try CoreDataManager.shared.saveContext()
    }
    
    func togglePinned(for tracker: TrackerCoreData) throws {
        tracker.isPinned.toggle()
        try CoreDataManager.shared.saveContext()
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdate()
    }
}
