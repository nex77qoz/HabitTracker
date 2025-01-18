import UIKit

final class ColorCell: UICollectionViewCell {
    static let identifier = "ColorCell"
    
    private let colorSquareView = UIView()
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
        
        selectionView.layer.borderWidth = 3
        selectionView.layer.cornerRadius = 12
        selectionView.layer.borderColor = UIColor.black.cgColor
        selectionView.isHidden = true
        
        colorSquareView.layer.cornerRadius = 8
        colorSquareView.layer.masksToBounds = true
        
        addSubview(selectionView)
        contentView.addSubview(colorSquareView)
        
        selectionView.translatesAutoresizingMaskIntoConstraints = false
        colorSquareView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            selectionView.centerXAnchor.constraint(equalTo: colorSquareView.centerXAnchor),
            selectionView.centerYAnchor.constraint(equalTo: colorSquareView.centerYAnchor),
            selectionView.widthAnchor.constraint(equalToConstant: 52),
            selectionView.heightAnchor.constraint(equalToConstant: 52)
        ])
        
        NSLayoutConstraint.activate([
            colorSquareView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorSquareView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorSquareView.widthAnchor.constraint(equalToConstant: 40),
            colorSquareView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func configure(with colorName: String, isSelected: Bool) {
        if let color = UIColor(named: colorName) {
            colorSquareView.backgroundColor = color
            selectionView.layer.borderColor = color.cgColor
        }
        selectionView.isHidden = !isSelected
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
