//
//  LocalFeedItem.swift
//  EssentialFeed
//
//  Created by Muhammed Azharudheen on 24/11/2021.
//  Copyright © 2021 Nagarro. All rights reserved.
//

import Foundation

public struct LocalFeedItem {
    public let id: UUID
    public let description: String?
    public let location: String?
    public let imageURL: URL
    
    public init(id: UUID, description: String?, location: String?, imageURL: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.imageURL = imageURL
    }
}

extension LocalFeedItem: Equatable { }
