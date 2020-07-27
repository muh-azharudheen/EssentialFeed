//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Muhammed Azharudheen on 07/07/2020.
//  Copyright © 2020 Nagarro. All rights reserved.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedItem])
    case failure(Error)
}

public protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
