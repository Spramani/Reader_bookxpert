//
//  UIViewController+Extensions.swift
//  Reader
//
//  Created by SHUBHAM on 17/08/25.
//

import UIKit

extension UIViewController {
    
    // MARK: - Dark Mode Support
    func setupAppearance() {
        // Ensure proper appearance for light/dark mode
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .unspecified // Follow system setting
        }
    }
    
    // MARK: - Navigation Bar Appearance
    func setupNavigationBarAppearance() {
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .systemBackground
            appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
            
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
            navigationController?.navigationBar.compactAppearance = appearance
        }
        
        navigationController?.navigationBar.tintColor = .systemBlue
        navigationController?.navigationBar.isTranslucent = true
    }
}

// MARK: - UIColor Extensions for Theme Support
extension UIColor {
    
    static var readerPrimary: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { traitCollection in
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    return UIColor.systemBlue
                default:
                    return UIColor.systemBlue
                }
            }
        } else {
            return UIColor.systemBlue
        }
    }
    
    static var readerSecondary: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.secondaryLabel
        } else {
            return UIColor.gray
        }
    }
    
    static var readerBackground: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.systemBackground
        } else {
            return UIColor.white
        }
    }
    
    static var readerCardBackground: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.secondarySystemBackground
        } else {
            return UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0)
        }
    }
}
