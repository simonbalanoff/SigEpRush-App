//
//  ImageCache.swift
//  SigEpRush-App
//
//  Image caching system to avoid redundant network calls
//

import UIKit
import SwiftUI

actor ImageCache {
    static let shared = ImageCache()
    
    private var cache: [String: UIImage] = [:]
    private var inProgress: [String: Task<UIImage?, Error>] = [:]
    
    private init() {}
    
    func get(_ key: String) -> UIImage? {
        return cache[key]
    }
    
    func set(_ key: String, image: UIImage) {
        cache[key]
        cache[key] = image
    }
    
    func fetch(url: URL) async throws -> UIImage? {
        let key = url.absoluteString
        
        if let cached = cache[key] {
            return cached
        }
        
        if let task = inProgress[key] {
            return try await task.value
        }
        
        let task = Task<UIImage?, Error> {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: data) else {
                throw URLError(.cannotDecodeContentData)
            }
            return image
        }
        
        inProgress[key] = task
        
        do {
            let image = try await task.value
            if let image = image {
                cache[key] = image
            }
            inProgress[key] = nil
            return image
        } catch {
            inProgress[key] = nil
            throw error
        }
    }
    
    func clear() {
        cache.removeAll()
        inProgress.values.forEach { $0.cancel() }
        inProgress.removeAll()
    }
    
    func clearImage(_ key: String) {
        cache.removeValue(forKey: key)
    }
}
