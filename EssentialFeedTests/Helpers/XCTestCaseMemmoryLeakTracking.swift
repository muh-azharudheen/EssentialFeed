//
//  XCTestCaseMemmoryLeakTracking.swift
//  EssentialFeedTests
//
//  Created by Muhammed Azharudheen on 31/08/2020.
//  Copyright © 2020 Nagarro. All rights reserved.
//

import XCTest

extension XCTestCase {
    func trackForMemmoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated, Potential memmory leak", file: file, line: line)
        }
    }
}
