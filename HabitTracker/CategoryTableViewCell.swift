import UIKit

class CategoryTableViewCell: UITableViewCell {
    static let identifier = "CategoryTableViewCell"
    private let container = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        container.backgroundColor = .backgroundDay
        container.layer.cornerRadius = 10
        container.layer.masksToBounds = true
        container.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(container)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])

        textLabel?.translatesAutoresizingMaskIntoConstraints = false
        contentView.bringSubviewToFront(textLabel!)

        NSLayoutConstraint.activate([
            textLabel!.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            textLabel!.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            textLabel!.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with category: TrackerCategory, isSelected: Bool) {
        textLabel?.text = category.title
        textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        accessoryType = isSelected ? .checkmark : .none
    }
}
