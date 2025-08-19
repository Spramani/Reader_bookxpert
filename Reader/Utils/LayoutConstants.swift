//
//  LayoutConstants.swift
//  Reader
//
//  Created by SHUBHAM on 17/08/25.
//

import UIKit

// MARK: - Layout Constants
struct LayoutConstants {
    
    // MARK: - Spacing
    struct Spacing {
        static let tiny: CGFloat = 4
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let extraLarge: CGFloat = 32
    }
    
    // MARK: - Margins
    struct Margins {
        static let horizontal: CGFloat = 16
        static let vertical: CGFloat = 16
        static let safe: CGFloat = 8
    }
    
    // MARK: - Corner Radius
    struct CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
    }
    
    // MARK: - Image Sizes
    struct ImageSize {
        static let thumbnail: CGFloat = 80
        static let medium: CGFloat = 120
        static let large: CGFloat = 200
    }
    
    // MARK: - Font Sizes
    struct FontSize {
        static let caption: CGFloat = 12
        static let body: CGFloat = 16
        static let headline: CGFloat = 18
        static let title: CGFloat = 22
        static let largeTitle: CGFloat = 28
    }
    
    // MARK: - Cell Heights
    struct CellHeight {
        static let minimum: CGFloat = 80
        static let compact: CGFloat = 100
        static let regular: CGFloat = 120
        static let expanded: CGFloat = 160
    }
}

// MARK: - Adaptive Layout Helper
class AdaptiveLayoutHelper {
    
    // MARK: - Size Class Detection
    static func isCompactWidth(_ traitCollection: UITraitCollection) -> Bool {
        return traitCollection.horizontalSizeClass == .compact
    }
    
    static func isCompactHeight(_ traitCollection: UITraitCollection) -> Bool {
        return traitCollection.verticalSizeClass == .compact
    }
    
    static func isRegularWidth(_ traitCollection: UITraitCollection) -> Bool {
        return traitCollection.horizontalSizeClass == .regular
    }
    
    static func isRegularHeight(_ traitCollection: UITraitCollection) -> Bool {
        return traitCollection.verticalSizeClass == .regular
    }
    
    // MARK: - Device Type Detection
    static var isIPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    static var isIPhone: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    
    // MARK: - Adaptive Values
    static func adaptiveMargin(for traitCollection: UITraitCollection) -> CGFloat {
        if isIPad {
            return isCompactWidth(traitCollection) ? LayoutConstants.Margins.horizontal : LayoutConstants.Spacing.large
        } else {
            return LayoutConstants.Margins.horizontal
        }
    }
    
    static func adaptiveImageSize(for traitCollection: UITraitCollection) -> CGFloat {
        if isIPad {
            return isCompactWidth(traitCollection) ? LayoutConstants.ImageSize.medium : LayoutConstants.ImageSize.large
        } else {
            return isCompactHeight(traitCollection) ? LayoutConstants.ImageSize.thumbnail : LayoutConstants.ImageSize.medium
        }
    }
    
    static func adaptiveCellHeight(for traitCollection: UITraitCollection) -> CGFloat {
        if isIPad {
            return isCompactWidth(traitCollection) ? LayoutConstants.CellHeight.regular : LayoutConstants.CellHeight.expanded
        } else {
            return isCompactHeight(traitCollection) ? LayoutConstants.CellHeight.compact : LayoutConstants.CellHeight.regular
        }
    }
    
    static func adaptiveFontSize(base: CGFloat, for traitCollection: UITraitCollection) -> CGFloat {
        let scaleFactor: CGFloat
        
        if isIPad {
            scaleFactor = isCompactWidth(traitCollection) ? 1.1 : 1.2
        } else {
            scaleFactor = isCompactHeight(traitCollection) ? 0.9 : 1.0
        }
        
        return base * scaleFactor
    }
    
    // MARK: - Column Count for Collection Views
    static func columnCount(for width: CGFloat, traitCollection: UITraitCollection) -> Int {
        if isIPad {
            if isCompactWidth(traitCollection) {
                return width > 600 ? 2 : 1
            } else {
                return width > 1000 ? 3 : 2
            }
        } else {
            return isCompactHeight(traitCollection) ? 2 : 1
        }
    }
}

// MARK: - Auto Layout Extensions
extension UIView {
    
    // MARK: - Constraint Helpers
    func pinToSuperview(with margins: UIEdgeInsets = .zero) {
        guard let superview = superview else { return }
        
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: superview.topAnchor, constant: margins.top),
            leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: margins.left),
            trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -margins.right),
            bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -margins.bottom)
        ])
    }
    
    func pinToSafeArea(with margins: UIEdgeInsets = .zero) {
        guard let superview = superview else { return }
        
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.topAnchor, constant: margins.top),
            leadingAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.leadingAnchor, constant: margins.left),
            trailingAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.trailingAnchor, constant: -margins.right),
            bottomAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.bottomAnchor, constant: -margins.bottom)
        ])
    }
    
    func centerInSuperview() {
        guard let superview = superview else { return }
        
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: superview.centerXAnchor),
            centerYAnchor.constraint(equalTo: superview.centerYAnchor)
        ])
    }
    
    func setSize(_ size: CGSize) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: size.width),
            heightAnchor.constraint(equalToConstant: size.height)
        ])
    }
    
    func setAspectRatio(_ ratio: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalTo: heightAnchor, multiplier: ratio).isActive = true
    }
}
