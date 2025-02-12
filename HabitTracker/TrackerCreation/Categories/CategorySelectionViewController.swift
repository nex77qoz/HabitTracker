import UIKit

protocol CategorySelectionDelegate: AnyObject {
    func categorySelected(_ category: TrackerCategoryCoreData)
}

class CategorySelectionViewController: UIViewController {
    
    // MARK: - Properties
    
    private var categories: [TrackerCategoryCoreData] = [] {
        didSet {
            updatePlaceholderVisibility()
            tableView.reloadData()
        }
    }
    
    private let categoryStore = TrackerCategoryStore()
    
    private var selectedCategoryIndex: IndexPath?
    weak var delegate: CategorySelectionDelegate?
    
    // MARK: - UI Elements
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Категория"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(CustomTableViewCell.self, forCellReuseIdentifier: "CategoryCell")
        table.layer.cornerRadius = 16
        table.layer.masksToBounds = true
        table.translatesAutoresizingMaskIntoConstraints = false
        table.separatorStyle = .none
        return table
    }()
    
    private lazy var addCategoryButton = UIButton.roundedButton(
        title: "Добавить категорию",
        backgroundColor: .black,
        titleColor: .white,
        selector: #selector(addCategoryTapped),
        target: self
    )
    
    private let placeholderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: "star")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = "Привычки и события можно \nобъединить по смыслу"
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(imageView)
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        return view
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Категория"
        
        setupLayout()
        setupPlaceholderLayout()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        
        categories = categoryStore.categories
        
        updatePlaceholderVisibility()
    }
    
    // MARK: - Layout
    
    private func setupLayout() {
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        view.addSubview(addCategoryButton)
        view.addSubview(placeholderView)
        
        addCategoryButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -16),
            
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupPlaceholderLayout() {
        NSLayoutConstraint.activate([
            placeholderView.topAnchor.constraint(equalTo: tableView.topAnchor),
            placeholderView.leadingAnchor.constraint(equalTo: tableView.leadingAnchor),
            placeholderView.trailingAnchor.constraint(equalTo: tableView.trailingAnchor),
            placeholderView.bottomAnchor.constraint(equalTo: tableView.bottomAnchor)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func addCategoryTapped() {
        let categoryCreationVC = CategoryCreationVC()
        categoryCreationVC.delegate = self
        present(categoryCreationVC, animated: true)
    }
    
    private func deleteCategory(_ category: TrackerCategoryCoreData, at indexPath: IndexPath) {
        do {
            try categoryStore.deleteCategory(category)
            try categoryStore.performFetch()
            categories = categoryStore.categories
        } catch {
            print("Error deleting category: \(error)")
        }
    }
    
    // MARK: - Helpers
    
    private func updatePlaceholderVisibility() {
        let isEmpty = categories.isEmpty
        tableView.isHidden = isEmpty
        placeholderView.isHidden = !isEmpty
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension CategorySelectionViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        categories.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "CategoryCell",
            for: indexPath
        ) as! CustomTableViewCell
        let category = categories[indexPath.row]
        cell.textLabel?.text = category.title
        cell.backgroundColor = .backgroundDay
        let isLastRow = (indexPath.row == categories.count - 1)
        cell.setSeparatorHidden(isLastRow)
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        let chosenCategory = categories[indexPath.row]
        delegate?.categorySelected(chosenCategory)
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    func tableView(_ tableView: UITableView,
                   willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        let corners: UIRectCorner
        if indexPath.row == 0 && categories.count == 1 {
            corners = [.topLeft, .topRight, .bottomLeft, .bottomRight]
        } else if indexPath.row == 0 {
            corners = [.topLeft, .topRight]
        } else if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            corners = [.bottomLeft, .bottomRight]
        } else {
            return
        }
        
        let path = UIBezierPath(
            roundedRect: cell.bounds,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: 16, height: 16)
        )
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        cell.layer.mask = mask
    }
    
    // MARK: - Built-in popup (context menu) for deleting a category
    func tableView(_ tableView: UITableView,
                   contextMenuConfigurationForRowAt indexPath: IndexPath,
                   point: CGPoint) -> UIContextMenuConfiguration? {
        let selectedCategory = categories[indexPath.row]
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            guard let self = self else { return UIMenu() }
            
            let deleteAction = UIAction(
                title: "Удалить",
                image: UIImage(systemName: "trash"),
                attributes: .destructive
            ) { _ in
                self.deleteCategory(selectedCategory, at: indexPath)
            }
            
            return UIMenu(title: "", children: [deleteAction])
        }
    }
}

// MARK: - CategoryCreationDelegate
extension CategorySelectionViewController: CategoryCreationDelegate {
    func didCreateCategory(_ newCategory: TrackerCategory) {
        do {
            try categoryStore.addCategory(newCategory)
            try categoryStore.performFetch()
            categories = categoryStore.categories
        } catch {
            print("Error adding category: \(error)")
        }
    }
}
