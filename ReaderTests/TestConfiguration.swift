//
//  TestConfiguration.swift
//  ReaderTests
//
//  Created by SHUBHAM on 17/08/25.
//

import Foundation
import XCTest
@testable import Reader

// MARK: - Test Configuration
class TestConfiguration {
    
    // MARK: - Test Data Factory
    static func createSampleArticle(
        title: String = "Sample Article Title",
        author: String? = "John Doe",
        description: String? = "This is a sample article description",
        url: String = "https://example.com/article",
        urlToImage: String? = "https://example.com/image.jpg",
        publishedAt: String = "2025-08-17T10:30:00Z",
        content: String? = "This is the article content...",
        sourceId: String? = "techcrunch",
        sourceName: String? = "TechCrunch"
    ) -> Article {
        let source = (sourceId != nil || sourceName != nil) ? 
            Source(id: sourceId, name: sourceName ?? "Unknown Source") : nil
        
        return Article(
            source: source,
            author: author,
            title: title,
            description: description,
            url: url,
            urlToImage: urlToImage,
            publishedAt: publishedAt,
            content: content
        )
    }
    
    static func createSampleArticles(count: Int) -> [Article] {
        return (0..<count).map { index in
            createSampleArticle(
                title: "Article \(index + 1)",
                url: "https://example.com/article\(index + 1)",
                sourceId: "source\(index + 1)",
                sourceName: "Source \(index + 1)"
            )
        }
    }
    
    // MARK: - JSON Test Data
    static let sampleArticleJSON = """
    {
        "source": {
            "id": "techcrunch",
            "name": "TechCrunch"
        },
        "author": "John Doe",
        "title": "Sample Article Title",
        "description": "This is a sample article description",
        "url": "https://example.com/article",
        "urlToImage": "https://example.com/image.jpg",
        "publishedAt": "2025-08-17T10:30:00Z",
        "content": "This is the article content..."
    }
    """
    
    static let sampleNewsResponseJSON = """
    {
        "status": "ok",
        "totalResults": 2,
        "articles": [
            {
                "source": {
                    "id": "techcrunch",
                    "name": "TechCrunch"
                },
                "author": "John Doe",
                "title": "First Article",
                "description": "First article description",
                "url": "https://example.com/article1",
                "urlToImage": "https://example.com/image1.jpg",
                "publishedAt": "2025-08-17T10:30:00Z",
                "content": "First article content..."
            },
            {
                "source": {
                    "id": "bbc-news",
                    "name": "BBC News"
                },
                "author": "Jane Smith",
                "title": "Second Article",
                "description": "Second article description",
                "url": "https://example.com/article2",
                "urlToImage": "https://example.com/image2.jpg",
                "publishedAt": "2025-08-17T11:00:00Z",
                "content": "Second article content..."
            }
        ]
    }
    """
    
    static let errorResponseJSON = """
    {
        "status": "error",
        "code": "apiKeyInvalid",
        "message": "Your API key is invalid or incorrect. Check your key, or go to https://newsapi.org to create a free API key."
    }
    """
}

// MARK: - XCTestCase Extensions
extension XCTestCase {
    
    /// Helper method to wait for async operations with a timeout
    func waitForAsync(timeout: TimeInterval = 1.0, completion: @escaping () -> Void) {
        let expectation = XCTestExpectation(description: "Async operation")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            completion()
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: timeout)
    }
    
    /// Helper method to decode JSON string to model
    func decodeJSON<T: Codable>(_ jsonString: String, to type: T.Type) throws -> T {
        guard let data = jsonString.data(using: .utf8) else {
            throw TestError.invalidJSON
        }
        return try JSONDecoder().decode(type, from: data)
    }
}

// MARK: - Test Errors
enum TestError: Error, LocalizedError {
    case invalidJSON
    case networkUnavailable
    case mockSetupFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidJSON:
            return "Invalid JSON data for testing"
        case .networkUnavailable:
            return "Network unavailable for integration tests"
        case .mockSetupFailed:
            return "Failed to setup mock objects"
        }
    }
}

// MARK: - Test Assertions
extension XCTestCase {
    
    /// Assert that an article matches expected values
    func assertArticle(
        _ article: Article,
        hasTitle title: String,
        author: String? = nil,
        url: String? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertEqual(article.title, title, "Article title mismatch", file: file, line: line)
        
        if let expectedAuthor = author {
            XCTAssertEqual(article.author, expectedAuthor, "Article author mismatch", file: file, line: line)
        }
        
        if let expectedURL = url {
            XCTAssertEqual(article.url, expectedURL, "Article URL mismatch", file: file, line: line)
        }
    }
    
    /// Assert that articles array contains expected count and titles
    func assertArticles(
        _ articles: [Article],
        count expectedCount: Int,
        titles expectedTitles: [String]? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertEqual(articles.count, expectedCount, "Articles count mismatch", file: file, line: line)
        
        if let titles = expectedTitles {
            XCTAssertEqual(titles.count, expectedCount, "Expected titles count should match expected articles count", file: file, line: line)
            
            for (index, expectedTitle) in titles.enumerated() {
                XCTAssertEqual(articles[index].title, expectedTitle, "Article title at index \(index) mismatch", file: file, line: line)
            }
        }
    }
}
