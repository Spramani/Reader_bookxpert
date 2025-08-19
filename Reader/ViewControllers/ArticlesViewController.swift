//
//  ArticlesViewController.swift
//  Reader
//
//  Created by SHUBHAM on 17/08/25.
//

import UIKit
import Combine
import SafariServices

class ArticlesViewController: UIViewController {
    
    // MARK: - UI Elements
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        return tableView
    }()
    
    private let searchController = UISearchController(searchResultsController: nil)
    private let refreshControl = UIRefreshControl()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No articles available.\nPull to refresh or check your internet connection."
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    // MARK: - Properties
    private let viewModel = ArticlesViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        setupSearchController()
        setupRefreshControl()
        setupAppearance()
        setupNavigationBarAppearance()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Refresh bookmarks status when returning to this view
        tableView.reloadData()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateLayoutForTraitCollection()
    }
    
    private func updateLayoutForTraitCollection() {
        // Update table view row height based on size class
        tableView.estimatedRowHeight = AdaptiveLayoutHelper.adaptiveCellHeight(for: traitCollection)
        tableView.rowHeight = UITableView.automaticDimension
        
        // Update empty state label font
        emptyStateLabel.font = UIFont.systemFont(ofSize: AdaptiveLayoutHelper.adaptiveFontSize(base: LayoutConstants.FontSize.body, for: traitCollection))
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "News"
        view.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
        view.addSubview(emptyStateLabel)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ArticleTableViewCell.self, forCellReuseIdentifier: ArticleTableViewCell.identifier)
        
        // Use adaptive layout helpers
        tableView.pinToSafeArea()
        loadingIndicator.centerInSuperview()
        
        NSLayoutConstraint.activate([
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: LayoutConstants.Spacing.extraLarge),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -LayoutConstants.Spacing.extraLarge)
        ])
    }
    
    private func setupBindings() {
        viewModel.$filteredArticles
            .receive(on: DispatchQueue.main)
            .sink { [weak self] articles in
                self?.tableView.reloadData()
                self?.updateEmptyState(isEmpty: articles.isEmpty)
            }
            .store(in: &cancellables)
        
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.loadingIndicator.startAnimating()
                } else {
                    self?.loadingIndicator.stopAnimating()
                    self?.refreshControl.endRefreshing()
                }
            }
            .store(in: &cancellables)
        
        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                if let error = errorMessage {
                    self?.showErrorAlert(message: error)
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search articles..."
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    private func setupRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refreshArticles), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    // MARK: - Actions
    @objc private func refreshArticles() {
        viewModel.refreshArticles()
    }
    
    // MARK: - Helper Methods
    private func updateEmptyState(isEmpty: Bool) {
        emptyStateLabel.isHidden = !isEmpty || viewModel.isLoading
        tableView.isHidden = isEmpty && !viewModel.isLoading
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
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
extension ArticlesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.filteredArticles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ArticleTableViewCell.identifier, for: indexPath) as? ArticleTableViewCell else {
            return UITableViewCell()
        }
        
        let article = viewModel.filteredArticles[indexPath.row]
        let isBookmarked = viewModel.isBookmarked(article)
        
        cell.configure(with: article, isBookmarked: isBookmarked)
        cell.onBookmarkTapped = { [weak self] in
            self?.viewModel.toggleBookmark(for: article)
            self?.tableView.reloadRows(at: [indexPath], with: .none)
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ArticlesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let article = viewModel.filteredArticles[indexPath.row]
        openArticle(article)
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let article = viewModel.filteredArticles[indexPath.row]
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let openAction = UIAction(title: "Open Article", image: UIImage(systemName: "safari")) { _ in
                self.openArticle(article)
            }
            
            let bookmarkTitle = self.viewModel.isBookmarked(article) ? "Remove Bookmark" : "Bookmark"
            let bookmarkImage = self.viewModel.isBookmarked(article) ? UIImage(systemName: "bookmark.slash") : UIImage(systemName: "bookmark")
            
            let bookmarkAction = UIAction(title: bookmarkTitle, image: bookmarkImage) { _ in
                self.viewModel.toggleBookmark(for: article)
                self.tableView.reloadRows(at: [indexPath], with: .none)
            }
            
            let shareAction = UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up")) { _ in
                let activityVC = UIActivityViewController(activityItems: [article.url], applicationActivities: nil)
                self.present(activityVC, animated: true)
            }
            
            return UIMenu(title: "", children: [openAction, bookmarkAction, shareAction])
        }
    }
}

// MARK: - UISearchResultsUpdating
extension ArticlesViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        
        if searchText.isEmpty {
            viewModel.searchText = ""
        } else {
            // Debounce search to avoid too many API calls
        //    NSObject.cancelPreviousPerformRequests(target: self, selector: #selector(performSearch), object: nil)
            perform(#selector(performSearch), with: nil, afterDelay: 0.5)
        }
        
        viewModel.searchText = searchText
    }
    
    @objc private func performSearch() {
        let searchText = searchController.searchBar.text ?? ""
        if !searchText.isEmpty {
            viewModel.searchArticles(query: searchText)
        }
    }
}
