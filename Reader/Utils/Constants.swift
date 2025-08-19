//
//  Constants.swift
//  Reader
//
//  Created by SHUBHAM on 17/08/25.
//

import Foundation

struct Constants {
    
    // MARK: - API Configuration
    struct API {
        static let baseURL = "https://newsapi.org/v2"
        static let apiKey = "d10a282284414326b9ae589b349e2c82" // Replace with your actual NewsAPI key from newsapi.org
        
        // Endpoints
        static let topHeadlines = "/top-headlines"
        static let everything = "/everything"
        
        // Parameters
        static let defaultCountry = "us"
        static let defaultPageSize = 20
    }
    
    // MARK: - UI Constants
    struct UI {
        static let cornerRadius: CGFloat = 8.0
        static let defaultPadding: CGFloat = 16.0
        static let smallPadding: CGFloat = 8.0
        static let imageSize: CGFloat = 80.0
        static let buttonSize: CGFloat = 30.0
    }
    
    // MARK: - Cache Configuration
    struct Cache {
        static let maxCacheAge: TimeInterval = 24 * 60 * 60 // 24 hours
        static let maxCachedArticles = 100
    }
    
    // MARK: - Error Messages
    struct ErrorMessages {
        static let noInternet = "No internet connection. Showing cached articles."
        static let noData = "No articles available."
        static let loadingFailed = "Failed to load articles. Please try again."
        static let bookmarkFailed = "Failed to bookmark article."
    }
}
