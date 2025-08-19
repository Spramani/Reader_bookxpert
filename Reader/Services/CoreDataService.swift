//
//  CoreDataService.swift
//  Reader
//
//  Created by SHUBHAM on 17/08/25.
//

import Foundation
import CoreData

// MARK: - Core Data Service Protocol
protocol CoreDataServiceProtocol {
    func saveArticles(_ articles: [Article])
    func fetchCachedArticles() -> [Article]
    func searchCachedArticles(query: String) -> [Article]
    func saveBookmark(_ article: Article)
    func removeBookmark(_ article: Article)
    func fetchBookmarkedArticles() -> [Article]
    func isArticleBookmarked(_ article: Article) -> Bool
}

// MARK: - Core Data Service Implementation
class CoreDataService: CoreDataServiceProtocol {
    static let shared = CoreDataService()
    
    private init() {}
    
    // MARK: - Core Data Stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ReaderDataModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data error: \(error)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - Save Context
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save context: \(error)")
            }
        }
    }
    
    // MARK: - Articles Management
    func saveArticles(_ articles: [Article]) {
        // Clear existing cached articles
        clearCachedArticles()
        
        for article in articles {
            let cachedArticle = CachedArticle(context: context)
            cachedArticle.title = article.title
            cachedArticle.articleDescription = article.description
            cachedArticle.author = article.author
            cachedArticle.url = article.url
            cachedArticle.urlToImage = article.urlToImage
            cachedArticle.publishedAt = article.publishedAt
            cachedArticle.content = article.content
            cachedArticle.sourceName = article.source?.name
            cachedArticle.sourceId = article.source?.id
            cachedArticle.cachedDate = Date()
        }
        
        saveContext()
    }
    
    func fetchCachedArticles() -> [Article] {
        let request: NSFetchRequest<CachedArticle> = CachedArticle.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "cachedDate", ascending: false)]
        
        do {
            let cachedArticles = try context.fetch(request)
            return cachedArticles.compactMap { $0.toArticle() }
        } catch {
            print("Failed to fetch cached articles: \(error)")
            return []
        }
    }
    
    func searchCachedArticles(query: String) -> [Article] {
        let request: NSFetchRequest<CachedArticle> = CachedArticle.fetchRequest()
        request.predicate = NSPredicate(format: "title CONTAINS[cd] %@ OR articleDescription CONTAINS[cd] %@", query, query)
        request.sortDescriptors = [NSSortDescriptor(key: "cachedDate", ascending: false)]
        
        do {
            let cachedArticles = try context.fetch(request)
            return cachedArticles.compactMap { $0.toArticle() }
        } catch {
            print("Failed to search cached articles: \(error)")
            return []
        }
    }
    
    private func clearCachedArticles() {
        let request: NSFetchRequest<NSFetchRequestResult> = CachedArticle.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        
        do {
            try context.execute(deleteRequest)
        } catch {
            print("Failed to clear cached articles: \(error)")
        }
    }
    
    // MARK: - Bookmarks Management
    func saveBookmark(_ article: Article) {
        // Check if already bookmarked
        if isArticleBookmarked(article) {
            return
        }
        
        let bookmark = BookmarkedArticle(context: context)
        bookmark.title = article.title
        bookmark.articleDescription = article.description
        bookmark.author = article.author
        bookmark.url = article.url
        bookmark.urlToImage = article.urlToImage
        bookmark.publishedAt = article.publishedAt
        bookmark.content = article.content
        bookmark.sourceName = article.source?.name
        bookmark.sourceId = article.source?.id
        bookmark.bookmarkedDate = Date()
        
        saveContext()
    }
    
    func removeBookmark(_ article: Article) {
        let request: NSFetchRequest<BookmarkedArticle> = BookmarkedArticle.fetchRequest()
        request.predicate = NSPredicate(format: "url == %@", article.url)
        
        do {
            let bookmarks = try context.fetch(request)
            for bookmark in bookmarks {
                context.delete(bookmark)
            }
            saveContext()
        } catch {
            print("Failed to remove bookmark: \(error)")
        }
    }
    
    func fetchBookmarkedArticles() -> [Article] {
        let request: NSFetchRequest<BookmarkedArticle> = BookmarkedArticle.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "bookmarkedDate", ascending: false)]
        
        do {
            let bookmarks = try context.fetch(request)
            return bookmarks.compactMap { $0.toArticle() }
        } catch {
            print("Failed to fetch bookmarked articles: \(error)")
            return []
        }
    }
    
    func isArticleBookmarked(_ article: Article) -> Bool {
        let request: NSFetchRequest<BookmarkedArticle> = BookmarkedArticle.fetchRequest()
        request.predicate = NSPredicate(format: "url == %@", article.url)
        
        do {
            let count = try context.count(for: request)
            return count > 0
        } catch {
            print("Failed to check bookmark status: \(error)")
            return false
        }
    }
}

// MARK: - Core Data Extensions
extension CachedArticle {
    func toArticle() -> Article? {
        guard let title = title,
              let url = url,
              let publishedAt = publishedAt else {
            return nil
        }
        
        let source = Source(id: sourceId, name: sourceName ?? "Unknown")
        
        return Article(
            source: source,
            author: author,
            title: title,
            description: articleDescription,
            url: url,
            urlToImage: urlToImage,
            publishedAt: publishedAt,
            content: content
        )
    }
}

extension BookmarkedArticle {
    func toArticle() -> Article? {
        guard let title = title,
              let url = url,
              let publishedAt = publishedAt else {
            return nil
        }
        
        let source = Source(id: sourceId, name: sourceName ?? "Unknown")
        
        return Article(
            source: source,
            author: author,
            title: title,
            description: articleDescription,
            url: url,
            urlToImage: urlToImage,
            publishedAt: publishedAt,
            content: content
        )
    }
}
