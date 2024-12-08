import UIKit

protocol ScheduleSelectionDelegate: AnyObject {
    func scheduleSelected(_ selectedDays: Set<String>)
}

final class CreateScheduledEventViewController: UIViewController, CategorySelectionDelegate, ScheduleSelectionDelegate, UITextFieldDelegate {
    
    // MARK: - UI
    private let nameTextFieldMaxLength = 38
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Новая привычка"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.backgroundColor = .backgroundDay
        textField.layer.cornerRadius = 16
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.text = "Emoji"
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emojiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: 52, height: 52)
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(EmojiCell.self, forCellWithReuseIdentifier: EmojiCell.identifier)
        collectionView.backgroundColor = .white
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    private var emojiCollectionViewHeightConstraint: NSLayoutConstraint!
    
    private let colorLabel: UILabel = {
        let label = UILabel()
        label.text = "Цвет"
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let colorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: 52, height: 52)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(ColorCell.self, forCellWithReuseIdentifier: ColorCell.identifier)
        collectionView.backgroundColor = .white
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    private var colorCollectionViewHeightConstraint: NSLayoutConstraint!
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentScrollView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "SettingsCell")
        table.isScrollEnabled = false
        table.tableHeaderView = UIView(frame: .zero)
        table.tableFooterView = UIView(frame: .zero)
        table.contentInset = .zero
        table.layoutMargins = .zero
        table.layer.cornerRadius = 16
        table.layer.masksToBounds = true
        table.translatesAutoresizingMaskIntoConstraints = false
        table.separatorStyle = .none
        return table
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton.roundedButton(
            title: "Отмена",
            backgroundColor: .backgroundDay,
            titleColor: .systemRed,
            selector: #selector(cancelButtonTapped),
            target: self
        )
        button.translatesAutoresizingMaskIntoConstraints = false
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
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Data
    
    private let emojis = Emojis.list
    private let colors = Colors.list
    private let weekdays = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
    
    private var selectedEmoji: String?
    private var selectedColor: String?
    private var selectedCategory: TrackerCategory?
    private var selectedWeekdays = Set<String>()
    
    private let settingsOptions = ["Выбрать категорию", "Расписание"]
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        
        emojiCollectionView.delegate = self
        emojiCollectionView.dataSource = self
        colorCollectionView.delegate = self
        colorCollectionView.dataSource = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        updateCategoryButtonTitle()
        updateScheduleButtonTitle()
        
        nameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        updateCreateButtonState()
        
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.systemRed.cgColor
        
        reloadCollectionViewHeight()
        emojiCollectionView.reloadData()
        colorCollectionView.reloadData()
    }
    
    // MARK: - Setup Interface
    
    private func setupView() {
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentScrollView)
        
        contentScrollView.addSubview(titleLabel)
        contentScrollView.addSubview(nameTextField)
        contentScrollView.addSubview(tableView)
        contentScrollView.addSubview(emojiLabel)
        contentScrollView.addSubview(emojiCollectionView)
        contentScrollView.addSubview(colorLabel)
        contentScrollView.addSubview(colorCollectionView)
        contentScrollView.addSubview(cancelButton)
        contentScrollView.addSubview(createButton)
    }
    
    private func setupConstraints() {
        emojiCollectionView.translatesAutoresizingMaskIntoConstraints = false
        colorCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        emojiCollectionViewHeightConstraint = emojiCollectionView.heightAnchor.constraint(equalToConstant: 150)
        emojiCollectionViewHeightConstraint.isActive = true
        
        colorCollectionViewHeightConstraint = colorCollectionView.heightAnchor.constraint(equalToConstant: 150)
        colorCollectionViewHeightConstraint.isActive = true
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentScrollView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentScrollView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentScrollView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentScrollView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentScrollView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: contentScrollView.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: contentScrollView.centerXAnchor),
            titleLabel.widthAnchor.constraint(equalTo: contentScrollView.widthAnchor, multiplier: 0.9),
            
            nameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            nameTextField.centerXAnchor.constraint(equalTo: contentScrollView.centerXAnchor),
            nameTextField.widthAnchor.constraint(equalTo: contentScrollView.widthAnchor, multiplier: 0.9),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            tableView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 16),
            tableView.centerXAnchor.constraint(equalTo: contentScrollView.centerXAnchor),
            tableView.widthAnchor.constraint(equalTo: contentScrollView.widthAnchor, multiplier: 0.9),
            tableView.heightAnchor.constraint(equalToConstant: 150),
            
            emojiLabel.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 16),
            emojiLabel.centerXAnchor.constraint(equalTo: contentScrollView.centerXAnchor),
            emojiLabel.widthAnchor.constraint(equalTo: contentScrollView.widthAnchor, multiplier: 0.9),
            
            emojiCollectionView.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 8),
            emojiCollectionView.centerXAnchor.constraint(equalTo: contentScrollView.centerXAnchor),
            emojiCollectionView.widthAnchor.constraint(equalTo: contentScrollView.widthAnchor, multiplier: 0.9),
            
            colorLabel.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 16),
            colorLabel.centerXAnchor.constraint(equalTo: contentScrollView.centerXAnchor),
            colorLabel.widthAnchor.constraint(equalTo: contentScrollView.widthAnchor, multiplier: 0.9),
            
            colorCollectionView.topAnchor.constraint(equalTo: colorLabel.bottomAnchor, constant: 8),
            colorCollectionView.centerXAnchor.constraint(equalTo: contentScrollView.centerXAnchor),
            colorCollectionView.widthAnchor.constraint(equalTo: contentScrollView.widthAnchor, multiplier: 0.9),
            colorCollectionView.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -16),
            
            cancelButton.bottomAnchor.constraint(equalTo: contentScrollView.bottomAnchor, constant: -16),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            cancelButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.45),
            
            createButton.bottomAnchor.constraint(equalTo: contentScrollView.bottomAnchor, constant: -16),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            createButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.45)
        ])
    }
    
    private func setupTextFieldDelegate() {
        nameTextField.delegate = self
    }
    
    private func updateCreateButtonState() {
        let isFormValid =
        !(nameTextField.text?.trimmingCharacters(in: .whitespaces).isEmpty ?? true) &&
        selectedCategory != nil &&
        selectedEmoji != nil &&
        selectedColor != nil
        
        if isFormValid {
            createButton.backgroundColor = .black
            createButton.isEnabled = true
        } else {
            createButton.backgroundColor = .gray
            createButton.isEnabled = false
        }
    }
    
    // MARK: - Actions
    
    @objc private func textFieldDidChange() {
        updateCreateButtonState()
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func createButtonTapped() {
        guard let name = nameTextField.text, !name.isEmpty,
              let category = selectedCategory,
              let emoji = selectedEmoji,
              let color = selectedColor,
              !selectedWeekdays.isEmpty else {
            let alert = UIAlertController(title: "Ошибка", message: "Заполните все поля", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ОК", style: .default))
            present(alert, animated: true)
            return
        }
        
        let daysOfWeek: [Bool] = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"].map { selectedWeekdays.contains($0) }
        let schedule = Schedule(daysOfWeek: daysOfWeek)
        
        let newTracker = Tracker(
            id: UUID(),
            name: name,
            color: color,
            emoji: emoji,
            schedule: schedule
        )
        
        NotificationCenter.default.post(name: .didCreateTracker, object: newTracker, userInfo: ["category": category])
        
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @objc private func selectCategory() {
        let categorySelectionVC = CategorySelectionViewController()
        categorySelectionVC.delegate = self
        categorySelectionVC.modalPresentationStyle = .pageSheet
        present(categorySelectionVC, animated: true, completion: nil)
    }
    
    func categorySelected(_ category: TrackerCategory) {
        selectedCategory = category
        updateCategoryButtonTitle()
        updateCreateButtonState()
    }
    
    func scheduleSelected(_ selectedDays: Set<String>) {
        selectedWeekdays = selectedDays
        updateScheduleButtonTitle()
        updateCreateButtonState()
    }
    
    private func updateScheduleButtonTitle() {
        tableView.reloadData()
    }
    
    private func updateCategoryButtonTitle() {
        tableView.reloadData()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard textField == nameTextField else {
            return true
        }
        
        let currentText = textField.text ?? ""
        
        guard let stringRange = Range(range, in: currentText) else {
            return false
        }
        
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        if updatedText.count > nameTextFieldMaxLength {
            showMaxLengthAlert()
            return false
        }
        
        return true
    }
    
    private func showMaxLengthAlert() {
        if self.presentedViewController is UIAlertController {
            return
        }
        
        let alert = UIAlertController(title: "Превышен лимит символов", message: "Название трекера не может превышать \(nameTextFieldMaxLength) символов.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource & Delegate

extension CreateScheduledEventViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsOptions.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)
        
        cell.selectionStyle = .none
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = .backgroundDay
        
        let option = settingsOptions[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
        
        if indexPath.row == 0 {
            let separator = UIView()
            separator.backgroundColor = .lightGray
            separator.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(separator)
            
            NSLayoutConstraint.activate([
                separator.heightAnchor.constraint(equalToConstant: 1),
                separator.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
                separator.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: 0),
                separator.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor)
            ])
        }
        
        switch option {
            case "Выбрать категорию":
                if let category = selectedCategory {
                    let attributedText = NSMutableAttributedString(
                        string: "Категория:",
                        attributes: [.foregroundColor: UIColor.black]
                    )
                    attributedText.append(NSAttributedString(
                        string: "\n\(category.title)",
                        attributes: [.foregroundColor: UIColor.lightGray]
                    ))
                    cell.textLabel?.attributedText = attributedText
                } else {
                    cell.textLabel?.attributedText = NSAttributedString(
                        string: "Выбрать категорию",
                        attributes: [.foregroundColor: UIColor.black]
                    )
                }
            case "Расписание":
                if selectedWeekdays.isEmpty {
                    cell.textLabel?.attributedText = NSAttributedString(
                        string: "Расписание",
                        attributes: [.foregroundColor: UIColor.black]
                    )
                } else {
                    let sortedDays = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"].filter { selectedWeekdays.contains($0) }
                    let daysText = sortedDays.joined(separator: ", ")
                    
                    let attributedText = NSMutableAttributedString(
                        string: "Расписание:",
                        attributes: [.foregroundColor: UIColor.black]
                    )
                    attributedText.append(NSAttributedString(
                        string: "\n\(daysText)",
                        attributes: [.foregroundColor: UIColor.lightGray]
                    ))
                    cell.textLabel?.attributedText = attributedText
                }
            default:
                cell.textLabel?.attributedText = NSAttributedString(
                    string: option,
                    attributes: [.foregroundColor: UIColor.black]
                )
        }
        
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.textAlignment = .left
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let option = settingsOptions[indexPath.row]
        switch option {
            case "Выбрать категорию":
                selectCategory()
            case "Расписание":
                let scheduleSelectionVC = ScheduleSelectionViewController()
                scheduleSelectionVC.selectedDays = selectedWeekdays
                scheduleSelectionVC.delegate = self
                scheduleSelectionVC.modalPresentationStyle = .pageSheet
                
                present(scheduleSelectionVC, animated: true, completion: nil)
            default:
                break
        }
    }
}

// MARK: - UICollectionViewDataSource & Delegate

extension CreateScheduledEventViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == emojiCollectionView {
            return emojis.count
        } else if collectionView == colorCollectionView {
            return colors.count
        } else {
            return weekdays.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == emojiCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCell.identifier, for: indexPath) as! EmojiCell
            let emoji = emojis[indexPath.item]
            let isSelected = selectedEmoji == emoji
            cell.configure(with: emoji, isSelected: isSelected)
            return cell
        } else if collectionView == colorCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCell.identifier, for: indexPath) as! ColorCell
            let colorName = colors[indexPath.item]
            let isSelected = selectedColor == colorName
            cell.configure(with: colorName, isSelected: isSelected)
            return cell
        } else {
            fatalError("Unexpected collection view")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView {
            selectedEmoji = emojis[indexPath.item]
            collectionView.reloadData()
        } else if collectionView == colorCollectionView {
            selectedColor = colors[indexPath.item]
            collectionView.reloadData()
        }
        updateCreateButtonState()
    }
    func reloadCollectionViewHeight() {
        DispatchQueue.main.async {
            self.emojiCollectionView.layoutIfNeeded()
            self.emojiCollectionViewHeightConstraint.constant = self.emojiCollectionView.contentSize.height
            self.colorCollectionView.layoutIfNeeded()
            self.colorCollectionViewHeightConstraint.constant = self.colorCollectionView.contentSize.height
        }
    }
}
