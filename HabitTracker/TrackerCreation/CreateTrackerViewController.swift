import UIKit

final class CreateTrackerViewController: UIViewController {
    
    // MARK: - UI-компоненты
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Создание трекера"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    private lazy var habitButton = UIButton.roundedButton(
        title: "Привычка",
        backgroundColor: .buttonBackground,
        titleColor: UIColor(named: "ButtonText") ?? .black,
        selector: #selector(habitButtonTapped), target: self
    )
    private lazy var irregularEventButton = UIButton.roundedButton(
        title: "Нерегулярное событие",
        backgroundColor: .buttonBackground,
        titleColor: UIColor(named: "ButtonText") ?? .black,
        selector: #selector(irregularEventButtonTapped), target: self
    )
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
    }
    
    // MARK: - Настройка интерфейса
    
    private func setupView() {
        view.backgroundColor = .background
        view.addSubview(titleLabel)
        view.addSubview(habitButton)
        view.addSubview(irregularEventButton)
    }
    
    private func setupConstraints() {
        [titleLabel, habitButton, irregularEventButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            // Заголовок
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Кнопка "Привычка"
            habitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            habitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            habitButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            habitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            habitButton.heightAnchor.constraint(equalToConstant: 60),
            
            // Кнопка "Нерегулярное событие"
            irregularEventButton.topAnchor.constraint(equalTo: habitButton.bottomAnchor, constant: 16),
            irregularEventButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            irregularEventButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            irregularEventButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            irregularEventButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func habitButtonTapped() {
        let createEventVC = CreateEventViewController(isScheduled: true)
        createEventVC.modalPresentationStyle = .pageSheet
        present(createEventVC, animated: true)
    }

    @objc private func irregularEventButtonTapped() {
        let createEventVC = CreateEventViewController(isScheduled: false)
        createEventVC.modalPresentationStyle = .pageSheet
        present(createEventVC, animated: true)
    }
}
