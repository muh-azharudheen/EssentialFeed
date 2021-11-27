//
//  FeedCacheTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Muhammed Azharudheen on 26/11/2021.
//  Copyright © 2021 Nagarro. All rights reserved.
//

import Foundation
import EssentialFeed

func anyURL() -> URL {
    URL(string: "http://any-url.com")!
}

func uniqueImageFeed() -> (models: [FeedImage], locals: [LocalFeedImage]) {
    let models = [uniqueImage(), uniqueImage()]
    let locals = models.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    return (models, locals)
}

func uniqueImage() -> FeedImage {
    FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())
}

extension Date {
    
    func minusFeedMaxCacheAge() -> Date {
        adding(days:  -feedMaxCacheAgeInDays)
    }
    
    private var feedMaxCacheAgeInDays: Int { 7 }
    
    private func adding(days: Int) -> Date {
        Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
}

extension Date {
    func adding(seconds: TimeInterval) -> Date {
        self + seconds
    }
}
