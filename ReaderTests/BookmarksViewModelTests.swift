//
//  BookmarksViewModelTests.swift
//  ReaderTests
//
//  Created by SHUBHAM on 17/08/25.
//

import XCTest
import Combine
@testable import Reader

class BookmarksViewModelTests: XCTestCase {
    
    var viewModel: BookmarksViewModel!
    var mockCoreDataService: MockCoreDataService!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockCoreDataService = MockCoreDataService()
        viewModel = BookmarksViewModel(coreDataService: mockCoreDataService)
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        viewModel = nil
        mockCoreDataService = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    func testViewModelInitialization() {
        XCTAssertEqual(viewModel.bookmarkedArticles.count, 0)
        XCTAssertEqual(viewModel.filteredBookmarks.count, 0)
        XCTAssertEqual(viewModel.searchText, "")
    }
    
    // MARK: - Load Bookmarks Tests
    func testLoadBookmarks() {
        let bookmarkedArticles = [
            createSampleArticle(title: "Bookmarked Article 1"),
            createSampleArticle(title: "Bookmarked Article 2")
        ]
        
        mockCoreDataService.mockBookmarkedArticles = bookmarkedArticles
        
        viewModel.loadBookmarks()
        
        XCTAssertEqual(viewModel.bookmarkedArticles.count, 2)
        XCTAssertEqual(viewModel.filteredBookmarks.count, 2)
        XCTAssertEqual(viewModel.bookmarkedArticles[0].title, "Bookmarked Article 1")
        XCTAssertEqual(viewModel.bookmarkedArticles[1].title, "Bookmarked Article 2")
    }
    
    // MARK: - Remove Bookmark Tests
    func testRemoveBookmark() {
        let article = createSampleArticle(title: "Article to Remove")
        mockCoreDataService.mockBookmarkedArticles = [article]
        
        viewModel.loadBookmarks()
        XCTAssertEqual(viewModel.bookmarkedArticles.count, 1)
        
        viewModel.removeBookmark(article)
        
        XCTAssertTrue(mockCoreDataService.removeBookmarkCalled)
        XCTAssertEqual(viewModel.bookmarkedArticles.count, 0)
    }
    
    // MARK: - Search and Filtering Tests
    func testSearchTextFiltering() {
        let bookmarks = [
            createSampleArticle(title: "Apple iPhone Review", description: "Latest iPhone features"),
            createSampleArticle(title: "Google Pixel News", description: "Android updates"),
            createSampleArticle(title: "Tech Industry", description: "Apple and Google competition", author: "John Apple")
        ]
        
        mockCoreDataService.mockBookmarkedArticles = bookmarks
        viewModel.loadBookmarks()
        
        // Test empty search
        viewModel.searchText = ""
        XCTAssertEqual(viewModel.filteredBookmarks.count, 3)
        
        // Test title search
        viewModel.searchText = "Apple"
        XCTAssertEqual(viewModel.filteredBookmarks.count, 2)
        
        // Test description search
        viewModel.searchText = "Android"
        XCTAssertEqual(viewModel.filteredBookmarks.count, 2)
        
        // Test author search
        viewModel.searchText = "John"
        XCTAssertEqual(viewModel.filteredBookmarks.count, 1)
        
        // Test case insensitive search
        viewModel.searchText = "IPHONE"
        XCTAssertEqual(viewModel.filteredBookmarks.count, 1)
        
        // Test no matches
        viewModel.searchText = "Windows"
        XCTAssertEqual(viewModel.filteredBookmarks.count, 0)
    }
    
    func testSearchTextProperty() {
        let expectation = XCTestExpectation(description: "Search text updated")
        
        viewModel.$searchText
            .dropFirst() // Skip initial empty value
            .sink { searchText in
                XCTAssertEqual(searchText, "test search")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.searchText = "test search"
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFilteredBookmarksUpdate() {
        let expectation = XCTestExpectation(description: "Filtered bookmarks updated")
        
        let bookmarks = [
            createSampleArticle(title: "Apple News"),
            createSampleArticle(title: "Google News")
        ]
        
        mockCoreDataService.mockBookmarkedArticles = bookmarks
        viewModel.loadBookmarks()
        
        viewModel.$filteredBookmarks
            .dropFirst() // Skip initial value
            .sink { filteredBookmarks in
                XCTAssertEqual(filteredBookmarks.count, 1)
                XCTAssertEqual(filteredBookmarks[0].title, "Apple News")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.searchText = "Apple"
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Edge Cases Tests
    func testEmptyBookmarksList() {
        mockCoreDataService.mockBookmarkedArticles = []
        
        viewModel.loadBookmarks()
        
        XCTAssertEqual(viewModel.bookmarkedArticles.count, 0)
        XCTAssertEqual(viewModel.filteredBookmarks.count, 0)
    }
    
    func testSearchWithEmptyBookmarks() {
        mockCoreDataService.mockBookmarkedArticles = []
        viewModel.loadBookmarks()
        
        viewModel.searchText = "test"
        
        XCTAssertEqual(viewModel.filteredBookmarks.count, 0)
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
            url: "https://example.com/\(title.replacingOccurrences(of: " ", with: "-"))",
            urlToImage: "https://example.com/image.jpg",
            publishedAt: "2025-08-17T10:30:00Z",
            content: "Sample Content"
        )
    }
}
