import UIKit

final class GradientBorderCardView: UIView {
    
    private let gradientLayer = CAGradientLayer()
    private let maskLayer = CAShapeLayer()
    
    private let gradientColors: [CGColor] = [
        UIColor(hex: "#FD4C49").cgColor,
        UIColor(hex: "#46E69D").cgColor,
        UIColor(hex: "#007BFA").cgColor
    ]
    
    private let borderWidth: CGFloat = 2
    private let cornerRadius: CGFloat = 16
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradientBorder()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradientBorder()
    }
    
    private func setupGradientBorder() {
        backgroundColor = .background
        
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = true
        
        gradientLayer.colors = gradientColors
        gradientLayer.startPoint = CGPoint(x: 0,   y: 0.5)
        gradientLayer.endPoint   = CGPoint(x: 1.0, y: 0.5)
        
        layer.addSublayer(gradientLayer)
        
        maskLayer.lineWidth = borderWidth
        maskLayer.fillColor = UIColor.clear.cgColor
        maskLayer.strokeColor = UIColor.black.cgColor
        
        gradientLayer.mask = maskLayer
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientLayer.frame = bounds
        
        let path = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: cornerRadius
        )
        maskLayer.path = path.cgPath
    }
}

private extension UIColor {
    convenience init(hex: String) {
        var hexClean = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if hexClean.hasPrefix("#") {
            hexClean.removeFirst()
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexClean).scanHexInt64(&rgbValue)
        
        let r = CGFloat((rgbValue & 0xFF0000) >> 16) / 255
        let g = CGFloat((rgbValue & 0x00FF00) >> 8)  / 255
        let b = CGFloat(rgbValue & 0x0000FF)        / 255
        self.init(red: r, green: g, blue: b, alpha: 1)
    }
}
