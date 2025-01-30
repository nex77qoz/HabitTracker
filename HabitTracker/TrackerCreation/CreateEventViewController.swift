import UIKit

protocol ScheduleSelectionDelegate: AnyObject {
    func scheduleSelected(_ selectedDays: Set<String>)
}

final class CreateEventViewController: UIViewController {
    
    // MARK: - Public
    
    private let isScheduled: Bool
    
    // MARK: - UI: ScrollView & ContentView
    
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
    
    // MARK: - Constants / Data
    
    private let nameTextFieldMaxLength = 38
    private let weekdays = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
    
    private var settingsOptions: [String] {
        isScheduled ? ["Выбрать категорию", "Расписание"] : ["Выбрать категорию"]
    }
    
    // MARK: - Model
    
    private var selectedCategory: TrackerCategoryCoreData?
    private var selectedWeekdays = Set<String>()
    private var selectedEmoji: String?
    private var selectedColor: String?
    
    // MARK: - UI: Title
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - UI: Name TextField
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .grayBackground
        textField.layer.cornerRadius = 16
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftViewMode = .always
        let placeholderText = "Введите название трекера"
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(named: "TextColor") ?? .darkText
        ]
        textField.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: attributes)
        return textField
    }()
    
    // MARK: - UI: TableView (Category + Schedule)
    
    private let settingsTableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "SettingsCell")
        table.layer.cornerRadius = 16
        table.layer.masksToBounds = true
        table.separatorStyle = .none
        table.isScrollEnabled = false
        return table
    }()
    
    // MARK: - UI: Emoji
    
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
        collection.backgroundColor = .background
        return collection
    }()
    
    private var emojiCollectionViewHeightConstraint: NSLayoutConstraint!
    
    // MARK: - UI: Color
    
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
        collection.backgroundColor = .background
        return collection
    }()
    
    private var colorCollectionViewHeightConstraint: NSLayoutConstraint!
    
    // MARK: - UI: Buttons
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton.roundedButton(
            title: "Отмена",
            backgroundColor: .background,
            titleColor: .systemRed,
            selector: #selector(cancelButtonTapped),
            target: self
        )
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemRed.cgColor
        return button
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton.roundedButton(
            title: "Создать",
            backgroundColor: .gray,
            titleColor: .white,
            selector: #selector(createButtonTapped),
            target: self
        )
        return button
    }()
    
    // MARK: - Collections Data
    
    private let emojis = Emojis.list
    private let colors = Colors.list
    
    // MARK: - Init
    
    init(isScheduled: Bool) {
        self.isScheduled = isScheduled
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(nameTextField)
        contentView.addSubview(settingsTableView)
        contentView.addSubview(emojiLabel)
        contentView.addSubview(emojiCollectionView)
        contentView.addSubview(colorLabel)
        contentView.addSubview(colorCollectionView)
        
        view.addSubview(cancelButton)
        view.addSubview(createButton)
        
        reloadCollectionViewHeight()
        
        nameTextField.delegate = self
        nameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        settingsTableView.delegate = self
        settingsTableView.dataSource = self
        
        emojiCollectionView.delegate = self
        emojiCollectionView.dataSource = self
        
        colorCollectionView.delegate = self
        colorCollectionView.dataSource = self
        
        titleLabel.text = isScheduled ? "Новая привычка" : "Новое нерегулярное событие"
        
        setupConstraints()
        updateCreateButtonState()
    }
    
    private func setupConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        [titleLabel,
         nameTextField,
         settingsTableView,
         emojiLabel,
         emojiCollectionView,
         colorLabel,
         colorCollectionView,
         cancelButton,
         createButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        emojiCollectionViewHeightConstraint = emojiCollectionView.heightAnchor.constraint(equalToConstant: 156)
        emojiCollectionViewHeightConstraint.isActive = true
        
        colorCollectionViewHeightConstraint = colorCollectionView.heightAnchor.constraint(equalToConstant: 156)
        colorCollectionViewHeightConstraint.isActive = true
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -16),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            nameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            nameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            settingsTableView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 16),
            settingsTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            settingsTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            settingsTableView.heightAnchor.constraint(equalToConstant: isScheduled ? 150 : 75),
            
            emojiLabel.topAnchor.constraint(equalTo: settingsTableView.bottomAnchor, constant: 16),
            emojiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            
            emojiCollectionView.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 8),
            emojiCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            emojiCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            colorLabel.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 16),
            colorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            
            colorCollectionView.topAnchor.constraint(equalTo: colorLabel.bottomAnchor, constant: 8),
            colorCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            colorCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            colorCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            createButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            createButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.45),
            
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            cancelButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.45)
        ])
    }
    
    private func reloadCollectionViewHeight() {
        DispatchQueue.main.async {
            self.emojiCollectionView.layoutIfNeeded()
            self.emojiCollectionViewHeightConstraint.constant = self.emojiCollectionView.contentSize.height
            self.colorCollectionView.layoutIfNeeded()
            self.colorCollectionViewHeightConstraint.constant = self.colorCollectionView.contentSize.height
        }
    }
    
    // MARK: - Actions & Logic
    
    @objc private func textFieldDidChange() {
        updateCreateButtonState()
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func createButtonTapped() {
        guard
            let name = nameTextField.text,
            !name.trimmingCharacters(in: .whitespaces).isEmpty,
            let category = selectedCategory,
            let emoji = selectedEmoji,
            let color = selectedColor
        else {
            showErrorAlert("Ошибка", "Заполните все поля")
            return
        }
        
        if isScheduled && selectedWeekdays.isEmpty {
            showErrorAlert("Ошибка", "Заполните все поля (нет расписания)")
            return
        }
        
        let schedule: Schedule? = isScheduled
        ? {
            let daysOfWeek = weekdays.map { selectedWeekdays.contains($0) }
            return Schedule(daysOfWeek: daysOfWeek)
        }()
        : nil
        
        let newTracker = Tracker(
            id: UUID(),
            name: name,
            color: color,
            emoji: emoji,
            schedule: schedule
        )
        
        NotificationCenter.default.post(
            name: .didCreateTracker,
            object: newTracker,
            userInfo: ["category": category]
        )
        
        if let tabBarController = presentingViewController as? UITabBarController {
            tabBarController.selectedIndex = 0
            dismiss(animated: true, completion: nil)
        } else {
            if let window = UIApplication.shared.windows.first {
                let tabBarController = TabBarViewController()
                window.rootViewController = tabBarController
                window.makeKeyAndVisible()
            }
        }
    }
    
    private func showErrorAlert(_ title: String, _ msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default))
        present(alert, animated: true)
    }
    
    private func updateCreateButtonState() {
        let hasName = !(nameTextField.text?.trimmingCharacters(in: .whitespaces).isEmpty ?? true)
        let hasCategory = selectedCategory != nil
        let hasEmoji = selectedEmoji != nil
        let hasColor = selectedColor != nil
        
        if isScheduled {
            let hasScheduleDays = !selectedWeekdays.isEmpty
            createButton.isEnabled = hasName && hasCategory && hasEmoji && hasColor && hasScheduleDays
        } else {
            createButton.isEnabled = hasName && hasCategory && hasEmoji && hasColor
        }
        
        createButton.backgroundColor = createButton.isEnabled ? .background : .gray
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension CreateEventViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int { 1 }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        settingsOptions.count
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
        cell.backgroundColor = .grayBackground
        
        let option = settingsOptions[indexPath.row]
        
        switch option {
        case "Выбрать категорию":
            if let category = selectedCategory {
                let a = NSMutableAttributedString(
                    string: "Категория:",
                    attributes: [.foregroundColor: UIColor(named: "TextColor") ?? .darkText]
                )
                a.append(
                    NSAttributedString(
                        string: "\n\(category.title ?? "")",
                        attributes: [.foregroundColor: UIColor.lightGray]
                    )
                )
                cell.textLabel?.attributedText = a
            } else {
                cell.textLabel?.attributedText = NSAttributedString(
                    string: "Выбрать категорию",
                    attributes: [.foregroundColor: UIColor(named: "TextColor") ?? .darkText]
                )
            }
            
        case "Расписание":
            if selectedWeekdays.isEmpty {
                cell.textLabel?.attributedText = NSAttributedString(
                    string: "Расписание",
                    attributes: [.foregroundColor: UIColor(named: "TextColor") ?? .darkText]
                )
            } else {
                let sortedDays = weekdays.filter { selectedWeekdays.contains($0) }
                let joined = sortedDays.joined(separator: ", ")
                
                let a = NSMutableAttributedString(
                    string: "Расписание:",
                    attributes: [.foregroundColor: UIColor(named: "TextColor") ?? .darkText]
                )
                a.append(
                    NSAttributedString(
                        string: "\n\(joined)",
                        attributes: [.foregroundColor: UIColor.lightGray]
                    )
                )
                cell.textLabel?.attributedText = a
            }
            
        default:
            cell.textLabel?.text = option
        }
        
        cell.textLabel?.numberOfLines = 0
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        let option = settingsOptions[indexPath.row]
        switch option {
        case "Выбрать категорию":
            selectCategory()
        case "Расписание":
            selectSchedule()
        default:
            break
        }
    }
    
    private func selectCategory() {
        let store = TrackerCategoryStore()
        let vm = CategorySelectionViewModel(categoryStore: store)
        let categorySelectionVC = CategorySelectionViewController(viewModel: vm)
        categorySelectionVC.delegate = self
        categorySelectionVC.modalPresentationStyle = .pageSheet
        present(categorySelectionVC, animated: true)
    }
    
    private func selectSchedule() {
        let scheduleVC = ScheduleSelectionViewController()
        scheduleVC.selectedDays = selectedWeekdays
        scheduleVC.delegate = self
        scheduleVC.modalPresentationStyle = .pageSheet
        present(scheduleVC, animated: true)
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension CreateEventViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        collectionView == emojiCollectionView ? emojis.count : colors.count
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
            cell.configure(with: emoji, isSelected: emoji == selectedEmoji)
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ColorCell.identifier,
                for: indexPath
            ) as? ColorCell else {
                return UICollectionViewCell()
            }
            let colorName = colors[indexPath.item]
            cell.configure(with: colorName, isSelected: colorName == selectedColor)
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
        updateCreateButtonState()
    }
}

// MARK: - CategorySelectionDelegate
extension CreateEventViewController: CategorySelectionDelegate {
    func categorySelected(_ category: TrackerCategoryCoreData) {
        selectedCategory = category
        settingsTableView.reloadData()
        updateCreateButtonState()
    }
}

// MARK: - ScheduleSelectionDelegate
extension CreateEventViewController: ScheduleSelectionDelegate {
    func scheduleSelected(_ selectedDays: Set<String>) {
        selectedWeekdays = selectedDays
        settingsTableView.reloadData()
        updateCreateButtonState()
    }
}

// MARK: - UITextFieldDelegate
extension CreateEventViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        
        guard textField == nameTextField else { return true }
        
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else {
            return false
        }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        if updatedText.count > nameTextFieldMaxLength {
            showErrorAlert(
                "Превышен лимит символов",
                "Название трекера не может превышать \(nameTextFieldMaxLength) символов."
            )
            return false
        }
        return true
    }
}
