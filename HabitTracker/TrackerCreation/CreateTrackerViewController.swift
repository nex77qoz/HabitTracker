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
        backgroundColor: .black,
        titleColor: .white,
        selector: #selector(habitButtonTapped), target: self
    )
    private lazy var irregularEventButton = UIButton.roundedButton(
        title: "Нерегулярное событие",
        backgroundColor: .black,
        titleColor: .white,
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
        view.backgroundColor = .white
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
        let createScheduledEventVC = CreateScheduledEventViewController()
        createScheduledEventVC.modalPresentationStyle = .pageSheet
        
        present(createScheduledEventVC, animated: true, completion: nil)
    }
    
    @objc private func irregularEventButtonTapped() {
        let createIrregularEventVC = CreateIrregularEventViewController()
        createIrregularEventVC.modalPresentationStyle = .pageSheet
        
        present(createIrregularEventVC, animated: true, completion: nil)
    }
}
