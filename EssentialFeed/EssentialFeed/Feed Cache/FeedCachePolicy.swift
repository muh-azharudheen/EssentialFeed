//
//  FeedCachePolicy.swift
//  EssentialFeed
//
//  Created by Muhammed Azharudheen on 27/11/2021.
//  Copyright © 2021 Nagarro. All rights reserved.
//

import Foundation

internal final class FeedCachePolicy {
    
    private init() {}
    
    static private let calendar = Calendar(identifier: .gregorian)
        
    private static var maxCacheAgeInDays: Int { 7 }
    
    static func validates(timestamp: Date, againist date: Date) -> Bool {
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else { return false }
        return date < maxCacheAge
    }
}
