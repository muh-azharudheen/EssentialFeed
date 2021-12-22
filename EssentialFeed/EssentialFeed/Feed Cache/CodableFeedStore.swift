//
//  CodableFeedStore.swift
//  EssentialFeed
//
//  Created by Muhammed Azharudheen on 21/12/2021.
//  Copyright © 2021 Nagarro. All rights reserved.
//

import Foundation

public class CodableFeedStore: FeedStore {
    
    private struct CodableFeedImage: Codable {
        let id: UUID
        let description: String?
        let location: String?
        let url: URL
        
        init(_ image: LocalFeedImage) {
            id = image.id
            description = image.description
            location = image.location
            url = image.url
        }
        
        var local: LocalFeedImage {
            LocalFeedImage(id: id, description: description, location: location, url: url)
        }
    }
    
    private let queue = DispatchQueue(label: "\(CodableFeedStore.self)Queue", qos: .userInitiated)
    private let storeURL: URL
    
    public init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    private struct Cache: Codable {
        let feed: [CodableFeedImage]
        let timestamp: Date
        
        var localFeed: [LocalFeedImage] {
            feed.map { $0.local }
        }
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        let storeurl = storeURL
        queue.async {
            guard let data = try? Data(contentsOf: storeurl) else {
                return completion(.empty)
            }
            let decoder = JSONDecoder()
            do {
                let cache = try decoder.decode(Cache.self, from: data)
                completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func insert(_ feed: [LocalFeedImage], timeStamp: Date, completion: @escaping InsertionCompletion) {
        let storeurl = storeURL
        queue.async {
            do {
                let encoder = JSONEncoder()
                let feedCache = feed.map { CodableFeedImage($0) }
                let encoded = try! encoder.encode(Cache(feed: feedCache, timestamp: timeStamp))
                try encoded.write(to: storeurl)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        let storeurl = storeURL
        queue.async {
            guard FileManager.default.fileExists(atPath: storeurl.path) else {
                return completion(nil)
            }
            do {
                try FileManager.default.removeItem(at: storeurl)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
}
