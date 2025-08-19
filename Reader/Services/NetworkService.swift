//
//  NetworkService.swift
//  Reader
//
//  Created by SHUBHAM on 17/08/25.
//

import Foundation
import Network

// MARK: - Network Service Protocol
protocol NetworkServiceProtocol {
    func fetchArticles(query: String?, completion: @escaping (Result<[Article], NetworkError>) -> Void)
    func isConnectedToInternet() -> Bool
}

// MARK: - Network Error
enum NetworkError: Error, LocalizedError, Equatable {
    case noInternetConnection
    case invalidURL
    case noData
    case decodingError
    case serverError(Int)
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .noInternetConnection:
            return "No internet connection available"
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError:
            return "Failed to decode response"
        case .serverError(let code):
            return "Server error with code: \(code)"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}

// MARK: - Network Service Implementation
class NetworkService: NetworkServiceProtocol {
    static let shared = NetworkService()
    
    private let baseURL = "https://newsapi.org/v2"
    private let apiKey = "d10a282284414326b9ae589b349e2c82" // Replace with your actual NewsAPI key from newsapi.org
    private let session = URLSession.shared
    private let monitor = NWPathMonitor()
    private var isConnected = false
    
    private init() {
        startNetworkMonitoring()
    }
    
    deinit {
        monitor.cancel()
    }
    
    // MARK: - Network Monitoring
    private func startNetworkMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status == .satisfied
        }
        
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
    }
    
    func isConnectedToInternet() -> Bool {
        return isConnected
    }
    
    // MARK: - Fetch Articles
    func fetchArticles(query: String? = nil, completion: @escaping (Result<[Article], NetworkError>) -> Void) {
        guard isConnectedToInternet() else {
            completion(.failure(.noInternetConnection))
            return
        }
        
        let endpoint: String
        if let searchQuery = query, !searchQuery.isEmpty {
            endpoint = "/everything?q=\(searchQuery)&sortBy=publishedAt&apiKey=\(apiKey)"
        } else {
            endpoint = "/top-headlines?country=us&apiKey=\(apiKey)"
        }
        
        guard let url = URL(string: baseURL + endpoint) else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Network error: \(error.localizedDescription)")
                    completion(.failure(.unknown))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(.unknown))
                    return
                }
                
                guard httpResponse.statusCode == 200 else {
                    completion(.failure(.serverError(httpResponse.statusCode)))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(.noData))
                    return
                }
                
                do {
                    let newsResponse = try JSONDecoder().decode(NewsResponse.self, from: data)
                    completion(.success(newsResponse.articles))
                } catch {
                    print("Decoding error: \(error)")
                    completion(.failure(.decodingError))
                }
            }
        }.resume()
    }
}

// MARK: - Mock Network Service for Testing
class MockNetworkService: NetworkServiceProtocol {
    var shouldReturnError = false
    var mockArticles: [Article] = []
    
    func fetchArticles(query: String?, completion: @escaping (Result<[Article], NetworkError>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if self.shouldReturnError {
                completion(.failure(.noInternetConnection))
            } else {
                completion(.success(self.mockArticles))
            }
        }
    }
    
    func isConnectedToInternet() -> Bool {
        return !shouldReturnError
    }
}
