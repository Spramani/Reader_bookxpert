//
//  Article.swift
//  Reader
//
//  Created by SHUBHAM on 17/08/25.
//

import Foundation

// MARK: - Article Model
struct Article: Codable, Identifiable {
    let id = UUID()
    let source: Source?
    let author: String?
    let title: String
    let description: String?
    let url: String
    let urlToImage: String?
    let publishedAt: String
    let content: String?
    
    private enum CodingKeys: String, CodingKey {
        case source, author, title, description, url, urlToImage, publishedAt, content
    }
}

// MARK: - Source Model
struct Source: Codable {
    let id: String?
    let name: String
}

// MARK: - News API Response
struct NewsResponse: Codable {
    let status: String
    let totalResults: Int
    let articles: [Article]
}

// MARK: - Article Extensions
extension Article {
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        if let date = formatter.date(from: publishedAt) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }
        
        return publishedAt
    }
    
    var displayTitle: String {
        return title.isEmpty ? "No Title" : title
    }
    
    var displayDescription: String {
        return description ?? "No description available"
    }
    
    var displayAuthor: String {
        return author ?? source?.name ?? "Unknown"
    }
}
