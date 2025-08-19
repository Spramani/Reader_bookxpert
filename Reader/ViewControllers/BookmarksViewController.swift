//
//  BookmarksViewController.swift
//  Reader
//
//  Created by SHUBHAM on 17/08/25.
//

import UIKit
import Combine
import SafariServices

class BookmarksViewController: UIViewController {
    
    // MARK: - UI Elements
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        return tableView
    }()
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No bookmarked articles.\nBookmark articles from the News tab to see them here."
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    // MARK: - Properties
    private let viewModel = BookmarksViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        setupSearchController()
        setupAppearance()
        setupNavigationBarAppearance()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadBookmarks()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "Bookmarks"
        view.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
        view.addSubview(emptyStateLabel)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ArticleTableViewCell.self, forCellReuseIdentifier: ArticleTableViewCell.identifier)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
    }
    
    private func setupBindings() {
        viewModel.$filteredBookmarks
            .receive(on: DispatchQueue.main)
            .sink { [weak self] bookmarks in
                self?.tableView.reloadData()
                self?.updateEmptyState(isEmpty: bookmarks.isEmpty)
            }
            .store(in: &cancellables)
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search bookmarks..."
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    // MARK: - Helper Methods
    private func updateEmptyState(isEmpty: Bool) {
        emptyStateLabel.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }
    
    private func openArticle(_ article: Article) {
        guard let url = URL(string: article.url) else { return }
        
        let safariVC = SFSafariViewController(url: url)
        safariVC.preferredBarTintColor = .systemBackground
        safariVC.preferredControlTintColor = .systemBlue
        present(safariVC, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension BookmarksViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.filteredBookmarks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ArticleTableViewCell.identifier, for: indexPath) as? ArticleTableViewCell else {
            return UITableViewCell()
        }
        
        let article = viewModel.filteredBookmarks[indexPath.row]
        
        cell.configure(with: article, isBookmarked: true)
        cell.onBookmarkTapped = { [weak self] in
            self?.viewModel.removeBookmark(article)
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension BookmarksViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let article = viewModel.filteredBookmarks[indexPath.row]
        openArticle(article)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let article = viewModel.filteredBookmarks[indexPath.row]
            viewModel.removeBookmark(article)
        }
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let article = viewModel.filteredBookmarks[indexPath.row]
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let openAction = UIAction(title: "Open Article", image: UIImage(systemName: "safari")) { _ in
                self.openArticle(article)
            }
            
            let removeAction = UIAction(title: "Remove Bookmark", image: UIImage(systemName: "bookmark.slash"), attributes: .destructive) { _ in
                self.viewModel.removeBookmark(article)
            }
            
            let shareAction = UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up")) { _ in
                let activityVC = UIActivityViewController(activityItems: [article.url], applicationActivities: nil)
                self.present(activityVC, animated: true)
            }
            
            return UIMenu(title: "", children: [openAction, shareAction, removeAction])
        }
    }
}

// MARK: - UISearchResultsUpdating
extension BookmarksViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.searchText = searchController.searchBar.text ?? ""
    }
}
