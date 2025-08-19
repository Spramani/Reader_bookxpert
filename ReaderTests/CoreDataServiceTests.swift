//
//  CoreDataServiceTests.swift
//  ReaderTests
//
//  Created by SHUBHAM on 17/08/25.
//

import XCTest
import CoreData
@testable import Reader

class CoreDataServiceTests: XCTestCase {
    
    var coreDataService: CoreDataService!
    var testContext: NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        coreDataService = CoreDataService.shared
        
        // Create in-memory store for testing
        let persistentStoreDescription = NSPersistentStoreDescription()
        persistentStoreDescription.type = NSInMemoryStoreType
        
        let container = NSPersistentContainer(name: "ReaderDataModel")
        container.persistentStoreDescriptions = [persistentStoreDescription]
        
        container.loadPersistentStores { _, error in
            XCTAssertNil(error)
        }
        
        testContext = container.viewContext
    }
    
    override func tearDown() {
        // Clear all data after each test
        clearAllData()
        coreDataService = nil
        testContext = nil
        super.tearDown()
    }
    
    // MARK: - Articles Caching Tests
    func testSaveAndFetchCachedArticles() {
        let articles = [
            createSampleArticle(title: "Article 1", url: "https://example.com/1"),
            createSampleArticle(title: "Article 2", url: "https://example.com/2")
        ]
        
        coreDataService.saveArticles(articles)
        
        let cachedArticles = coreDataService.fetchCachedArticles()
        
        XCTAssertEqual(cachedArticles.count, 2)
        XCTAssertEqual(cachedArticles[0].title, "Article 1")
        XCTAssertEqual(cachedArticles[1].title, "Article 2")
    }
    
    func testSaveArticlesClearsExistingCache() {
        // Save initial articles
        let initialArticles = [createSampleArticle(title: "Initial Article")]
        coreDataService.saveArticles(initialArticles)
        
        let initialCached = coreDataService.fetchCachedArticles()
        XCTAssertEqual(initialCached.count, 1)
        
        // Save new articles (should replace existing)
        let newArticles = [
            createSampleArticle(title: "New Article 1"),
            createSampleArticle(title: "New Article 2")
        ]
        coreDataService.saveArticles(newArticles)
        
        let finalCached = coreDataService.fetchCachedArticles()
        XCTAssertEqual(finalCached.count, 2)
        XCTAssertEqual(finalCached[0].title, "New Article 1")
        XCTAssertEqual(finalCached[1].title, "New Article 2")
    }
    
    func testSearchCachedArticles() {
        let articles = [
            createSampleArticle(title: "Apple iPhone News", description: "Latest iPhone updates"),
            createSampleArticle(title: "Google Android Update", description: "New Android features"),
            createSampleArticle(title: "Tech Industry News", description: "Apple and Google competition")
        ]
        
        coreDataService.saveArticles(articles)
        
        // Test title search
        let appleResults = coreDataService.searchCachedArticles(query: "Apple")
        XCTAssertEqual(appleResults.count, 2)
        
        // Test description search
        let androidResults = coreDataService.searchCachedArticles(query: "Android")
        XCTAssertEqual(androidResults.count, 2)
        
        // Test case insensitive search
        let iphoneResults = coreDataService.searchCachedArticles(query: "iphone")
        XCTAssertEqual(iphoneResults.count, 1)
        
        // Test no matches
        let windowsResults = coreDataService.searchCachedArticles(query: "Windows")
        XCTAssertEqual(windowsResults.count, 0)
    }
    
    // MARK: - Bookmarks Tests
    func testSaveBookmark() {
        let article = createSampleArticle(title: "Bookmark Test")
        
        XCTAssertFalse(coreDataService.isArticleBookmarked(article))
        
        coreDataService.saveBookmark(article)
        
        XCTAssertTrue(coreDataService.isArticleBookmarked(article))
        
        let bookmarks = coreDataService.fetchBookmarkedArticles()
        XCTAssertEqual(bookmarks.count, 1)
        XCTAssertEqual(bookmarks[0].title, "Bookmark Test")
    }
    
    func testSaveBookmarkDuplicate() {
        let article = createSampleArticle(title: "Duplicate Test")
        
        // Save bookmark twice
        coreDataService.saveBookmark(article)
        coreDataService.saveBookmark(article)
        
        let bookmarks = coreDataService.fetchBookmarkedArticles()
        XCTAssertEqual(bookmarks.count, 1) // Should not create duplicate
    }
    
    func testRemoveBookmark() {
        let article = createSampleArticle(title: "Remove Test")
        
        // Save bookmark first
        coreDataService.saveBookmark(article)
        XCTAssertTrue(coreDataService.isArticleBookmarked(article))
        
        // Remove bookmark
        coreDataService.removeBookmark(article)
        XCTAssertFalse(coreDataService.isArticleBookmarked(article))
        
        let bookmarks = coreDataService.fetchBookmarkedArticles()
        XCTAssertEqual(bookmarks.count, 0)
    }
    
    func testFetchBookmarkedArticles() {
        let articles = [
            createSampleArticle(title: "Bookmark 1", url: "https://example.com/bookmark1"),
            createSampleArticle(title: "Bookmark 2", url: "https://example.com/bookmark2")
        ]
        
        for article in articles {
            coreDataService.saveBookmark(article)
        }
        
        let bookmarks = coreDataService.fetchBookmarkedArticles()
        XCTAssertEqual(bookmarks.count, 2)
        
        // Should be sorted by bookmark date (most recent first)
        XCTAssertEqual(bookmarks[0].title, "Bookmark 2")
        XCTAssertEqual(bookmarks[1].title, "Bookmark 1")
    }
    
    func testIsArticleBookmarked() {
        let article1 = createSampleArticle(title: "Article 1", url: "https://example.com/1")
        let article2 = createSampleArticle(title: "Article 2", url: "https://example.com/2")
        
        XCTAssertFalse(coreDataService.isArticleBookmarked(article1))
        XCTAssertFalse(coreDataService.isArticleBookmarked(article2))
        
        coreDataService.saveBookmark(article1)
        
        XCTAssertTrue(coreDataService.isArticleBookmarked(article1))
        XCTAssertFalse(coreDataService.isArticleBookmarked(article2))
    }
    
    // MARK: - Core Data Extensions Tests
    func testCachedArticleToArticle() {
        let cachedArticle = CachedArticle(context: testContext)
        cachedArticle.title = "Test Title"
        cachedArticle.url = "https://example.com"
        cachedArticle.publishedAt = "2025-08-17T10:30:00Z"
        cachedArticle.author = "Test Author"
        cachedArticle.articleDescription = "Test Description"
        cachedArticle.content = "Test Content"
        cachedArticle.urlToImage = "https://example.com/image.jpg"
        cachedArticle.sourceName = "Test Source"
        cachedArticle.sourceId = "test-source"
        
        let article = cachedArticle.toArticle()
        
        XCTAssertNotNil(article)
        XCTAssertEqual(article?.title, "Test Title")
        XCTAssertEqual(article?.url, "https://example.com")
        XCTAssertEqual(article?.author, "Test Author")
        XCTAssertEqual(article?.description, "Test Description")
        XCTAssertEqual(article?.source?.name, "Test Source")
        XCTAssertEqual(article?.source?.id, "test-source")
    }
    
    func testCachedArticleToArticleWithMissingData() {
        let cachedArticle = CachedArticle(context: testContext)
        // Missing required fields
        
        let article = cachedArticle.toArticle()
        XCTAssertNil(article)
    }
    
    func testBookmarkedArticleToArticle() {
        let bookmarkedArticle = BookmarkedArticle(context: testContext)
        bookmarkedArticle.title = "Bookmarked Title"
        bookmarkedArticle.url = "https://example.com/bookmark"
        bookmarkedArticle.publishedAt = "2025-08-17T10:30:00Z"
        bookmarkedArticle.author = "Bookmark Author"
        bookmarkedArticle.articleDescription = "Bookmark Description"
        bookmarkedArticle.content = "Bookmark Content"
        bookmarkedArticle.urlToImage = "https://example.com/bookmark-image.jpg"
        bookmarkedArticle.sourceName = "Bookmark Source"
        bookmarkedArticle.sourceId = "bookmark-source"
        
        let article = bookmarkedArticle.toArticle()
        
        XCTAssertNotNil(article)
        XCTAssertEqual(article?.title, "Bookmarked Title")
        XCTAssertEqual(article?.url, "https://example.com/bookmark")
        XCTAssertEqual(article?.author, "Bookmark Author")
        XCTAssertEqual(article?.description, "Bookmark Description")
        XCTAssertEqual(article?.source?.name, "Bookmark Source")
        XCTAssertEqual(article?.source?.id, "bookmark-source")
    }
    
    // MARK: - Performance Tests
    func testSaveArticlesPerformance() {
        let articles = (0..<100).map { index in
            createSampleArticle(title: "Article \(index)", url: "https://example.com/\(index)")
        }
        
        measure {
            coreDataService.saveArticles(articles)
        }
    }
    
    func testFetchCachedArticlesPerformance() {
        let articles = (0..<100).map { index in
            createSampleArticle(title: "Article \(index)", url: "https://example.com/\(index)")
        }
        coreDataService.saveArticles(articles)
        
        measure {
            _ = coreDataService.fetchCachedArticles()
        }
    }
    
    // MARK: - Helper Methods
    private func createSampleArticle(
        title: String = "Sample Title",
        url: String = "https://example.com",
        description: String = "Sample Description",
        author: String = "Sample Author"
    ) -> Article {
        let source = Source(id: "test", name: "Test Source")
        return Article(
            source: source,
            author: author,
            title: title,
            description: description,
            url: url,
            urlToImage: "https://example.com/image.jpg",
            publishedAt: "2025-08-17T10:30:00Z",
            content: "Sample Content"
        )
    }
    
    private func clearAllData() {
        // Clear cached articles
        let cachedRequest: NSFetchRequest<NSFetchRequestResult> = CachedArticle.fetchRequest()
        let cachedDeleteRequest = NSBatchDeleteRequest(fetchRequest: cachedRequest)
        
        // Clear bookmarked articles
        let bookmarkRequest: NSFetchRequest<NSFetchRequestResult> = BookmarkedArticle.fetchRequest()
        let bookmarkDeleteRequest = NSBatchDeleteRequest(fetchRequest: bookmarkRequest)
        
        do {
            try testContext.execute(cachedDeleteRequest)
            try testContext.execute(bookmarkDeleteRequest)
            try testContext.save()
        } catch {
            print("Failed to clear test data: \(error)")
        }
    }
}
