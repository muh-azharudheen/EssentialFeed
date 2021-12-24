//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Muhammed Azharudheen on 24/12/2021.
//  Copyright © 2021 Nagarro. All rights reserved.
//

import Foundation

public final class CoreDataFeedStore: FeedStore {
    
    public init() { }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }
    
    public func insert(_ feed: [LocalFeedImage], timeStamp: Date, completion: @escaping InsertionCompletion) {
        
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        
    }
}
