//
//  CreateIrregularEventViewController.swift

import UIKit

final class CreateIrregularEventViewController: UIViewController, CategorySelectionDelegate {
    
    // MARK: - UI-компоненты
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Новое нерегулярное событие"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        return label
    }()
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.backgroundColor = .backgroundDay
        textField.layer.cornerRadius = 16
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
    
    // MARK: - Данные
    
    private let emojis = Emojis.list
    private let colors = Colors.list
    
    private var selectedEmoji: String?
    private var selectedColor: String?
    private var selectedCategory: TrackerCategory?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        configureButtons()
    }
    
    // MARK: - Настройка интерфейса
    
    private func setupView() {
        view.backgroundColor = .white
        
        // Set delegates
        emojiCollectionView.delegate = self
        emojiCollectionView.dataSource = self
        colorCollectionView.delegate = self
        colorCollectionView.dataSource = self
        
        view.addSubview(mainStackView)
        
        // Добавляем элементы в стек
        mainStackView.addArrangedSubview(titleLabel)
        mainStackView.addArrangedSubview(nameTextField)
        mainStackView.addArrangedSubview(categoryButton)
        mainStackView.addArrangedSubview(emojiLabel)
        mainStackView.addArrangedSubview(emojiCollectionView)
        mainStackView.addArrangedSubview(colorLabel)
        mainStackView.addArrangedSubview(colorCollectionView)
        buttonsStackView.addArrangedSubview(cancelButton)
        buttonsStackView.addArrangedSubview(createButton)
        mainStackView.addArrangedSubview(buttonsStackView)
    }
    
    private func setupConstraints() {
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            mainStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            categoryButton.heightAnchor.constraint(equalToConstant: 75),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 150),
            colorCollectionView.heightAnchor.constraint(equalToConstant: 150),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        // Дополнительные ограничения для корректного отображения заголовка
        titleLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
    
    private func configureButtons() {
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.systemRed.cgColor
        categoryButton.titleLabel?.numberOfLines = 2
        categoryButton.titleLabel?.textAlignment = .center
        categoryButton.titleLabel?.lineBreakMode = .byWordWrapping
        updateCategoryButtonTitle()
    }
    
    // MARK: - Actions
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func createButtonTapped() {
        // Валидация полей
        guard let name = nameTextField.text, !name.isEmpty,
              let category = selectedCategory,
              let emoji = selectedEmoji,
              let color = selectedColor else {
            let alert = UIAlertController(title: "Ошибка", message: "Заполните все поля", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ОК", style: .default))
            present(alert, animated: true)
            return
        }
        
        // Создание трекера
        let newTracker = Tracker(
            id: UUID(),
            name: name,
            color: color,
            emoji: emoji,
            schedule: nil // Нерегулярное событие
        )
        
        // Отправка уведомления
        NotificationCenter.default.post(name: .didCreateTracker, object: newTracker, userInfo: ["category": category])
        
        // Закрытие всех модальных экранов до `TrackerViewController`
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @objc private func selectCategory() {
        let categorySelectionVC = CategorySelectionViewController()
        categorySelectionVC.delegate = self
        categorySelectionVC.modalPresentationStyle = .pageSheet
        
        if let sheet = categorySelectionVC.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
        }
        present(categorySelectionVC, animated: true, completion: nil)
    }
    
    func categorySelected(_ category: TrackerCategory) {
        selectedCategory = category
        updateCategoryButtonTitle()
    }
    
    private func updateCategoryButtonTitle() {
        if let category = selectedCategory {
            let categoryLabel = "Категория:\n"
            let categoryName = "\(category.title)"
            
            let attributedTitle = NSMutableAttributedString(
                string: categoryLabel,
                attributes: [
                    .foregroundColor: UIColor.black
                ]
            )
            
            let attributedCategory = NSAttributedString(
                string: categoryName,
                attributes: [
                    .foregroundColor: UIColor.gray
                ]
            )
            
            attributedTitle.append(attributedCategory)
            
            categoryButton.setAttributedTitle(attributedTitle, for: .normal)
        } else {
            let attributedTitle = NSAttributedString(
                string: "Выбрать категорию",
                attributes: [
                    .foregroundColor: UIColor.black
                ]
            )
            categoryButton.setAttributedTitle(attributedTitle, for: .normal)
        }
    }
}

// MARK: - UICollectionViewDataSource & Delegate

extension CreateIrregularEventViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView == emojiCollectionView ? emojis.count : colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == emojiCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCell.identifier, for: indexPath) as! EmojiCell
            let emoji = emojis[indexPath.item]
            let isSelected = selectedEmoji == emoji
            cell.configure(with: emoji, isSelected: isSelected)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCell.identifier, for: indexPath) as! ColorCell
            let colorName = colors[indexPath.item]
            let isSelected = selectedColor == colorName
            cell.configure(with: colorName, isSelected: isSelected)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView {
            selectedEmoji = emojis[indexPath.item]
            collectionView.reloadData()
        } else {
            selectedColor = colors[indexPath.item]
            collectionView.reloadData()
        }
    }
}


// MARK: - Ячейки для коллекций

class EmojiCell: UICollectionViewCell {
    static let identifier = "EmojiCell"
    
    private let emojiLabel = UILabel()
    private let selectionView = UIView()
    
    override var isSelected: Bool {
        didSet {
            selectionView.isHidden = !isSelected
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    private func setupViews() {
        emojiLabel.font = UIFont.systemFont(ofSize: 32)
        emojiLabel.textAlignment = .center
        contentView.addSubview(emojiLabel)
        contentView.addSubview(selectionView)
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        
        selectionView.layer.borderWidth = 2
        selectionView.layer.borderColor = UIColor.systemBlue.cgColor
        selectionView.layer.cornerRadius = 8
        selectionView.isHidden = true
        
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        selectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            selectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            selectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            selectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            selectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    func configure(with emoji: String, isSelected: Bool) {
        emojiLabel.text = emoji
        selectionView.isHidden = !isSelected
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ColorCell: UICollectionViewCell {
    static let identifier = "ColorCell"
    
    private let selectionView = UIView()
    
    override var isSelected: Bool {
        didSet {
            selectionView.isHidden = !isSelected
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    private func setupViews() {
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        
        selectionView.layer.borderWidth = 2
        selectionView.layer.borderColor = UIColor.systemBlue.cgColor
        selectionView.layer.cornerRadius = 8
        selectionView.isHidden = true
        
        contentView.addSubview(selectionView)
        selectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            selectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            selectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            selectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            selectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    func configure(with colorName: String, isSelected: Bool) {
        contentView.backgroundColor = UIColor(named: colorName)
        selectionView.isHidden = !isSelected
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
