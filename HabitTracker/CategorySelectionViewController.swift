import UIKit

protocol CategorySelectionDelegate: AnyObject {
    func categorySelected(_ category: TrackerCategory)
}

class CategorySelectionViewController: UIViewController {
    
    private var categories = TrackerCategory.allCategories {
        didSet {
            updatePlaceholderVisibility()
            tableView.reloadData()
        }
    }
    private var selectedCategoryIndex: IndexPath?
    weak var delegate: CategorySelectionDelegate?
    
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
        table.translatesAutoresizingMaskIntoConstraints = false
        table.layer.cornerRadius = 16
        table.layer.masksToBounds = true
        return table
    }()
    
    private lazy var addCategoryButton = UIButton.roundedButton(
        title: "Добавить категорию",
        backgroundColor: .black,
        titleColor: .white,
        selector: #selector(addCategoryTapped),
        target: self
    )

    
    // MARK: - Placeholder View
    
    private let placeholderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: "star")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = "Привычки и события можно \n объединить по смыслу"
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
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Категория"
        view.backgroundColor = .white
        
        setupLayout()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        
        tableView.tableFooterView = UIView()
        
        view.addSubview(placeholderView)
        setupPlaceholderLayout()
        
        updatePlaceholderVisibility()
        addCategoryButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // MARK: - Setup
    
    private func setupLayout() {
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        view.addSubview(addCategoryButton)
        
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
    
    // MARK: - Helper Methods
    
    private func updatePlaceholderVisibility() {
        if categories.isEmpty {
            tableView.isHidden = true
            placeholderView.isHidden = false
        } else {
            tableView.isHidden = false
            placeholderView.isHidden = true
        }
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension CategorySelectionViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "CategoryCell",
            for: indexPath
        ) as! CustomTableViewCell
        cell.textLabel?.text = categories[indexPath.row].title
        cell.backgroundColor = .backgroundDay
        if indexPath.row == categories.count - 1 {
            cell.setSeparatorHidden(true)
        } else {
            cell.setSeparatorHidden(false)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        let chosenCategory = categories[indexPath.row]
        delegate?.categorySelected(chosenCategory)
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let corners: UIRectCorner
        if indexPath.row == 0 && categories.count == 1{
            corners = [.topLeft, .topRight, .bottomLeft, .bottomRight]
        } else if indexPath.row == 0 {
            corners = [.topLeft, .topRight]
        } else if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            corners = [.bottomLeft, .bottomRight]
        } else {
            return
        }
        
        let path = UIBezierPath(roundedRect: cell.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: 16, height: 16))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        cell.layer.mask = mask
    }
}

// MARK: - CategoryCreationDelegate
extension CategorySelectionViewController: CategoryCreationDelegate {
    func didCreateCategory(_ category: TrackerCategory) {
        categories.append(category)
        tableView.reloadData()
    }
}
