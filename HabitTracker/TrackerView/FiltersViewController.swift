import UIKit

final class FiltersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private let filters: [(title: String, filter: TrackerFilter)] = [
        ("Все трекеры", .all),
        ("Трекеры на сегодня", .today),
        ("Завершённые", .completed),
        ("Незавершённые", .incomplete)
    ]
    
    private var selectedFilter: TrackerFilter
    private let completion: (TrackerFilter) -> Void
    
    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.isScrollEnabled = false
        return tv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.textColor = UIColor(named: "TextColor")
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "Фильтр"
        return label
    }()
    
    init(selectedFilter: TrackerFilter, completion: @escaping (TrackerFilter) -> Void) {
        self.selectedFilter = selectedFilter
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        tableView.backgroundColor = .background
        
        view.addSubview(tableView)
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.rowHeight = 75
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filters.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        let item = filters[indexPath.row]
        cell.textLabel?.text = item.title
        cell.selectionStyle = .none
        cell.backgroundColor = UIColor(named: "GrayBackground")
        
        if item.filter == selectedFilter {
            cell.accessoryType = .checkmark
            cell.tintColor = .systemBlue
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        let chosenFilter = filters[indexPath.row].filter
        completion(chosenFilter)
        dismiss(animated: true)
    }
}
