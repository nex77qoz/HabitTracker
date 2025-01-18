import Foundation

final class CategorySelectionViewModel {
    // MARK: - Properties
    
    private let categoryStore: TrackerCategoryStore
    
    var categories: [TrackerCategoryCoreData] = [] {
        didSet {
            onCategoriesChange?(categories)
        }
    }
    
    // MARK: - Closures (Bindings)
    
    var onCategoriesChange: (([TrackerCategoryCoreData]) -> Void)?
    
    var onCategorySelected: ((TrackerCategoryCoreData) -> Void)?
    
    // MARK: - Init
    
    init(categoryStore: TrackerCategoryStore) {
        self.categoryStore = categoryStore
        fetchCategories()
    }
    
    // MARK: - Public Methods
    
    func fetchCategories() {
        categories = categoryStore.categories
    }
    
    func selectCategory(at index: Int) {
        guard index < categories.count else { return }
        let selectedCategory = categories[index]
        onCategorySelected?(selectedCategory)
    }
    
    func addCategory(_ category: TrackerCategory) {
        do {
            try categoryStore.addCategory(category)
            try categoryStore.performFetch()
            categories = categoryStore.categories
        } catch {
            print("Error adding category: \(error)")
        }
    }
    
    func deleteCategory(at index: Int) {
        guard index < categories.count else { return }
        let categoryToDelete = categories[index]
        do {
            try categoryStore.deleteCategory(categoryToDelete)
            try categoryStore.performFetch()
            categories = categoryStore.categories
        } catch {
            print("Error deleting category: \(error)")
        }
    }
}
