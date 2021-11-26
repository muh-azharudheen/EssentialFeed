//
//  LoadFeedFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Muhammed Azharudheen on 25/11/2021.
//  Copyright © 2021 Nagarro. All rights reserved.
//

import XCTest
import EssentialFeed

class LoadFeedFromCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_load_requestCacheRetrieval() {
        
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_failsOnRetreivalError() {
        let (sut, store) = makeSUT()
        let retrievalError = anyNSError()

        expect(sut: sut, toCompleteWith: .failure(retrievalError), when: {
            store.completeRetrieval(with: retrievalError)
        })
    }

    func test_load_deliversNoImagesOnEmptyCache() {
        let (sut, store) = makeSUT()

        expect(sut: sut, toCompleteWith: .success([]), when: {
            store.completeRetrievalWithEmptyCache()
        })
    }
    
    func test_load_deliversCachedImagesOnLessThanSevenDaysOldCache() {
        let feed = uniqueImageFeed()
        let curentDate = Date()
        let lessThanSevenDaysOldTimeStamp = curentDate.adding(days: -7).adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { curentDate })
        
        expect(sut: sut, toCompleteWith: .success(feed.models)) {
            store.completeRetrieval(with: feed.locals, timestamp: lessThanSevenDaysOldTimeStamp)
        }
    }
    
    func test_load_deliversNoImagesOnSevenDaysOldCache() {
        let feed = uniqueImageFeed()
        let curentDate = Date()
        let sevenDaysOldTimeStamp = curentDate.adding(days: -7)
        let (sut, store) = makeSUT(currentDate: { curentDate })
        
        expect(sut: sut, toCompleteWith: .success([])) {
            store.completeRetrieval(with: feed.locals, timestamp: sevenDaysOldTimeStamp)
        }
    }
    
    func test_load_deliversNoImagesOnMoreThanSevenDaysOldCache() {
        let feed = uniqueImageFeed()
        let curentDate = Date()
        let moreThanSevenDaysOldTimeStamp = curentDate.adding(days: -7).adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { curentDate })
        
        expect(sut: sut, toCompleteWith: .success([])) {
            store.completeRetrieval(with: feed.locals, timestamp: moreThanSevenDaysOldTimeStamp)
        }
    }
    
    func test_load_hasNoSideEffectOnRetrievalError() {
        let (sut, store) = makeSUT()
        sut.load { _ in }
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_doesNotDeleteCacheOnEmptyCache() {
        let (sut, store) = makeSUT()
        sut.load { _ in }
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_doesNotDeleteCacheOnLessThanSevenDaysOldCache() {
        let feed = uniqueImageFeed()
        let curentDate = Date()
        let lessThanSevenDaysOldTimeStamp = curentDate.adding(days: -7).adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { curentDate })
        
        sut.load { _ in }
        store.completeRetrieval(with: feed.locals, timestamp: lessThanSevenDaysOldTimeStamp)

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_DeleteCacheSevenDaysOldCache() {
        let feed = uniqueImageFeed()
        let curentDate = Date()
        let sevenDaysOldTimeStamp = curentDate.adding(days: -7)
        let (sut, store) = makeSUT(currentDate: { curentDate })
        
        sut.load { _ in }
        store.completeRetrieval(with: feed.locals, timestamp: sevenDaysOldTimeStamp)

        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCacheFeed])
    }
    
    func test_load_DeleteCacheMoreThanSevenDaysOldCache() {
        let feed = uniqueImageFeed()
        let curentDate = Date()
        let moreThanSevenDaysOldCache = curentDate.adding(days: -7).adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { curentDate })
        
        sut.load { _ in }
        store.completeRetrieval(with: feed.locals, timestamp: moreThanSevenDaysOldCache)

        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCacheFeed])
    }
    
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        var receivedMessages = [LoadFeedResult]()
        sut?.load { receivedMessages.append($0) }
        sut = nil
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertTrue(receivedMessages.isEmpty)
    }
    
    // MARK: - Helpers
    private func makeSUT(currentDate: @escaping (() -> Date) = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemmoryLeaks(store, file: file, line: line)
        trackForMemmoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func expect(sut: LocalFeedLoader, toCompleteWith expectedResult: LoadFeedResult, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Waiting for expectation")
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case (.success(let receivedImages), .success(let expectedImages)):
                XCTAssertEqual(receivedImages, expectedImages, file: file, line: line)
            case (.failure(let receivedError as NSError), .failure(let expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1)
    }
    
    private func anyNSError() -> NSError {
        NSError(domain: "any error", code: 0)
    }
    
    private func anyURL() -> URL {
        URL(string: "http://any-url.com")!
    }
    
    private func uniqueImageFeed() -> (models: [FeedImage], locals: [LocalFeedImage]) {
        let models = [uniqueImage(), uniqueImage()]
        let locals = models.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
        return (models, locals)
    }
    
    private func uniqueImage() -> FeedImage {
        FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())
    }
}

private extension Date {
    
    func adding(days: Int) -> Date {
        Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(seconds: TimeInterval) -> Date {
        self + seconds
    }
}
