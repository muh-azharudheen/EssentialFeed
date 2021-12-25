//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Muhammed Azharudheen on 24/12/2021.
//  Copyright © 2021 Nagarro. All rights reserved.
//

import CoreData

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

private class ManagedCache: NSManagedObject {
     @NSManaged var timestamp: Date
     @NSManaged var feed: NSOrderedSet
 }

 private class ManagedFeedImage: NSManagedObject {
     @NSManaged var id: UUID
     @NSManaged var imageDescription: String?
     @NSManaged var location: String?
     @NSManaged var url: URL
     @NSManaged var cache: ManagedCache
 }
