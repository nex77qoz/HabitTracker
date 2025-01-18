import UIKit

final class CreateIrregularEventViewController: UIViewController, CategorySelectionDelegate, UITextFieldDelegate {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Новое нерегулярное событие"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
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
    
    private let categoryTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.isScrollEnabled = false
        tableView.layer.cornerRadius = 16
        tableView.backgroundColor = .backgroundDay
        tableView.separatorStyle = .none
        return tableView
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
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(EmojiCell.self, forCellWithReuseIdentifier: EmojiCell.identifier)
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    private var emojiCollectionViewHeightConstraint: NSLayoutConstraint!
    
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
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(ColorCell.self, forCellWithReuseIdentifier: ColorCell.identifier)
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    private var colorCollectionViewHeightConstraint: NSLayoutConstraint!
    
    private lazy var cancelButton = UIButton.roundedButton(
        title: "Отмена",
        backgroundColor: .backgroundDay,
        titleColor: .systemRed,
        selector: #selector(cancelButtonTapped),
        target: self
    )
    
    private lazy var createButton = UIButton.roundedButton(
        title: "Создать",
        backgroundColor: .gray,
        titleColor: .white,
        selector: #selector(createButtonTapped),
        target: self
    )
    
    private let emojis = Emojis.list
    private let colors = Colors.list
    private var selectedEmoji: String?
    private var selectedColor: String?
    private var selectedCategory: TrackerCategoryCoreData?
    private let nameTextFieldMaxLength = 38
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        emojiCollectionView.delegate = self
        emojiCollectionView.dataSource = self
        colorCollectionView.delegate = self
        colorCollectionView.dataSource = self
        categoryTableView.delegate = self
        categoryTableView.dataSource = self
        categoryTableView.register(UITableViewCell.self, forCellReuseIdentifier: "CategoryCell")
        
        view.addSubview(titleLabel)
        view.addSubview(nameTextField)
        view.addSubview(categoryTableView)
        view.addSubview(emojiLabel)
        view.addSubview(emojiCollectionView)
        view.addSubview(colorLabel)
        view.addSubview(colorCollectionView)
        view.addSubview(cancelButton)
        view.addSubview(createButton)
        
        setupConstraints()
        
        nameTextField.delegate = self
        nameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        updateCreateButtonState()
        reloadCollectionViewHeight()
        emojiCollectionView.reloadData()
        colorCollectionView.reloadData()
        
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.systemRed.cgColor
    }
    
    // MARK: - CategorySelectionDelegate
    func categorySelected(_ category: TrackerCategoryCoreData) {
        selectedCategory = category
        categoryTableView.reloadData()
        updateCreateButtonState()
    }
    
    // MARK: - Actions / Helpers
    
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
              let color = selectedColor else {
            let alert = UIAlertController(title: "Ошибка", message: "Заполните все поля", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ОК", style: .default))
            present(alert, animated: true)
            return
        }
        
        let newTracker = Tracker(id: UUID(), name: name, color: color, emoji: emoji, schedule: nil)
        NotificationCenter.default.post(name: .didCreateTracker, object: newTracker, userInfo: ["category": category])
        
        presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    /// Updated to use the ViewModel initializer
    @objc private func selectCategory() {
        let store = TrackerCategoryStore()
        let viewModel = CategorySelectionViewModel(categoryStore: store)
        let categorySelectionVC = CategorySelectionViewController(viewModel: viewModel)
        categorySelectionVC.delegate = self
        categorySelectionVC.modalPresentationStyle = UIModalPresentationStyle.pageSheet
        present(categorySelectionVC, animated: true, completion: nil)
    }
    
    private func updateCreateButtonState() {
        let isFormValid = !(nameTextField.text?.trimmingCharacters(in: .whitespaces).isEmpty ?? true)
        && selectedCategory != nil
        && selectedEmoji != nil
        && selectedColor != nil
        
        if isFormValid {
            createButton.backgroundColor = .black
            createButton.isEnabled = true
        } else {
            createButton.backgroundColor = .gray
            createButton.isEnabled = false
        }
    }
    
    // MARK: - Layout
    
    private func setupConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        categoryTableView.translatesAutoresizingMaskIntoConstraints = false
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        emojiCollectionView.translatesAutoresizingMaskIntoConstraints = false
        colorLabel.translatesAutoresizingMaskIntoConstraints = false
        colorCollectionView.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        createButton.translatesAutoresizingMaskIntoConstraints = false
        
        emojiCollectionViewHeightConstraint = emojiCollectionView.heightAnchor.constraint(equalToConstant: 150)
        emojiCollectionViewHeightConstraint.isActive = true
        colorCollectionViewHeightConstraint = colorCollectionView.heightAnchor.constraint(equalToConstant: 150)
        colorCollectionViewHeightConstraint.isActive = true
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            nameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            categoryTableView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 16),
            categoryTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categoryTableView.heightAnchor.constraint(equalToConstant: 75),
            
            emojiLabel.topAnchor.constraint(equalTo: categoryTableView.bottomAnchor, constant: 16),
            emojiLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            
            emojiCollectionView.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 8),
            emojiCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            emojiCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            colorLabel.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 16),
            colorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            
            colorCollectionView.topAnchor.constraint(equalTo: colorLabel.bottomAnchor, constant: 8),
            colorCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            colorCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            cancelButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.45),
            
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            createButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.45)
        ])
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

// MARK: - UITableViewDataSource, UITableViewDelegate
extension CreateIrregularEventViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.textAlignment = .left
        
        if let category = selectedCategory {
            let attributedText = NSMutableAttributedString(string: "Категория:\n", attributes: [.foregroundColor: UIColor.black])
            let categoryNameAttributed = NSAttributedString(string: category.title ?? "", attributes: [.foregroundColor: UIColor.gray])
            attributedText.append(categoryNameAttributed)
            cell.textLabel?.attributedText = attributedText
        } else {
            cell.textLabel?.text = "Выбрать категорию"
            cell.textLabel?.textColor = .black
        }
        
        cell.selectionStyle = .none
        cell.backgroundColor = .backgroundDay
        cell.layer.cornerRadius = 16
        cell.layer.masksToBounds = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectCategory()
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension CreateIrregularEventViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionView == emojiCollectionView ? emojis.count : colors.count
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
        updateCreateButtonState()
    }
}
