import UIKit

final class EditTrackerViewController: UIViewController {
    
    // MARK: - Свойства
    
    private let tracker: TrackerCoreData
    
    private let trackerStore = TrackerStore()
    private let recordStore = TrackerRecordStore()
    
    private lazy var completedDaysCount: Int = {
        recordStore.records.filter { $0.trackerId == tracker.id }.count
    }()
    
    private var isScheduled: Bool = false
    
    private var selectedCategory: TrackerCategoryCoreData?
    private var selectedWeekdays = Set<String>()
    private var selectedEmoji: String?
    private var selectedColor: String?
    
    private let emojis = Emojis.list
    private let colors = Colors.list
    
    private var emojiCollectionViewHeightConstraint: NSLayoutConstraint?
    private var colorCollectionViewHeightConstraint: NSLayoutConstraint?
    
    // MARK: - UI-элементы
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Редактирование привычки"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    private let completedDaysLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.textColor = UIColor(named: "TextColor")
        label.text = "0 дней"
        return label
    }()
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.backgroundColor = .systemGray6
        textField.layer.cornerRadius = 16
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftViewMode = .always
        textField.clearButtonMode = .whileEditing
        return textField
    }()
    
    private let settingsTableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "SettingsCell")
        table.layer.cornerRadius = 16
        table.layer.masksToBounds = true
        table.separatorStyle = .none
        table.isScrollEnabled = false
        return table
    }()
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.text = "Emoji"
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    private let emojiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: 52, height: 52)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.register(EmojiCell.self, forCellWithReuseIdentifier: EmojiCell.identifier)
        collection.backgroundColor = .white
        collection.isScrollEnabled = false
        return collection
    }()
    
    private let colorLabel: UILabel = {
        let label = UILabel()
        label.text = "Цвет"
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    private let colorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: 52, height: 52)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.register(ColorCell.self, forCellWithReuseIdentifier: ColorCell.identifier)
        collection.backgroundColor = .white
        collection.isScrollEnabled = false
        return collection
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отменить", for: .normal)
        button.backgroundColor = .systemGray5
        button.setTitleColor(.systemRed, for: .normal)
        button.layer.cornerRadius = 16
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Сохранить", for: .normal)
        button.backgroundColor = .gray
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.isEnabled = false
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Жизненный цикл
    
    init(tracker: TrackerCoreData) {
        self.tracker = tracker
        super.init(nibName: nil, bundle: nil)
        
        loadTrackerDataIntoFields()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        
        setupViews()
        setupConstraints()
        updateSaveButtonState()
        viewDidLayoutSubviews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        emojiCollectionView.reloadData()
        colorCollectionView.reloadData()
        
        let emojiContentHeight = emojiCollectionView.collectionViewLayout.collectionViewContentSize.height
        emojiCollectionViewHeightConstraint?.constant = emojiContentHeight
        
        let colorContentHeight = colorCollectionView.collectionViewLayout.collectionViewContentSize.height
        colorCollectionViewHeightConstraint?.constant = colorContentHeight
        
        view.layoutIfNeeded()
    }
    
    private func loadTrackerDataIntoFields() {
        if let data = tracker.schedule as? Data,
           let schedule = try? JSONDecoder().decode(Schedule.self, from: data) {
            isScheduled = true
            let weekdaysMap = ["Пн","Вт","Ср","Чт","Пт","Сб","Вс"]
            for (i, isOn) in schedule.daysOfWeek.enumerated() {
                if isOn {
                    selectedWeekdays.insert(weekdaysMap[i])
                }
            }
        } else {
            isScheduled = false
        }
        
        selectedCategory = tracker.category
        selectedEmoji = tracker.emoji
        selectedColor = tracker.color
    }
    
    // MARK: - Настройка UI
    
    private func setupViews() {
        completedDaysLabel.text = "\(completedDaysCount) дней"
        
        settingsTableView.delegate = self
        settingsTableView.dataSource = self
        
        emojiCollectionView.delegate = self
        emojiCollectionView.dataSource = self
        colorCollectionView.delegate = self
        colorCollectionView.dataSource = self
        
        nameTextField.text = tracker.name
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(completedDaysLabel)
        contentView.addSubview(nameTextField)
        contentView.addSubview(settingsTableView)
        contentView.addSubview(emojiLabel)
        contentView.addSubview(emojiCollectionView)
        contentView.addSubview(colorLabel)
        contentView.addSubview(colorCollectionView)
        
        view.addSubview(cancelButton)
        view.addSubview(saveButton)
        
        nameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    private func setupConstraints() {
        [scrollView, contentView, titleLabel, completedDaysLabel, nameTextField,
         settingsTableView, emojiLabel, emojiCollectionView,
         colorLabel, colorCollectionView, cancelButton, saveButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        emojiCollectionViewHeightConstraint = emojiCollectionView.heightAnchor.constraint(equalToConstant: 0)
        colorCollectionViewHeightConstraint = colorCollectionView.heightAnchor.constraint(equalToConstant: 0)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -16),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            completedDaysLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            completedDaysLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            nameTextField.topAnchor.constraint(equalTo: completedDaysLabel.bottomAnchor, constant: 16),
            nameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            nameTextField.heightAnchor.constraint(equalToConstant: 44),
            
            settingsTableView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 16),
            settingsTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            settingsTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            settingsTableView.heightAnchor.constraint(equalToConstant: isScheduled ? 150 : 75),
            
            emojiLabel.topAnchor.constraint(equalTo: settingsTableView.bottomAnchor, constant: 24),
            emojiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            
            emojiCollectionView.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 24),
            emojiCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            emojiCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            emojiCollectionViewHeightConstraint!,
            
            colorLabel.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 24),
            colorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            
            colorCollectionView.topAnchor.constraint(equalTo: colorLabel.bottomAnchor, constant: 24),
            colorCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            colorCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            colorCollectionViewHeightConstraint!,
            colorCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            cancelButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.45),
            
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            saveButton.heightAnchor.constraint(equalToConstant: 60),
            saveButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.45)
        ])
    }
    
    // MARK: - Действия (Actions)
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func saveButtonTapped() {
        guard
            let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            !name.isEmpty,
            let emoji = selectedEmoji,
            let color = selectedColor
        else {
            return
        }
        
        var scheduleData: Data? = nil
        if isScheduled {
            let weekdaysMap = ["Пн","Вт","Ср","Чт","Пт","Сб","Вс"]
            var boolArray = [Bool](repeating: false, count: 7)
            for (i, day) in weekdaysMap.enumerated() {
                if selectedWeekdays.contains(day) {
                    boolArray[i] = true
                }
            }
            let newSchedule = Schedule(daysOfWeek: boolArray)
            scheduleData = try? JSONEncoder().encode(newSchedule)
        }
        
        tracker.name = name
        tracker.emoji = emoji
        tracker.color = color
        tracker.isIrregular = !isScheduled
        tracker.schedule = scheduleData as NSObject?
        
        if let category = selectedCategory {
            tracker.category = category
        }
        
        do {
            try CoreDataManager.shared.saveContext()
        } catch {
            print("Ошибка сохранения: \(error)")
        }
        
        dismiss(animated: true)
    }
    
    @objc private func textFieldDidChange() {
        updateSaveButtonState()
    }
    
    private func updateSaveButtonState() {
        let hasName = !(nameTextField.text?.trimmingCharacters(in: .whitespaces).isEmpty ?? true)
        let hasEmoji = (selectedEmoji != nil)
        let hasColor = (selectedColor != nil)
        
        if hasName, hasEmoji, hasColor {
            saveButton.isEnabled = true
            saveButton.backgroundColor = .black
        } else {
            saveButton.isEnabled = false
            saveButton.backgroundColor = .gray
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension EditTrackerViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int { 1 }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isScheduled ? 2 : 1
    }
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)
        cell.selectionStyle = .none
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = .systemGray6
        
        if indexPath.row == 0 {
            if let category = selectedCategory {
                cell.textLabel?.text = "Категория: \(category.title ?? "")"
            } else {
                cell.textLabel?.text = "Выбрать категорию"
            }
        } else {
            if selectedWeekdays.isEmpty {
                cell.textLabel?.text = "Расписание"
            } else {
                let daysOrder = ["Пн","Вт","Ср","Чт","Пт","Сб","Вс"]
                let sortedDays = daysOrder.filter { selectedWeekdays.contains($0) }
                let joined = sortedDays.joined(separator: ", ")
                cell.textLabel?.text = "Расписание: \(joined)"
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let catStore = TrackerCategoryStore()
            let vm = CategorySelectionViewModel(categoryStore: catStore)
            let catVC = CategorySelectionViewController(viewModel: vm)
            catVC.delegate = self
            catVC.modalPresentationStyle = .pageSheet
            present(catVC, animated: true)
        } else {
            let scheduleVC = ScheduleSelectionViewController()
            scheduleVC.selectedDays = selectedWeekdays
            scheduleVC.delegate = self
            scheduleVC.modalPresentationStyle = .pageSheet
            present(scheduleVC, animated: true)
        }
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension EditTrackerViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return (collectionView == emojiCollectionView) ? emojis.count : colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == emojiCollectionView {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: EmojiCell.identifier,
                for: indexPath
            ) as? EmojiCell else {
                return UICollectionViewCell()
            }
            let emoji = emojis[indexPath.item]
            let isSelected = (emoji == selectedEmoji)
            cell.configure(with: emoji, isSelected: isSelected)
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ColorCell.identifier,
                for: indexPath
            ) as? ColorCell else {
                return UICollectionViewCell()
            }
            let colorName = colors[indexPath.item]
            let isSelected = (colorName == selectedColor)
            cell.configure(with: colorName, isSelected: isSelected)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView {
            selectedEmoji = emojis[indexPath.item]
            emojiCollectionView.reloadData()
        } else {
            selectedColor = colors[indexPath.item]
            colorCollectionView.reloadData()
        }
        updateSaveButtonState()
    }
}

// MARK: - CategorySelectionDelegate
extension EditTrackerViewController: CategorySelectionDelegate {
    func categorySelected(_ category: TrackerCategoryCoreData) {
        selectedCategory = category
        settingsTableView.reloadData()
        updateSaveButtonState()
    }
}

// MARK: - ScheduleSelectionDelegate
extension EditTrackerViewController: ScheduleSelectionDelegate {
    func scheduleSelected(_ selectedDays: Set<String>) {
        selectedWeekdays = selectedDays
        isScheduled = !selectedWeekdays.isEmpty
        settingsTableView.reloadData()
        updateSaveButtonState()
    }
}
