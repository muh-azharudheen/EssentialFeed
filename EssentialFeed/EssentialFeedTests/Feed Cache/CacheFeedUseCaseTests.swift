//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Muhammed Azharudheen on 21/11/2021.
//  Copyright © 2021 Nagarro. All rights reserved.
//

import XCTest

class LocalFeedLoader {
    
    init(store: FeedStore) {
        
    }
}

class FeedStore {
    var deleteCacheFeedCallCount = 0
}
class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation() {
        let store = FeedStore()
        _ = LocalFeedLoader(store: store)
        XCTAssertEqual(store.deleteCacheFeedCallCount, 0)
    }
}

