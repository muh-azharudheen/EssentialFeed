//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Muhammed Azharudheen on 21/11/2021.
//  Copyright © 2021 Nagarro. All rights reserved.
//

import XCTest
import EssentialFeed

class LocalFeedLoader {
    
    private let store: FeedStore
    
    init(store: FeedStore) {
        self.store = store
    }
    
    func save(_ items: [FeedItem]) {
        store.deleteCachedFeed { [unowned self] error in
            if error == nil {
                self.store.insertItems(items: items)
            }
        }
    }
}

class FeedStore {
    
    typealias DeletionCompletion = (Error?) -> Void
    
    private var deletionCompletion = [DeletionCompletion]()
    
    var deleteCacheFeedCallCount = 0
    var insertCallCount = 0
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        deleteCacheFeedCallCount += 1
        deletionCompletion.append(completion)
    }
    
    func insertItems(items: [FeedItem]) {
        insertCallCount += 1
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletion[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletion[index](nil)
    }
}
class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.deleteCacheFeedCallCount, 0)
    }
    
    func test_save_requestCacheDeletion() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        sut.save(items)
        XCTAssertEqual(store.deleteCacheFeedCallCount, 1)
    }
    
    func test_save_doesNotRequestCacheDeletionOnInsertionError() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        sut.save(items)
        let deletionError = anyNSError()
        store.completeDeletion(with: deletionError)
        XCTAssertEqual(store.insertCallCount, 0)
    }
    
    func test_save_requestsNewCacheInsertionOnSuccesfullDeletion() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        sut.save(items)
        store.completeDeletionSuccessfully()
        XCTAssertEqual(store.insertCallCount, 1)
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        trackForMemmoryLeaks(store, file: file, line: line)
        trackForMemmoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func uniqueItem() -> FeedItem {
        FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
    }
    
    private func anyURL() -> URL {
        URL(string: "http://any-url.com")!
    }
    
    private func anyNSError() -> NSError {
        NSError(domain: "any error", code: 0)
    }
}
