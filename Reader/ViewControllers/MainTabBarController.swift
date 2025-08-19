//
//  MainTabBarController.swift
//  Reader
//
//  Created by SHUBHAM on 17/08/25.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        setupViewControllers()
    }
    
    private func setupTabBar() {
        tabBar.tintColor = .systemBlue
        tabBar.unselectedItemTintColor = .systemGray
        
        // Support for light/dark mode
        if #available(iOS 13.0, *) {
            tabBar.backgroundColor = .systemBackground
            tabBar.barTintColor = .systemBackground
        }
    }
    
    private func setupViewControllers() {
        // Articles Tab
        let articlesVC = ArticlesViewController()
        let articlesNavController = UINavigationController(rootViewController: articlesVC)
        articlesNavController.tabBarItem = UITabBarItem(
            title: "News",
            image: UIImage(systemName: "newspaper"),
            selectedImage: UIImage(systemName: "newspaper.fill")
        )
        
        // Bookmarks Tab
        let bookmarksVC = BookmarksViewController()
        let bookmarksNavController = UINavigationController(rootViewController: bookmarksVC)
        bookmarksNavController.tabBarItem = UITabBarItem(
            title: "Bookmarks",
            image: UIImage(systemName: "bookmark"),
            selectedImage: UIImage(systemName: "bookmark.fill")
        )
        
        // Settings Tab
        let settingsVC = SettingsViewController()
        let settingsNavController = UINavigationController(rootViewController: settingsVC)
        settingsNavController.tabBarItem = UITabBarItem(
            title: "Settings",
            image: UIImage(systemName: "gearshape"),
            selectedImage: UIImage(systemName: "gearshape.fill")
        )
        
        // Set view controllers
        viewControllers = [articlesNavController, bookmarksNavController, settingsNavController]
    }
}
