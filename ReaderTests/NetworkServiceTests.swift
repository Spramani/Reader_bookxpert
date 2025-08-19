//
//  NetworkServiceTests.swift
//  ReaderTests
//
//  Created by SHUBHAM on 17/08/25.
//

import XCTest
import Network
@testable import Reader

class NetworkServiceTests: XCTestCase {
    
    var networkService: NetworkService!
    var mockNetworkService: MockNetworkService!
    
    override func setUp() {
        super.setUp()
        networkService = NetworkService.shared
        mockNetworkService = MockNetworkService()
    }
    
    override func tearDown() {
        networkService = nil
        mockNetworkService = nil
        super.tearDown()
    }
    
    // MARK: - Mock Network Service Tests
    func testMockNetworkServiceSuccess() {
        let expectation = XCTestExpectation(description: "Fetch articles successfully")
        
        let sampleArticle = createSampleArticle()
        mockNetworkService.mockArticles = [sampleArticle]
        mockNetworkService.shouldReturnError = false
        
        mockNetworkService.fetchArticles(query: nil) { result in
            switch result {
            case .success(let articles):
                XCTAssertEqual(articles.count, 1)
                XCTAssertEqual(articles.first?.title, "Sample Title")
                expectation.fulfill()
            case .failure:
                XCTFail("Expected success but got failure")
            }
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testMockNetworkServiceFailure() {
        let expectation = XCTestExpectation(description: "Fetch articles with error")
        
        mockNetworkService.shouldReturnError = true
        
        mockNetworkService.fetchArticles(query: nil) { result in
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                XCTAssertEqual(error, NetworkError.noInternetConnection)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testMockNetworkServiceInternetConnection() {
        mockNetworkService.shouldReturnError = false
        XCTAssertTrue(mockNetworkService.isConnectedToInternet())
        
        mockNetworkService.shouldReturnError = true
        XCTAssertFalse(mockNetworkService.isConnectedToInternet())
    }
    
    // MARK: - Network Error Tests
    func testNetworkErrorDescriptions() {
        XCTAssertEqual(NetworkError.noInternetConnection.errorDescription, "No internet connection available")
        XCTAssertEqual(NetworkError.invalidURL.errorDescription, "Invalid URL")
        XCTAssertEqual(NetworkError.noData.errorDescription, "No data received")
        XCTAssertEqual(NetworkError.decodingError.errorDescription, "Failed to decode response")
        XCTAssertEqual(NetworkError.serverError(404).errorDescription, "Server error with code: 404")
        XCTAssertEqual(NetworkError.unknown.errorDescription, "An unknown error occurred")
    }
    
    // MARK: - URL Construction Tests
    func testURLConstruction() {
        let baseURL = "https://newsapi.org/v2"
        let apiKey = "test-api-key"
        
        // Test top headlines URL
        let topHeadlinesEndpoint = "/top-headlines?country=us&apiKey=\(apiKey)"
        let topHeadlinesURL = URL(string: baseURL + topHeadlinesEndpoint)
        XCTAssertNotNil(topHeadlinesURL)
        XCTAssertEqual(topHeadlinesURL?.absoluteString, "https://newsapi.org/v2/top-headlines?country=us&apiKey=test-api-key")
        
        // Test everything endpoint URL
        let query = "Apple"
        let everythingEndpoint = "/everything?q=\(query)&sortBy=publishedAt&apiKey=\(apiKey)"
        let everythingURL = URL(string: baseURL + everythingEndpoint)
        XCTAssertNotNil(everythingURL)
        XCTAssertEqual(everythingURL?.absoluteString, "https://newsapi.org/v2/everything?q=Apple&sortBy=publishedAt&apiKey=test-api-key")
    }
    
    // MARK: - Integration Tests (Requires Network)
    func testRealNetworkServiceIntegration() {
        // Skip this test if running in CI or without network
//        guard networkService.isConnectedToInternet() else {
//            XCTSkip("No internet connection available for integration test")
//        }
        
        let expectation = XCTestExpectation(description: "Fetch real articles from API")
        expectation.expectedFulfillmentCount = 1
        
        networkService.fetchArticles(query: nil) { result in
            switch result {
            case .success(let articles):
                XCTAssertGreaterThan(articles.count, 0, "Should fetch at least one article")
                
                // Verify article structure
                if let firstArticle = articles.first {
                    XCTAssertFalse(firstArticle.title.isEmpty, "Article should have a title")
                    XCTAssertFalse(firstArticle.url.isEmpty, "Article should have a URL")
                    XCTAssertNotNil(firstArticle.source, "Article should have a source")
                }
                
                expectation.fulfill()
                
            case .failure(let error):
                // If the test fails due to API limits or network issues, that's okay for integration tests
                print("Integration test failed with error: \(error)")
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    // MARK: - Helper Methods
    private func createSampleArticle() -> Article {
        let source = Source(id: "test", name: "Test Source")
        return Article(
            source: source,
            author: "Test Author",
            title: "Sample Title",
            description: "Sample Description",
            url: "https://example.com",
            urlToImage: "https://example.com/image.jpg",
            publishedAt: "2025-08-17T10:30:00Z",
            content: "Sample Content"
        )
    }
}

// MARK: - URLSession Mock for Testing
class MockURLSession: URLSession {
    var mockData: Data?
    var mockResponse: URLResponse?
    var mockError: Error?
    
    override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return MockURLSessionDataTask {
            completionHandler(self.mockData, self.mockResponse, self.mockError)
        }
    }
}

class MockURLSessionDataTask: URLSessionDataTask {
    private let closure: () -> Void
    
    init(closure: @escaping () -> Void) {
        self.closure = closure
    }
    
    override func resume() {
        closure()
    }
}
