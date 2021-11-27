//
//  ValidateCacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Muhammed Azharudheen on 26/11/2021.
//  Copyright © 2021 Nagarro. All rights reserved.
//

import XCTest
import EssentialFeed

class ValidatedCacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_validates_deleteCacheOnRetrievalError() {
        let (sut, store) = makeSUT()
        sut.validateCache()
        store.completeRetrieval(with: anyNSError())
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCacheFeed])
    }
    
    func test_validates_doesNotDeleteEmptyCache() {
        let (sut, store) = makeSUT()
        sut.load { _ in }
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_validate_hasNoSideEffectOnNonExpiredCache() {
        let feed = uniqueImageFeed()
        let curentDate = Date()
        let nonExpirationTimestamp = curentDate.minusFeedMaxCacheAge().adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { curentDate })
        
        sut.validateCache()
        store.completeRetrieval(with: feed.locals, timestamp: nonExpirationTimestamp)

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_validate_deltesCacheOnExpiredCache() {
        let feed = uniqueImageFeed()
        let curentDate = Date()
        let expirationTimeStamp = curentDate.minusFeedMaxCacheAge()
        let (sut, store) = makeSUT(currentDate: { curentDate })
        
        sut.validateCache()
        store.completeRetrieval(with: feed.locals, timestamp: expirationTimeStamp)

        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCacheFeed])
    }
    
    func test_validate_hasNoSideEffectsMoreThanExpiredCache() {
        let feed = uniqueImageFeed()
        let curentDate = Date()
        let expirationTimeStamp = curentDate.minusFeedMaxCacheAge().adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { curentDate })
        
        sut.validateCache()
        store.completeRetrieval(with: feed.locals, timestamp: expirationTimeStamp)

        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCacheFeed])
    }
    
    func test_validate_doesNotDeleteInvalidCacheAfterSUTInstanceHasBeenDeallocated() {
        
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        sut?.validateCache()
        sut = nil
        store.completeRetrieval(with: anyNSError())
    }
    
    
    // MARK: - Helpers
    private func makeSUT(currentDate: @escaping (() -> Date) = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemmoryLeaks(store, file: file, line: line)
        trackForMemmoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
}
