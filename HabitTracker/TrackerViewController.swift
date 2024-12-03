import UIKit

// MARK: - Протокол делегата ячейки трекера

protocol TrackerCellDelegate: AnyObject {
    func trackerCell(_ cell: TrackerCell, didToggleCompletionFor tracker: Tracker)
}

// MARK: - Расширение для работы с датами

extension Date {
    func startOfDay() -> Date {
        Calendar.current.startOfDay(for: self)
    }
}

// MARK: - Основной контроллер трекеров

final class TrackerViewController: UIViewController {
    
    // MARK: - Приватные свойства
    
    private let categories: [TrackerCategory] = [
        TrackerCategory(title: "Домашний уют", trackers: [
            Tracker(id: UUID(), name: "Поливать растения", color: "Color selection 1", emoji: "🪴",
                    schedule: Schedule(daysOfWeek: [true, false, true, false, true, false, true]))
        ]),
        TrackerCategory(title: "Здоровье", trackers: [
            Tracker(id: UUID(), name: "Сделал зарядку", color: "Color selection 2", emoji: "💪",
                    schedule: Schedule(daysOfWeek: [true, true, true, true, true, false, true])),
            Tracker(id: UUID(), name: "Не ел сладкого", color: "Color selection 3", emoji: "🍫",
                    schedule: Schedule(daysOfWeek: [true, true, true, true, true, false, false])),
            Tracker(id: UUID(), name: "Сходил на работу пешком", color: "Color selection 4", emoji: "🦶",
                    schedule: Schedule(daysOfWeek: [true, true, true, true, true, false, false]))
        ])
    ]
    
    private var completedTrackers: [TrackerRecord] = []
    
    private var currentWeekday: Int {
        Calendar.current.component(.weekday, from: datePicker.date) - 1
    }
    
    // MARK: - UI-компоненты
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.locale = Locale(identifier: "ru_RU")
        picker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
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
    private let placeholderStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 8
        stackView.isHidden = true
        
        let starImageView = UIImageView(image: UIImage(named: "star"))
        starImageView.contentMode = .scaleAspectFit
        starImageView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        starImageView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        let placeholderLabel = UILabel()
        placeholderLabel.text = "Что будем отслеживать?"
        placeholderLabel.textAlignment = .center
        placeholderLabel.font = .systemFont(ofSize: 12, weight: .medium)
        
        stackView.addArrangedSubview(starImageView)
        stackView.addArrangedSubview(placeholderLabel)
        
        return stackView
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
    
    // MARK: - Настройка интерфейса
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(titleLabel)
        view.addSubview(searchBar)
        view.addSubview(collectionView)
        view.addSubview(placeholderStackView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        [titleLabel, searchBar, collectionView, placeholderStackView].forEach {
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
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            placeholderStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20)
        ])
    }
    
    private func setupNavigationBar() {
        let plusImage = UIImage(named: "plus")?.withRenderingMode(.alwaysOriginal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: plusImage, style: .plain, target: self, action: #selector(showAddTracker))
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
    
    // MARK: - Обработчики действий
    
    @objc private func showAddTracker() {
        let alert = UIAlertController(title: "Тестовый алерт", message: "Кнопка нажата", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        collectionView.reloadData()
        updatePlaceholderVisibility()
    }
    
    // MARK: - Вспомогательные методы
    
    private func updatePlaceholderVisibility() {
        let weekday = currentWeekday
        let trackersForCurrentDay = categories.flatMap { category in
            category.trackers.filter { $0.schedule.daysOfWeek[weekday] }
        }
        
        let hasTrackersForCurrentDay = !trackersForCurrentDay.isEmpty
        
        collectionView.isHidden = !hasTrackersForCurrentDay
        placeholderStackView.isHidden = hasTrackersForCurrentDay
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
        
        // Определяем, выполнен ли трекер на выбранную дату
        let selectedDate = datePicker.date.startOfDay()
        let isCompleted = completedTrackers.contains { $0.trackerId == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
        
        // Вычисляем количество выполненных дней для данного трекера
        let daysCount = completedTrackers.filter { $0.trackerId == tracker.id }.count
        
        // Проверяем, является ли выбранная дата будущей
        let isFutureDate = selectedDate > Date().startOfDay()
        
        // Передаём isFutureDate в ячейку
        cell.configure(with: tracker, completed: isCompleted, daysCount: daysCount, isFutureDate: isFutureDate)
        cell.delegate = self
        
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
    
    weak var delegate: TrackerCellDelegate?
    private var tracker: Tracker?
    private var isFutureDate: Bool = false
    
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
        
        completeButton.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
    }
    
    @objc private func completeButtonTapped() {
        guard !isFutureDate, let tracker = tracker else { return }
        delegate?.trackerCell(self, didToggleCompletionFor: tracker)
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
    
    func configure(with tracker: Tracker, completed: Bool, daysCount: Int, isFutureDate: Bool) {
        self.tracker = tracker
        titleLabel.text = tracker.name
        emojiLabel.text = tracker.emoji
        mainView.backgroundColor = color(from: tracker.color)
        completeButtonContainer.backgroundColor = color(from: tracker.color)
        
        // Установка состояния кнопки
        let title = completed ? "✓" : "+"
        completeButton.setTitle(title, for: .normal)
        
        // Установка количества выполненных дней
        daysLabel.text = "\(daysCount) дней"
        
        // Настройка кнопки в зависимости от даты
        if isFutureDate {
            completeButton.setTitle("+", for: .normal)
            completeButton.isEnabled = false
            completeButtonContainer.backgroundColor = UIColor.lightGray
        } else {
            completeButton.isEnabled = true
            completeButtonContainer.backgroundColor = color(from: tracker.color)
        }
        
        // Установка состояния ячейки
        self.isFutureDate = isFutureDate
        
        if isFutureDate {
            completeButton.setTitle("+", for: .normal)
            completeButton.isEnabled = false
            completeButtonContainer.backgroundColor = color(from: tracker.color)
            completeButton.alpha = 0.5
        } else {
            completeButton.isEnabled = true
            completeButtonContainer.backgroundColor = color(from: tracker.color)
            completeButton.alpha = 1.0
        }
        
    }
    
    // MARK: - Цвета
    
    private func color(from colorName: String) -> UIColor {
        return UIColor(named: colorName) ?? UIColor.systemGray5
    }
}

// MARK: - TrackerCellDelegate

extension TrackerViewController: TrackerCellDelegate {
    func trackerCell(_ cell: TrackerCell, didToggleCompletionFor tracker: Tracker) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        
        let selectedDate = datePicker.date.startOfDay()
        
        if let existingRecordIndex = completedTrackers.firstIndex(where: { $0.trackerId == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }) {
            // Если запись существует, удалить её (отметка как невыполнено)
            completedTrackers.remove(at: existingRecordIndex)
        } else {
            // Иначе, добавить новую запись (отметка как выполнено)
            let newRecord = TrackerRecord(trackerId: tracker.id, date: selectedDate)
            completedTrackers.append(newRecord)
        }
        
        // Перезагрузить конкретную ячейку для обновления состояния кнопки и daysCount
        collectionView.reloadItems(at: [indexPath])
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
