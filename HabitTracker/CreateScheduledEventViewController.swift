//
//  CreateScheduledEventViewController.swift
import UIKit

protocol ScheduleSelectionDelegate: AnyObject {
    func scheduleSelected(_ selectedDays: Set<String>)
}

final class CreateScheduledEventViewController: UIViewController, CategorySelectionDelegate, ScheduleSelectionDelegate {
    
    // MARK: - UI
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Новая привычка"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.backgroundColor = .backgroundDay
        textField.layer.cornerRadius = 20
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftViewMode = .always
        return textField
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
        layout.itemSize = CGSize(width: 40, height: 40)
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(EmojiCell.self, forCellWithReuseIdentifier: EmojiCell.identifier)
        collectionView.backgroundColor = .white
        return collectionView
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
        layout.itemSize = CGSize(width: 40, height: 40)
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(ColorCell.self, forCellWithReuseIdentifier: ColorCell.identifier)
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = true
        return scrollView
    }()
    
    // MARK: - Updated UITableView
    
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
        return table
    }()
    
    // MARK: - Data
    
    private let emojis = Emojis.list
    private let colors = Colors.list
    private let weekdays = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
    
    private var selectedEmoji: String?
    private var selectedColor: String?
    private var selectedCategory: TrackerCategory?
    private var selectedWeekdays = Set<String>()
    
    private let cancelButton = UIButton.roundedButton(
        title: "Отмена",
        backgroundColor: .backgroundDay,
        titleColor: .systemRed,
        selector: #selector(cancelButtonTapped),
        target: self
    )
    private let createButton = UIButton.roundedButton(
        title: "Создать",
        backgroundColor: .blackDay,
        titleColor: .white,
        selector: #selector(createButtonTapped),
        target: self
    )
    
    private let mainStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill
        stack.distribution = .equalSpacing
        return stack
    }()
    
    private let buttonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        return stackView
    }()
    
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
    }
    
    // MARK: - Setup Interface
    
    private func setupView() {
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(mainStackView)
        
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        
        mainStackView.addArrangedSubview(titleLabel)
        mainStackView.addArrangedSubview(nameTextField)
        mainStackView.addArrangedSubview(tableView)
        mainStackView.addArrangedSubview(emojiLabel)
        mainStackView.addArrangedSubview(emojiCollectionView)
        mainStackView.addArrangedSubview(colorLabel)
        mainStackView.addArrangedSubview(colorCollectionView)
        buttonsStackView.addArrangedSubview(cancelButton)
        buttonsStackView.addArrangedSubview(createButton)
        mainStackView.addArrangedSubview(buttonsStackView)
        
        tableView.separatorStyle = .none
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            mainStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            mainStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
            mainStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -16),
            mainStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -16),
            mainStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32),
            
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            tableView.heightAnchor.constraint(equalToConstant: 150),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 150),
            colorCollectionView.heightAnchor.constraint(equalToConstant: 150),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    // MARK: - Actions
    
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
    }
    
    func scheduleSelected(_ selectedDays: Set<String>) {
        selectedWeekdays = selectedDays
        updateScheduleButtonTitle()
    }
    
    private func updateScheduleButtonTitle() {
        tableView.reloadData()
    }

    private func updateCategoryButtonTitle() {
        tableView.reloadData()
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
        cell.textLabel?.textColor = .black
        
        if indexPath.row == 0 {
            let separator = UIView()
            separator.backgroundColor = .lightGray
            separator.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(separator)

            NSLayoutConstraint.activate([
                separator.heightAnchor.constraint(equalToConstant: 1),
                separator.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
                separator.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
                separator.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor)
            ])
        }
        
        switch option {
        case "Выбрать категорию":
            if let category = selectedCategory {
                cell.textLabel?.text = "Категория:\n\(category.title)"
            } else {
                cell.textLabel?.text = "Выбрать категорию"
            }
        case "Расписание":
            if selectedWeekdays.isEmpty {
                cell.textLabel?.text = "Расписание"
            } else {
                let sortedDays = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"].filter { selectedWeekdays.contains($0) }
                let daysText = sortedDays.joined(separator: ", ")
                cell.textLabel?.text = "Расписание:\n\(daysText)"
            }
        default:
            cell.textLabel?.text = option
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
    }
}
