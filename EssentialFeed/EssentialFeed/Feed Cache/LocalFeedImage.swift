//
//  LocalFeedItem.swift
//  EssentialFeed
//
//  Created by Muhammed Azharudheen on 24/11/2021.
//  Copyright © 2021 Nagarro. All rights reserved.
//

import Foundation

public struct LocalFeedImage {
    public let id: UUID
    public let description: String?
    public let location: String?
    public let url: URL
    
    public init(id: UUID, description: String?, location: String?, url: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.url = url
    }
}

extension LocalFeedImage: Equatable { }
