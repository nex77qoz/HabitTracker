//
//  TrackerCell.swift
import UIKit

protocol TrackerCellDelegate: AnyObject {
    func trackerCell(_ cell: TrackerCell, didToggleCompletionFor tracker: TrackerCoreData, at indexPath: IndexPath)
}


final class TrackerCell: UICollectionViewCell {
    static let identifier = "TrackerCell"
    
    weak var delegate: TrackerCellDelegate?
    private var tracker: TrackerCoreData?
    private var isFutureDate: Bool = false
    var indexPath: IndexPath?
    
    // MARK: - Элементы интерфейса
    
    private let mainView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()
    
    private let circleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.textAlignment = .center
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()
    
    private let daysLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = UIColor(named: "TextColor")
        return label
    }()
    
    private let completeButtonContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        return view
    }()
    
    private let completeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("+", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        button.tintColor = .white
        return button
    }()
    
    // MARK: - Инициализаторы
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        setupSubviews()
        
        completeButton.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
    }
    
    @objc private func completeButtonTapped() {
        guard let indexPath = indexPath, let tracker = tracker else { return }
        delegate?.trackerCell(self, didToggleCompletionFor: tracker, at: indexPath)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Subviews и Constraints
    
    private func setupSubviews() {
        contentView.addSubview(mainView)
        contentView.addSubview(daysLabel)
        contentView.addSubview(completeButtonContainer)
        
        mainView.addSubview(circleView)
        mainView.addSubview(titleLabel)
        
        circleView.addSubview(emojiLabel)
        completeButtonContainer.addSubview(completeButton)
        
        mainView.translatesAutoresizingMaskIntoConstraints = false
        circleView.translatesAutoresizingMaskIntoConstraints = false
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        daysLabel.translatesAutoresizingMaskIntoConstraints = false
        completeButtonContainer.translatesAutoresizingMaskIntoConstraints = false
        completeButton.translatesAutoresizingMaskIntoConstraints = false
        
        let circleSize: CGFloat = 32
        let padding: CGFloat = 12
        
        NSLayoutConstraint.activate([
            mainView.topAnchor.constraint(equalTo: contentView.topAnchor),
            mainView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mainView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            circleView.topAnchor.constraint(equalTo: mainView.topAnchor, constant: padding),
            circleView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: padding),
            circleView.widthAnchor.constraint(equalToConstant: circleSize),
            circleView.heightAnchor.constraint(equalToConstant: circleSize),
            
            emojiLabel.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: circleView.centerYAnchor),
            emojiLabel.widthAnchor.constraint(lessThanOrEqualTo: circleView.widthAnchor, multiplier: 0.8),
            emojiLabel.heightAnchor.constraint(lessThanOrEqualTo: circleView.heightAnchor, multiplier: 0.8),
            
            titleLabel.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: padding),
            titleLabel.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -padding),
            titleLabel.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: -padding),
            
            daysLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            daysLabel.topAnchor.constraint(equalTo: mainView.bottomAnchor, constant: 8),
            
            completeButtonContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            completeButtonContainer.centerYAnchor.constraint(equalTo: daysLabel.centerYAnchor),
            completeButtonContainer.topAnchor.constraint(equalTo: mainView.bottomAnchor, constant: padding),
            completeButtonContainer.widthAnchor.constraint(equalToConstant: 40),
            completeButtonContainer.heightAnchor.constraint(equalToConstant: 40),
            
            completeButton.centerXAnchor.constraint(equalTo: completeButtonContainer.centerXAnchor),
            completeButton.centerYAnchor.constraint(equalTo: completeButtonContainer.centerYAnchor),
            
            contentView.bottomAnchor.constraint(equalTo: completeButtonContainer.bottomAnchor, constant: padding)
        ])
    }
    
    // MARK: - Настройка ячеек
    
    func configure(with tracker: TrackerCoreData, completed: Bool, daysCount: Int, isFutureDate: Bool) {
        self.tracker = tracker
        titleLabel.text = tracker.name
        emojiLabel.text = tracker.emoji
        
        if let colorName = tracker.color {
            mainView.backgroundColor = color(from: colorName)
            completeButtonContainer.backgroundColor = color(from: colorName)
        }
        
        let title = completed ? "✓" : "+"
        completeButton.setTitle(title, for: .normal)
        daysLabel.text = "\(daysCount) дней"
        self.isFutureDate = isFutureDate
        
        if isFutureDate {
            completeButton.isEnabled = false
            if let colorName = tracker.color {
                completeButtonContainer.backgroundColor = color(from: colorName)
            }
            completeButton.alpha = 0.5
        } else {
            completeButton.isEnabled = true
            if let colorName = tracker.color {
                completeButtonContainer.backgroundColor = color(from: colorName)
            }
            completeButton.alpha = 1.0
        }
    }
    
    // MARK: - Цвета
    
    private func color(from colorName: String) -> UIColor {
        return UIColor(named: colorName) ?? UIColor.systemGray5
    }
}
