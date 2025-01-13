import CoreData

final class TrackerRecordStore: NSObject {
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData>?
    weak var delegate: TrackerRecordStoreDelegate?
    
    override init() {
        self.context = CoreDataManager.shared.context
        super.init()
        
        let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        fetchedResultsController?.delegate = self
        
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print("Failed to fetch records: \(error)")
        }
    }
    
    var records: [TrackerRecordCoreData] {
        return fetchedResultsController?.fetchedObjects ?? []
    }
    
    func addRecord(_ record: TrackerRecord, tracker: TrackerCoreData) throws {
        let recordCoreData = TrackerRecordCoreData(context: context)
        recordCoreData.trackerId = record.trackerId
        recordCoreData.date = record.date
        recordCoreData.tracker = tracker
        try CoreDataManager.shared.saveContext()
    }
    
    func fetchRecords() throws -> [TrackerRecordCoreData] {
        let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        return try context.fetch(request)
    }
    
    func deleteRecord(_ record: TrackerRecordCoreData) throws {
        context.delete(record)
        try CoreDataManager.shared.saveContext()
    }
}

extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdate()
    }
}
