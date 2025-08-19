//
//  AppearanceManager.swift
//  Reader
//
//  Created by SHUBHAM on 17/08/25.
//

import UIKit

// MARK: - Theme Mode
enum ThemeMode: String, CaseIterable {
    case system = "system"
    case light = "light"
    case dark = "dark"
    
    var displayName: String {
        switch self {
        case .system:
            return "System"
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        }
    }
    
    var userInterfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .system:
            return .unspecified
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}

// MARK: - Appearance Manager
class AppearanceManager {
    static let shared = AppearanceManager()
    
    private let userDefaults = UserDefaults.standard
    private let themeKey = "selectedTheme"
    
    private init() {}
    
    // MARK: - Current Theme
    var currentTheme: ThemeMode {
        get {
            let savedTheme = userDefaults.string(forKey: themeKey) ?? ThemeMode.system.rawValue
            return ThemeMode(rawValue: savedTheme) ?? .system
        }
        set {
            userDefaults.set(newValue.rawValue, forKey: themeKey)
            applyTheme(newValue)
        }
    }
    
    // MARK: - Apply Theme
    func applyTheme(_ theme: ThemeMode) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return
        }
        
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve) {
            window.overrideUserInterfaceStyle = theme.userInterfaceStyle
        }
    }
    
    // MARK: - Initialize Theme
    func initializeTheme() {
        applyTheme(currentTheme)
    }
}
