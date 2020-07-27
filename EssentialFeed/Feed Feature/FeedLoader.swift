//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Muhammed Azharudheen on 07/07/2020.
//  Copyright © 2020 Nagarro. All rights reserved.
//

import Foundation

public enum LoadFeedResult<Error: Swift.Error> {
    case success([FeedItem])
    case failure(Error)
}

protocol FeedLoader {
    associatedtype Error: Swift.Error
    
    func load(completion: @escaping (LoadFeedResult<Error>) -> Void)
}
