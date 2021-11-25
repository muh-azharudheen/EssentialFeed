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
        let exp = expectation(description: "wait for load completion")
        var receivedError: Error?
        sut.load() { result in
            switch result {
            case .failure(let error):
                receivedError = error
            default:
                XCTFail("Expected failure, Received \(result) instead")
            }
            exp.fulfill()
        }
        store.completeRetrieval(with:  retrievalError)
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(receivedError as NSError?, retrievalError)
    }

    func test_load_deliversNoImagesOnEmptyCache() {
        let (sut, store) = makeSUT()
        let exp = expectation(description: "wait for load completion")
        var receivedImages: [FeedImage]?
        sut.load() { result in
            switch result {
            case .success(let images):
                receivedImages = images
            default:
                XCTFail("Expected Success, Received \(result) instead")
            }
            exp.fulfill()
        }
        
        store.completeRetrievalWithEmptyCache()
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(receivedImages, [])
    }
    
    // MARK: - Helpers
    private func makeSUT(currentDate: Date = Date(), file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: { currentDate })
        trackForMemmoryLeaks(store, file: file, line: line)
        trackForMemmoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func anyNSError() -> NSError {
        NSError(domain: "any error", code: 0)
    }
}
