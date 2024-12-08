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
        label.text = "Новое регулярное событие"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
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
    private let categoryButton = UIButton.roundedButton(
        title: "Выбрать категорию",
        backgroundColor: .backgroundDay,
        titleColor: .black,
        selector: #selector(selectCategory),
        target: self
    )
    
    private let scheduleButton = UIButton.roundedButton(
        title: "Расписание",
        backgroundColor: .backgroundDay,
        titleColor: .black,
        selector: #selector(scheduleButtonTapped),
        target: self
    )
    
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
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        categoryButton.titleLabel?.numberOfLines = 2
        categoryButton.titleLabel?.textAlignment = .center
        categoryButton.titleLabel?.lineBreakMode = .byWordWrapping
        scheduleButton.titleLabel?.numberOfLines = 2
        scheduleButton.titleLabel?.textAlignment = .center
        scheduleButton.titleLabel?.lineBreakMode = .byWordWrapping
        updateCategoryButtonTitle()
        updateScheduleButtonTitle()
    }
    
    // MARK: - Setup Interface
    
    private func setupView() {
        view.backgroundColor = .white
        
        emojiCollectionView.delegate = self
        emojiCollectionView.dataSource = self
        colorCollectionView.delegate = self
        colorCollectionView.dataSource = self
        
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(mainStackView)
        
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        
        mainStackView.addArrangedSubview(titleLabel)
        mainStackView.addArrangedSubview(nameTextField)
        mainStackView.addArrangedSubview(categoryButton)
        mainStackView.addArrangedSubview(scheduleButton)
        mainStackView.addArrangedSubview(emojiLabel)
        mainStackView.addArrangedSubview(emojiCollectionView)
        mainStackView.addArrangedSubview(colorLabel)
        mainStackView.addArrangedSubview(colorCollectionView)
        buttonsStackView.addArrangedSubview(cancelButton)
        buttonsStackView.addArrangedSubview(createButton)
        mainStackView.addArrangedSubview(buttonsStackView)
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
            
            titleLabel.centerXAnchor.constraint(equalTo: mainStackView.centerXAnchor),
            
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            categoryButton.heightAnchor.constraint(equalToConstant: 75),
            scheduleButton.heightAnchor.constraint(equalToConstant: 75),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 150),
            colorCollectionView.heightAnchor.constraint(equalToConstant: 150),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func scheduleButtonTapped() {
        let scheduleSelectionVC = ScheduleSelectionViewController()
        scheduleSelectionVC.selectedDays = selectedWeekdays
        scheduleSelectionVC.delegate = self
        scheduleSelectionVC.modalPresentationStyle = .pageSheet

        present(scheduleSelectionVC, animated: true, completion: nil)
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
        if selectedWeekdays.isEmpty {
            scheduleButton.setTitle("Расписание", for: .normal)
        } else {
            let sortedDays = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"].filter { selectedWeekdays.contains($0) }
            let daysText = sortedDays.joined(separator: ", ")
            let title = "Расписание:\n\(daysText)"
            scheduleButton.setTitle(title, for: .normal)
        }
    }
    
    private func updateCategoryButtonTitle() {
        if let category = selectedCategory {
            let title = "Категория:\n\(category.title)"
            categoryButton.setTitle(title, for: .normal)
        } else {
            categoryButton.setTitle("Выбрать категорию", for: .normal)
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
            fatalError("Экран сейчас не во View")
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
