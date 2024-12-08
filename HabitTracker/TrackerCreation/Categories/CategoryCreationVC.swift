import UIKit

class CategoryCreationVC: UIViewController {
    private let nameTextFieldMaxLength = 38
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Новая категория"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название категории"
        textField.backgroundColor = .backgroundDay
        textField.layer.cornerRadius = 16
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton.roundedButton(
            title: "Готово",
            backgroundColor: .gray,
            titleColor: .white,
            selector: #selector(addCategoryTapped),
            target: self
        )
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        return button
    }()
    
    weak var delegate: CategoryCreationDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        
        nameTextField.delegate = self
        nameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    private func setupView() {
        view.backgroundColor = .white
        
        view.addSubview(titleLabel)
        view.addSubview(nameTextField)
        view.addSubview(createButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            titleLabel.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.9),
            
            nameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            nameTextField.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            nameTextField.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.9),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            createButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
    
    @objc private func addCategoryTapped() {
        guard let categoryName = nameTextField.text, !categoryName.isEmpty else {
            return
        }
        
        let newCategory = TrackerCategory(title: categoryName, trackers: [])
        
        delegate?.didCreateCategory(newCategory)
        
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func textFieldDidChange() {
        createButton.isEnabled = !(nameTextField.text?.isEmpty ?? true)
        createButton.backgroundColor = createButton.isEnabled ? .black : .gray
    }
}

// MARK: - UITextFieldDelegate
extension CategoryCreationVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        return newLength <= nameTextFieldMaxLength
    }
}

// MARK: - CategoryCreationDelegate Protocol
protocol CategoryCreationDelegate: AnyObject {
    func didCreateCategory(_ category: TrackerCategory)
}
