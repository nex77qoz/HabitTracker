import UIKit

// MARK: - TrackerViewController

class TrackerViewController: UIViewController {
    
    // MARK: - Свойства
    
    private var categories: [TrackerCategory] = [
        TrackerCategory(title: "Домашний уют", trackers: [
            Tracker(id: UUID(), name: "Поливать растения", color: "green", emoji: "🪴",
                    schedule: Schedule(daysOfWeek: [true, false, true, false, true, false, true]))
        ]),
        TrackerCategory(title: "Здоровье", trackers: [
            Tracker(id: UUID(), name: "Сделал зарядку", color: "orange", emoji: "💪",
                    schedule: Schedule(daysOfWeek: [true, true, true, true, true, false, true])),
            Tracker(id: UUID(), name: "Не ел сладкого", color: "red", emoji: "🍫",
                    schedule: Schedule(daysOfWeek: [true, true, true, true, true, false, false])),
            Tracker(id: UUID(), name: "Сходил на работу пешком", color: "blue", emoji: "🦶",
                    schedule: Schedule(daysOfWeek: [true, true, true, true, true, false, false]))
        ])
    ]
    
    private var completedTrackers: [TrackerRecord] = []
    private var currentWeekday: Int {
        return Calendar.current.component(.weekday, from: datePicker.date) - 1
    }
    
    // MARK: - Интерфейс
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.locale = Locale(identifier: "ru_RU")
        picker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        return picker
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Трекеры"
        label.font = .systemFont(ofSize: 34, weight: .bold)
        return label
    }()
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Поиск"
        searchBar.searchBarStyle = .minimal
        return searchBar
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.identifier)
        collectionView.register(TrackerHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: TrackerHeaderView.identifier)
        return collectionView
    }()
    
    // Плейсхолдеры
    private let starImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "star")
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        return imageView
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.isHidden = true
        return label
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updatePlaceholderVisibility()
    }
    
    // MARK: - Setup Methods
    
    private func setupUI() {
        view.backgroundColor = .white
        
        [titleLabel, searchBar, collectionView, starImageView, placeholderLabel].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            searchBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            starImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            starImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            starImageView.widthAnchor.constraint(equalToConstant: 80),
            starImageView.heightAnchor.constraint(equalToConstant: 80),
            
            placeholderLabel.topAnchor.constraint(equalTo: starImageView.bottomAnchor, constant: 8),
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupNavigationBar() {
        let plusImage = UIImage(named: "plus")?.withRenderingMode(.alwaysOriginal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: plusImage, style: .plain, target: self, action: #selector(showAddTracker))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
    
    // MARK: - Actions
    
    @objc private func showAddTracker() {
        let alert = UIAlertController(title: "Тестовый алерт", message: "Кнопка нажата", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        collectionView.reloadData()
    }
    
    // MARK: - Helper Methods
    
    private func updatePlaceholderVisibility() {
        let hasCategories = !categories.isEmpty
        collectionView.isHidden = !hasCategories
        starImageView.isHidden = hasCategories
        placeholderLabel.isHidden = hasCategories
    }
}

// MARK: - UICollectionView DataSource & Delegate

extension TrackerViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let weekday = currentWeekday
        return categories[section].trackers.filter { $0.schedule.daysOfWeek[weekday] }.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.identifier, for: indexPath) as? TrackerCell else {
            return UICollectionViewCell()
        }
        
        let weekday = currentWeekday
        let filteredTrackers = categories[indexPath.section].trackers.filter { $0.schedule.daysOfWeek[weekday] }
        let tracker = filteredTrackers[indexPath.item]
        cell.configure(with: tracker)
        
        return cell
    }
    
    // Заголовок
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                               withReuseIdentifier: TrackerHeaderView.identifier,
                                                                               for: indexPath) as? TrackerHeaderView else {
            return UICollectionReusableView()
        }
        headerView.titleLabel.text = categories[indexPath.section].title
        return headerView
    }
    
    // Размер Заголовка
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50)
    }
    
    // Размер ячеек
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalSpacing: CGFloat = 48
        let width = (collectionView.frame.width - totalSpacing) / 2
        return CGSize(width: width, height: 175)
    }
}

