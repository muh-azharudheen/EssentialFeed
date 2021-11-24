//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Muhammed Azharudheen on 24/11/2021.
//  Copyright © 2021 Nagarro. All rights reserved.
//

import Foundation

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void

    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insertItems(items: [FeedItem], timeStamp: Date, completion: @escaping InsertionCompletion)
}
