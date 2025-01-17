import CoreData

final class TrackerCategoryStore: NSObject {
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>?
    weak var delegate: TrackerCategoryStoreDelegate?
    
    override init() {
        self.context = CoreDataManager.shared.context
        super.init()
        
        let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
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
            print("Failed to fetch categories: \(error)")
        }
    }
    
    var categories: [TrackerCategoryCoreData] {
        fetchedResultsController?.fetchedObjects ?? []
    }
    
    func addCategory(_ category: TrackerCategory) throws {
        let categoryCoreData = TrackerCategoryCoreData(context: context)
        categoryCoreData.title = category.title
        try CoreDataManager.shared.saveContext()
    }
    
    func deleteCategory(_ category: TrackerCategoryCoreData) throws {
        context.delete(category)
        try CoreDataManager.shared.saveContext()
    }
    
    func performFetch() throws {
        try fetchedResultsController?.performFetch()
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdate()
    }
}