class TrackerCell: UICollectionViewCell {

    static let identifier = "TrackerCell"

    // MARK: - Элементы интерфейса

    private let mainView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()

    private let circleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        view.layer.cornerRadius = 16 // Половина ширины и высоты чтобы сделать круг
        view.layer.masksToBounds = true
        return view
    }()

    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.textAlignment = .center
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()

    private let daysLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .black
        return label
    }()

    private let completeButtonContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        return view
    }()

    private let completeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("+", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        button.tintColor = .white
        return button
    }()

    // MARK: - Инициализаторы

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        setupSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Subviews и Constraints

    private func setupSubviews() {
        contentView.addSubview(mainView)
        contentView.addSubview(daysLabel)
        contentView.addSubview(completeButtonContainer)

        mainView.addSubview(circleView)
        mainView.addSubview(titleLabel)

        circleView.addSubview(emojiLabel)
        completeButtonContainer.addSubview(completeButton)

        mainView.translatesAutoresizingMaskIntoConstraints = false
        circleView.translatesAutoresizingMaskIntoConstraints = false
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        daysLabel.translatesAutoresizingMaskIntoConstraints = false
        completeButtonContainer.translatesAutoresizingMaskIntoConstraints = false
        completeButton.translatesAutoresizingMaskIntoConstraints = false

        let circleSize: CGFloat = 32
        let padding: CGFloat = 12

        NSLayoutConstraint.activate([
            mainView.topAnchor.constraint(equalTo: contentView.topAnchor),
            mainView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mainView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            circleView.topAnchor.constraint(equalTo: mainView.topAnchor, constant: padding),
            circleView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: padding),
            circleView.widthAnchor.constraint(equalToConstant: circleSize),
            circleView.heightAnchor.constraint(equalToConstant: circleSize),

            emojiLabel.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: circleView.centerYAnchor),
            emojiLabel.widthAnchor.constraint(lessThanOrEqualTo: circleView.widthAnchor, multiplier: 0.8),
            emojiLabel.heightAnchor.constraint(lessThanOrEqualTo: circleView.heightAnchor, multiplier: 0.8),

            titleLabel.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: padding),
            titleLabel.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -padding),
            titleLabel.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: -padding),

            daysLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            daysLabel.topAnchor.constraint(equalTo: mainView.bottomAnchor, constant: 8),

            completeButtonContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            completeButtonContainer.centerYAnchor.constraint(equalTo: daysLabel.centerYAnchor),
            completeButtonContainer.topAnchor.constraint(equalTo: mainView.bottomAnchor, constant: padding),
            completeButtonContainer.widthAnchor.constraint(equalToConstant: 40),
            completeButtonContainer.heightAnchor.constraint(equalToConstant: 40),

            completeButton.centerXAnchor.constraint(equalTo: completeButtonContainer.centerXAnchor),
            completeButton.centerYAnchor.constraint(equalTo: completeButtonContainer.centerYAnchor),

            contentView.bottomAnchor.constraint(equalTo: completeButtonContainer.bottomAnchor, constant: padding)
        ])
    }

    // MARK: - Настройка ячеек

    func configure(with tracker: Tracker) {
        titleLabel.text = tracker.name
        emojiLabel.text = tracker.emoji
        mainView.backgroundColor = color(from: tracker.color)
        completeButtonContainer.backgroundColor = color(from: tracker.color)

        // Пример подсчета количества дней
        let daysCount = tracker.schedule.daysOfWeek.filter { $0 }.count
        daysLabel.text = "\(daysCount) дней"
    }

    // MARK: - Цвета

    private func color(from colorName: String) -> UIColor {
        switch colorName.lowercased() {
            case "green":
                return UIColor.systemGreen
            case "orange":
                return UIColor.systemOrange
            case "red":
                return UIColor.systemRed
            case "blue":
                return UIColor.systemBlue
            case "purple":
                return UIColor.systemPurple
            case "yellow":
                return UIColor.systemYellow
            default:
                return UIColor.systemGray5
        }
    }
}

// MARK: - TrackerHeaderView

class TrackerHeaderView: UICollectionReusableView {
    
    static let identifier = "TrackerHeaderView"
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 19, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
