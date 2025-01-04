import UIKit

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
        contentView.addSubview(selectionView)
        contentView.addSubview(emojiLabel)
        
        selectionView.backgroundColor = UIColor.lightGray
        selectionView.layer.cornerRadius = 16
        selectionView.isHidden = true
        
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        selectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            selectionView.widthAnchor.constraint(equalToConstant: 45),
            selectionView.heightAnchor.constraint(equalToConstant: 45),
            selectionView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            selectionView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
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
