//
//  ArticleTests.swift
//  ReaderTests
//
//  Created by SHUBHAM on 17/08/25.
//
//
//import XCTest
//@testable import Reader
//
//class ArticleTests: XCTestCase {
//    
//    // MARK: - Test Data
//    private let sampleArticleJSON = """
//    {
//        "source": {
//            "id": "techcrunch",
//            "name": "TechCrunch"
//        },
//        "author": "John Doe",
//        "title": "Sample Article Title",
//        "description": "This is a sample article description",
//        "url": "https://example.com/article",
//        "urlToImage": "https://example.com/image.jpg",
//        "publishedAt": "2025-08-17T10:30:00Z",
//        "content": "This is the article content..."
//    }
//    """
//    
//    private let sampleNewsResponseJSON = """
//    {
//        "status": "ok",
//        "totalResults": 2,
//        "articles": [
//            {
//                "source": {
//                    "id": "techcrunch",
//                    "name": "TechCrunch"
//                },
//                "author": "John Doe",
//                "title": "First Article",
//                "description": "First article description",
//                "url": "https://example.com/article1",
//                "urlToImage": "https://example.com/image1.jpg",
//                "publishedAt": "2025-08-17T10:30:00Z",
//                "content": "First article content..."
//            },
//            {
//                "source": {
//                    "id": "bbc-news",
//                    "name": "BBC News"
//                },
//                "author": "Jane Smith",
//                "title": "Second Article",
//                "description": "Second article description",
//                "url": "https://example.com/article2",
//                "urlToImage": "https://example.com/image2.jpg",
//                "publishedAt": "2025-08-17T11:00:00Z",
//                "content": "Second article content..."
//            }
//        ]
//    }
//    """
//    
//    // MARK: - Article Model Tests
//    func testArticleDecoding() throws {
//        let data = sampleArticleJSON.data(using: .utf8)!
//        let article = try JSONDecoder().decode(Article.self, from: data)
//        
//        XCTAssertEqual(article.title, "Sample Article Title")
//        XCTAssertEqual(article.author, "John Doe")
//        XCTAssertEqual(article.description, "This is a sample article description")
//        XCTAssertEqual(article.url, "https://example.com/article")
//        XCTAssertEqual(article.urlToImage, "https://example.com/image.jpg")
//        XCTAssertEqual(article.publishedAt, "2025-08-17T10:30:00Z")
//        XCTAssertEqual(article.content, "This is the article content...")
//        XCTAssertEqual(article.source?.id, "techcrunch")
//        XCTAssertEqual(article.source?.name, "TechCrunch")
//    }
//    
//    func testNewsResponseDecoding() throws {
//        let data = sampleNewsResponseJSON.data(using: .utf8)!
//        let newsResponse = try JSONDecoder().decode(NewsResponse.self, from: data)
//        
//        XCTAssertEqual(newsResponse.status, "ok")
//        XCTAssertEqual(newsResponse.totalResults, 2)
//        XCTAssertEqual(newsResponse.articles.count, 2)
//        
//        let firstArticle = newsResponse.articles[0]
//        XCTAssertEqual(firstArticle.title, "First Article")
//        XCTAssertEqual(firstArticle.author, "John Doe")
//        
//        let secondArticle = newsResponse.articles[1]
//        XCTAssertEqual(secondArticle.title, "Second Article")
//        XCTAssertEqual(secondArticle.author, "Jane Smith")
//    }
//    
//    // MARK: - Article Extensions Tests
//    func testFormattedDate() {
//        let article = createSampleArticle(publishedAt: "2025-08-17T10:30:00Z")
//        let formattedDate = article.formattedDate
//        
//        // The exact format will depend on locale, but it should not be the original string
//        XCTAssertNotEqual(formattedDate, "2025-08-17T10:30:00Z")
//        XCTAssertFalse(formattedDate.isEmpty)
//    }
//    
//    func testFormattedDateWithInvalidDate() {
//        let article = createSampleArticle(publishedAt: "invalid-date")
//        let formattedDate = article.formattedDate
//        
//        // Should return the original string if parsing fails
//        XCTAssertEqual(formattedDate, "invalid-date")
//    }
//    
//    func testDisplayTitle() {
//        let articleWithTitle = createSampleArticle(title: "Sample Title")
//        XCTAssertEqual(articleWithTitle.displayTitle, "Sample Title")
//        
//        let articleWithEmptyTitle = createSampleArticle(title: "")
//        XCTAssertEqual(articleWithEmptyTitle.displayTitle, "No Title")
//    }
//    
//    func testDisplayDescription() {
//        let articleWithDescription = createSampleArticle(description: "Sample Description")
//        XCTAssertEqual(articleWithDescription.displayDescription, "Sample Description")
//        
//        let articleWithoutDescription = createSampleArticle(description: nil)
//        XCTAssertEqual(articleWithoutDescription.displayDescription, "No description available")
//    }
//    
//    func testDisplayAuthor() {
//        let articleWithAuthor = createSampleArticle(author: "John Doe", sourceName: "TechCrunch")
//        XCTAssertEqual(articleWithAuthor.displayAuthor, "John Doe")
//        
//        let articleWithoutAuthor = createSampleArticle(author: nil, sourceName: "TechCrunch")
//        XCTAssertEqual(articleWithoutAuthor.displayAuthor, "TechCrunch")
//        
//        let articleWithoutAuthorOrSource = createSampleArticle(author: nil, sourceName: nil)
//        XCTAssertEqual(articleWithoutAuthorOrSource.displayAuthor, "Unknown")
//    }
//    
//    // MARK: - Helper Methods
//    private func createSampleArticle(
//        title: String = "Sample Title",
//        author: String? = "John Doe",
//        description: String? = "Sample Description",
//        url: String = "https://example.com",
//        urlToImage: String? = "https://example.com/image.jpg",
//        publishedAt: String = "2025-08-17T10:30:00Z",
//        content: String? = "Sample Content",
//        sourceName: String? = "TechCrunch"
//    ) -> Article {
//        let source = sourceName != nil ? Source(id: "test", name: sourceName!) : nil
//        return Article(
//            source: source,
//            author: author,
//            title: title,
//            description: description,
//            url: url,
//            urlToImage: urlToImage,
//            publishedAt: publishedAt,
//            content: content
//        )
//    }
//}
