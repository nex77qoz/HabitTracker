//
//  UI extensions.swift
import UIKit

extension UIButton {
    static func roundedButton(title: String, backgroundColor: UIColor, titleColor: UIColor, selector: Selector, target: Any?) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.backgroundColor = backgroundColor
        button.setTitleColor(titleColor, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.addTarget(target, action: selector, for: .touchUpInside)
        return button
    }
}
