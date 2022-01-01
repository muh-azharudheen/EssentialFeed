//
//  EssentialFeedCacheIntegrationTest.swift
//  EssentialFeedCacheIntegrationTest
//
//  Created by Muhammed Azharudheen on 01/01/2022.
//  Copyright © 2022 Nagarro. All rights reserved.
//

import XCTest
import EssentialFeed

class EssentialFeedCacheIntegrationTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        undoStoreSideEffects()
    }
    
    func test_load_deliversNoItemsOnEmptyCache() {
        let sut = makeSUT()
        expect(sut, toLoad: [])
    }
    
    func test_load_delivers_itemsSavedOnSeperateInstance() {
        
        let sutToPerformSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        
        let feed = uniqueImageFeed().models
        
        save(feed, sutToPerformSave)
        expect(sutToPerformLoad, toLoad: feed)
    }
    
    func test_save_overridesItemsSavedOnASeperateInstance() {
        let sutToPerformFirstSave = makeSUT()
        let sutToPerformLastSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        
        let firstFeed = uniqueImageFeed().models
        let latestFeed = uniqueImageFeed().models
        
        save(firstFeed, sutToPerformFirstSave)
        save(latestFeed, sutToPerformLastSave)
                
        expect(sutToPerformLoad, toLoad: latestFeed)
    }
    
    // MARK: Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> LocalFeedLoader {
        let storeBunde = Bundle(for: CoreDataFeedStore.self)
        let storeURL = testSpecificStoreURL()
        let store = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBunde)
        let sut = LocalFeedLoader(store: store, currentDate: Date.init)
        trackForMemmoryLeaks(store, file: file, line: line)
        trackForMemmoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func expect(_ sut: LocalFeedLoader, toLoad expectedFeed: [FeedImage], file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Waiting for load completion")
        sut.load { result in
            switch result {
            case let .success(imageFeed):
                XCTAssertEqual(imageFeed, expectedFeed, file: file, line: line)
            case let .failure(error):
                XCTFail("Expected successful feed result, got \(error) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    private func save(_ feed: [FeedImage], _ sut: LocalFeedLoader) {
        let saveExp = expectation(description: "Waiting for save to complete")
        sut.save(feed) { saveError in
            XCTAssertNil(saveError, "Expected to save feed succesfully")
            saveExp.fulfill()
        }
        wait(for: [saveExp], timeout: 1.0)
    }
    
    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }
    
    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }

    private func testSpecificStoreURL() -> URL {
        cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cachesDirectory() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
}
