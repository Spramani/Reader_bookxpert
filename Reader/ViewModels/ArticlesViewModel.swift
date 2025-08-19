//
//  ArticlesViewModel.swift
//  Reader
//
//  Created by SHUBHAM on 17/08/25.
//

import Foundation
import Combine

// MARK: - Articles View Model
class ArticlesViewModel: ObservableObject {
    @Published var articles: [Article] = []
    @Published var filteredArticles: [Article] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = "" {
        didSet {
            filterArticles()
        }
    }
    
    private let networkService: NetworkServiceProtocol
    private let coreDataService: CoreDataServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(networkService: NetworkServiceProtocol = NetworkService.shared,
         coreDataService: CoreDataServiceProtocol = CoreDataService.shared) {
        self.networkService = networkService
        self.coreDataService = coreDataService
        
        loadCachedArticles()
        fetchArticles()
    }
    
    // MARK: - Public Methods
    func fetchArticles(query: String? = nil) {
        isLoading = true
        errorMessage = nil
        
        networkService.fetchArticles(query: query) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let articles):
                    self?.articles = articles
                    self?.coreDataService.saveArticles(articles)
                    self?.filterArticles()
                    
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    // If network fails, show cached articles
                        if !(self?.networkService.isConnectedToInternet() ?? false) {
                        self?.loadCachedArticles()
                    }
                }
            }
        }
    }
    
    func refreshArticles() {
        fetchArticles()
    }
    
    func searchArticles(query: String) {
        if networkService.isConnectedToInternet() {
            fetchArticles(query: query)
        } else {
            // Search in cached articles when offline
            let cachedResults = coreDataService.searchCachedArticles(query: query)
            articles = cachedResults
            filterArticles()
        }
    }
    
    func toggleBookmark(for article: Article) {
        if coreDataService.isArticleBookmarked(article) {
            coreDataService.removeBookmark(article)
        } else {
            coreDataService.saveBookmark(article)
        }
    }
    
    func isBookmarked(_ article: Article) -> Bool {
        return coreDataService.isArticleBookmarked(article)
    }
    
    // MARK: - Private Methods
    private func loadCachedArticles() {
        let cachedArticles = coreDataService.fetchCachedArticles()
        if !cachedArticles.isEmpty {
            articles = cachedArticles
            filterArticles()
        }
    }
    
    private func filterArticles() {
        if searchText.isEmpty {
            filteredArticles = articles
        } else {
            filteredArticles = articles.filter { article in
                article.title.localizedCaseInsensitiveContains(searchText) ||
                article.displayDescription.localizedCaseInsensitiveContains(searchText) ||
                article.displayAuthor.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}

// MARK: - Bookmarks View Model
class BookmarksViewModel: ObservableObject {
    @Published var bookmarkedArticles: [Article] = []
    @Published var filteredBookmarks: [Article] = []
    @Published var searchText = "" {
        didSet {
            filterBookmarks()
        }
    }
    
    private let coreDataService: CoreDataServiceProtocol
    
    init(coreDataService: CoreDataServiceProtocol = CoreDataService.shared) {
        self.coreDataService = coreDataService
        loadBookmarks()
    }
    
    func loadBookmarks() {
        bookmarkedArticles = coreDataService.fetchBookmarkedArticles()
        filterBookmarks()
    }
    
    func removeBookmark(_ article: Article) {
        coreDataService.removeBookmark(article)
        loadBookmarks()
    }
    
    private func filterBookmarks() {
        if searchText.isEmpty {
            filteredBookmarks = bookmarkedArticles
        } else {
            filteredBookmarks = bookmarkedArticles.filter { article in
                article.title.localizedCaseInsensitiveContains(searchText) ||
                article.displayDescription.localizedCaseInsensitiveContains(searchText) ||
                article.displayAuthor.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}
