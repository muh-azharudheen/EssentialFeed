//
//  FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Muhammed Azharudheen on 24/12/2021.
//  Copyright © 2021 Nagarro. All rights reserved.
//

import Foundation

protocol FeedStoreSpecs {
    
    func test_retrieve_deliversEmptyOnEmptyCache()
    func test_retrieve_hasNoSideEffectsOnEmptyCache()
    func test_retrieve_deliversFoundValuesOnNonEmptyCache()
    func test_retrievehasNoSideEffectsOnNonEmptyCache()

    func test_insert_deliversNoErrorOnEmptyCache()
    func test_insert_overridesPreviouslyInsertedCacheValues()
    
    func test_delete_hasNoSideEffectsOnEmptyCache()
    func test_delete_deliversNoErrorOnNonEmptyCache()
    func test_delete_emptiesPreviouslyInsertedCache()

    func test_storeSideEffectsRunSerially()
}

protocol FailableRetrieveFeedStoreSpecs: FeedStoreSpecs {
     func test_retrieve_deliversFailureOnRetrievalError()
     func test_retrieve_hasNoSideEffectsOnFailure()
 }

 protocol FailableInsertFeedStoreSpecs: FeedStoreSpecs {
     func test_insert_deliversErrorOnInsertionError()
     func test_insert_hasNoSideEffectsOnInsertionError()
 }

 protocol FailableDeleteFeedStoreSpecs: FeedStoreSpecs {
     func test_delete_deliversErrorOnDeletionError()
     func test_delete_hasNoSideEffectsOnDeletionError()
 }

typealias FailableFeedStoreSpecs = FailableRetrieveFeedStoreSpecs & FailableInsertFeedStoreSpecs & FailableDeleteFeedStoreSpecs
