//
//  PinLabelView.swift
//  OneStepGPSRP
//
//  Created by Ruslan Ponomarenko on 5/4/25.
//
import SwiftUI
import UIKit
// MARK: - Custom Label View with Padding and Shadow
/// A flexible UIView for displaying text with customizable padding and styling.
class PinLabelView: UIView {
    private let label = UILabel()
    
    init(text: String) {
        super.init(frame: .zero)
        label.text = text
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        label.numberOfLines = 1
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8)
        ])
        backgroundColor = .white
        layer.cornerRadius = 4
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 2
    }
    func setText(_ text: String) {
        label.text = text
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
