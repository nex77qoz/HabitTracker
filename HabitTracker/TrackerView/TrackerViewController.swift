import UIKit

final class TrackerViewController: UIViewController {

    // MARK: - UI-компоненты
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.locale = .autoupdatingCurrent
        picker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        return picker
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("trackersTitle", comment: "Заголовок")
        label.font = .systemFont(ofSize: 34, weight: .bold)
        return label
    }()
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = NSLocalizedString("searchPlaceholder", comment: "Плейсхолдер для поиска")
        searchBar.searchBarStyle = .minimal
        return searchBar
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .background
        collectionView.dataSource = presenter
        collectionView.delegate = self
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.identifier)
        collectionView.register(
            TrackerHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrackerHeaderView.identifier
        )
        return collectionView
    }()
    
    private let placeholderStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 8
        stackView.isHidden = true
        
        let imageView = UIImageView(image: UIImage(named: "star"))
        imageView.contentMode = .scaleAspectFit
        imageView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        let placeholderLabel = UILabel()
        placeholderLabel.text = NSLocalizedString("placeholderWhatToTrack", comment: "Плейсхолдер что будем отслеживать?")
        placeholderLabel.textAlignment = .center
        placeholderLabel.font = .systemFont(ofSize: 12, weight: .medium)
        
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(placeholderLabel)
        
        return stackView
    }()
    
    private lazy var filterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("filtersButton", comment: "Кнопка фильтров"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Presenter
    
    private lazy var presenter = TrackerPresenter(view: self)
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        searchBar.delegate = self
        
        collectionView.contentInset.bottom = 100
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.updatePlaceholderVisibility()
        updateFilterButtonVisibility()
    }
    
    // MARK: - Настройка интерфейса
    
    private func setupUI() {
        view.backgroundColor = .background
        
        view.addSubview(titleLabel)
        view.addSubview(searchBar)
        view.addSubview(collectionView)
        view.addSubview(placeholderStackView)
        view.addSubview(filterButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        [titleLabel, searchBar, collectionView, placeholderStackView, filterButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            searchBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            placeholderStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            
            filterButton.heightAnchor.constraint(equalToConstant: 60),
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.4),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
        ])
    }
    
    private func setupNavigationBar() {
        let plusButton = UIBarButtonItem(title: "+",
                                         style: .plain,
                                         target: self,
                                         action: #selector(showAddTracker))
        
        plusButton.tintColor = UIColor(named: "TextColor")
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 24)]
        plusButton.setTitleTextAttributes(attributes, for: .normal)
        
        navigationItem.leftBarButtonItem = plusButton
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
    
    // MARK: - Действия
    
    @objc private func showAddTracker() {
        let createTrackerVC = CreateTrackerViewController()
        createTrackerVC.modalPresentationStyle = .pageSheet
        present(createTrackerVC, animated: true, completion: nil)
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        presenter.datePickerValueChanged(date: sender.date)
    }
    
    @objc private func filterButtonTapped() {
        let filtersVC = FiltersViewController(selectedFilter: presenter.currentFilter) { [weak self] newFilter in
            self?.presenter.setFilter(newFilter)
        }
        filtersVC.modalPresentationStyle = .pageSheet
        present(filtersVC, animated: true)
    }
    
    // MARK: - Дополнительные методы
    
    func updateFilterButtonVisibility() {
        let hasTrackers = presenter.hasAnyTrackersForSelectedDay()
        let filterIsAll = (presenter.currentFilter == .all)

        filterButton.isHidden = (!hasTrackers && filterIsAll)
    }
}

// MARK: - TrackerViewProtocol

extension TrackerViewController: TrackerViewProtocol {
    func reloadCollectionView() {
        collectionView.reloadData()
    }
    
    func updatePlaceholderVisibility(isHidden: Bool) {
        collectionView.isHidden = !isHidden
        placeholderStackView.isHidden = isHidden
        
        let placeholderLabel = placeholderStackView.arrangedSubviews[1] as? UILabel
        if !isHidden && !(searchBar.text?.isEmpty ?? true) {
            placeholderLabel?.text = NSLocalizedString("placeholderNothingFound", comment: "Если ничего не найдено")
        } else {
            placeholderLabel?.text = NSLocalizedString("placeholderWhatToTrack", comment: "")
        }
        
        updateFilterButtonVisibility()
    }
    
    func reloadItems(at indexPaths: [IndexPath]) {
        collectionView.reloadItems(at: indexPaths)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let totalSpacing: CGFloat = 48
        let width = (collectionView.frame.width - totalSpacing) / 2
        return CGSize(width: width, height: 175)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50)
    }
}

// MARK: - UICollectionViewDelegate
extension TrackerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemAt indexPath: IndexPath,
                        point: CGPoint) -> UIContextMenuConfiguration? {
        let tracker = presenter.dailySections[indexPath.section].trackers[indexPath.item]
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            let deleteAction = UIAction(title: NSLocalizedString("delete", comment: "Delete action"),
                                        image: UIImage(systemName: "trash"),
                                        attributes: .destructive) { _ in
                let alert = UIAlertController(
                    title: NSLocalizedString("deleteTrackerTitle", comment: ""),
                    message: NSLocalizedString("deleteTrackerMessage", comment: ""),
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: NSLocalizedString("delete", comment: ""), style: .destructive, handler: { _ in
                    self?.presenter.deleteTracker(tracker)
                }))
                self?.present(alert, animated: true, completion: nil)
            }
            
            let editAction = UIAction(
                title: NSLocalizedString("edit", comment: "Edit action"),
                image: UIImage(systemName: "pencil")
            ) { [weak self] _ in
                guard let self = self else { return }
                let tracker = self.presenter.dailySections[indexPath.section].trackers[indexPath.item]
                
                let editVC = EditTrackerViewController(tracker: tracker)
                editVC.modalPresentationStyle = .pageSheet
                self.present(editVC, animated: true)
            }
            
            let pinTitle = tracker.isPinned
              ? NSLocalizedString("unpin", comment: "Unpin action")
              : NSLocalizedString("pin", comment: "Pin action")
            let pinImage = tracker.isPinned ? "pin.slash" : "pin"
            let pinAction = UIAction(
                title: pinTitle,
                image: UIImage(systemName: pinImage)
            ) { [weak self] _ in
                self?.presenter.togglePinned(for: tracker)
            }
            
            return UIMenu(title: "", children: [pinAction, editAction, deleteAction])
        }
    }
}

extension TrackerViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        presenter.filter(with: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
