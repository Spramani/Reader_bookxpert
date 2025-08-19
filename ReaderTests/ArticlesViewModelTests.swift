//
//  ArticlesViewModelTests.swift
//  ReaderTests
//
//  Created by SHUBHAM on 17/08/25.
//

import XCTest
import Combine
@testable import Reader

class ArticlesViewModelTests: XCTestCase {
    
    var viewModel: ArticlesViewModel!
    var mockNetworkService: MockNetworkService!
    var mockCoreDataService: MockCoreDataService!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        mockCoreDataService = MockCoreDataService()
        viewModel = ArticlesViewModel(
            networkService: mockNetworkService,
            coreDataService: mockCoreDataService
        )
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        viewModel = nil
        mockNetworkService = nil
        mockCoreDataService = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    func testViewModelInitialization() {
        XCTAssertEqual(viewModel.articles.count, 0)
        XCTAssertEqual(viewModel.filteredArticles.count, 0)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.searchText, "")
    }
    
    // MARK: - Fetch Articles Tests
    func testFetchArticlesSuccess() {
        let expectation = XCTestExpectation(description: "Articles fetched successfully")
        
        let sampleArticles = [createSampleArticle(title: "Test Article 1"),
                              createSampleArticle(title: "Test Article 2")]
        mockNetworkService.mockArticles = sampleArticles
        mockNetworkService.shouldReturnError = false
        
        viewModel.$articles
            .dropFirst() // Skip initial empty value
            .sink { articles in
                XCTAssertEqual(articles.count, 2)
                XCTAssertEqual(articles[0].title, "Test Article 1")
                XCTAssertEqual(articles[1].title, "Test Article 2")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.fetchArticles()
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testFetchArticlesFailure() {
        let expectation = XCTestExpectation(description: "Articles fetch failed")
        
        mockNetworkService.shouldReturnError = true
        
        viewModel.$errorMessage
            .compactMap { $0 }
            .sink { errorMessage in
                XCTAssertEqual(errorMessage, "No internet connection available")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.fetchArticles()
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testFetchArticlesWithQuery() {
        let expectation = XCTestExpectation(description: "Articles fetched with query")
        
        let sampleArticles = [createSampleArticle(title: "Apple News")]
        mockNetworkService.mockArticles = sampleArticles
        mockNetworkService.shouldReturnError = false
        
        viewModel.$articles
            .dropFirst()
            .sink { articles in
                XCTAssertEqual(articles.count, 1)
                XCTAssertEqual(articles[0].title, "Apple News")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.fetchArticles(query: "Apple")
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    // MARK: - Loading State Tests
    func testLoadingState() {
        let expectation = XCTestExpectation(description: "Loading state changes")
        expectation.expectedFulfillmentCount = 2
        
        var loadingStates: [Bool] = []
        
        viewModel.$isLoading
            .sink { isLoading in
                loadingStates.append(isLoading)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        mockNetworkService.shouldReturnError = false
        viewModel.fetchArticles()
        
        wait(for: [expectation], timeout: 2.0)
        
        // Should start with false, then true when loading starts, then false when done
        XCTAssertEqual(loadingStates.count, 2)
        XCTAssertTrue(loadingStates[1])  // Loading started
    }
    
    // MARK: - Search and Filtering Tests
    func testSearchTextFiltering() {
        let articles = [
            createSampleArticle(title: "Apple iPhone News", description: "Latest iPhone updates"),
            createSampleArticle(title: "Google Android Update", description: "Android features"),
            createSampleArticle(title: "Tech News", description: "Apple and Google news")
        ]
        
        // Set articles directly for filtering test
        viewModel.articles = articles
        
        // Test empty search
        viewModel.searchText = ""
        XCTAssertEqual(viewModel.filteredArticles.count, 3)
        
        // Test title search
        viewModel.searchText = "Apple"
        XCTAssertEqual(viewModel.filteredArticles.count, 2)
        
        // Test description search
        viewModel.searchText = "Android"
        XCTAssertEqual(viewModel.filteredArticles.count, 2)
        
        // Test case insensitive search
        viewModel.searchText = "IPHONE"
        XCTAssertEqual(viewModel.filteredArticles.count, 1)
        
        // Test no matches
        viewModel.searchText = "Windows"
        XCTAssertEqual(viewModel.filteredArticles.count, 0)
    }
    
    func testSearchArticlesOnline() {
        let expectation = XCTestExpectation(description: "Search articles online")
        
        mockNetworkService.shouldReturnError = false
        mockNetworkService.mockArticles = [createSampleArticle(title: "Search Result")]
        
        viewModel.$articles
            .dropFirst()
            .sink { articles in
                XCTAssertEqual(articles.count, 1)
                XCTAssertEqual(articles[0].title, "Search Result")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.searchArticles(query: "test")
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testSearchArticlesOffline() {
        mockNetworkService.shouldReturnError = true
        mockCoreDataService.mockSearchResults = [createSampleArticle(title: "Cached Result")]
        
        viewModel.searchArticles(query: "test")
        
        XCTAssertEqual(viewModel.articles.count, 1)
        XCTAssertEqual(viewModel.articles[0].title, "Cached Result")
    }
    
    // MARK: - Bookmark Tests
    func testToggleBookmark() {
        let article = createSampleArticle()
        
        // Test adding bookmark
        mockCoreDataService.isBookmarked = false
        viewModel.toggleBookmark(for: article)
        XCTAssertTrue(mockCoreDataService.saveBookmarkCalled)
        
        // Test removing bookmark
        mockCoreDataService.isBookmarked = true
        mockCoreDataService.saveBookmarkCalled = false
        viewModel.toggleBookmark(for: article)
        XCTAssertTrue(mockCoreDataService.removeBookmarkCalled)
    }
    
    func testIsBookmarked() {
        let article = createSampleArticle()
        
        mockCoreDataService.isBookmarked = true
        XCTAssertTrue(viewModel.isBookmarked(article))
        
        mockCoreDataService.isBookmarked = false
        XCTAssertFalse(viewModel.isBookmarked(article))
    }
    
    // MARK: - Refresh Tests
    func testRefreshArticles() {
        let expectation = XCTestExpectation(description: "Articles refreshed")
        
        mockNetworkService.shouldReturnError = false
        mockNetworkService.mockArticles = [createSampleArticle(title: "Refreshed Article")]
        
        viewModel.$articles
            .dropFirst()
            .sink { articles in
                XCTAssertEqual(articles.count, 1)
                XCTAssertEqual(articles[0].title, "Refreshed Article")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.refreshArticles()
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    // MARK: - Helper Methods
    private func createSampleArticle(
        title: String = "Sample Title",
        description: String = "Sample Description",
        author: String = "Sample Author"
    ) -> Article {
        let source = Source(id: "test", name: "Test Source")
        return Article(
            source: source,
            author: author,
            title: title,
            description: description,
            url: "https://example.com",
            urlToImage: "https://example.com/image.jpg",
            publishedAt: "2025-08-17T10:30:00Z",
            content: "Sample Content"
        )
    }
}

// MARK: - Mock Core Data Service
class MockCoreDataService: CoreDataServiceProtocol {
    var mockCachedArticles: [Article] = []
    var mockBookmarkedArticles: [Article] = []
    var mockSearchResults: [Article] = []
    var isBookmarked = false
    
    var saveArticlesCalled = false
    var saveBookmarkCalled = false
    var removeBookmarkCalled = false
    
    func fetchCachedArticles() -> [Article] {
        return mockCachedArticles
    }
    
    func saveArticles(_ articles: [Article]) {
        saveArticlesCalled = true
        mockCachedArticles = articles
    }
    
    func searchCachedArticles(query: String) -> [Article] {
        return mockSearchResults
    }
    
    func fetchBookmarkedArticles() -> [Article] {
        return mockBookmarkedArticles
    }
    
    func saveBookmark(_ article: Article) {
        saveBookmarkCalled = true
        mockBookmarkedArticles.append(article)
    }
    
    func removeBookmark(_ article: Article) {
        removeBookmarkCalled = true
        mockBookmarkedArticles.removeAll { $0.url == article.url }
    }
    
    func isArticleBookmarked(_ article: Article) -> Bool {
        return isBookmarked
    }
}
