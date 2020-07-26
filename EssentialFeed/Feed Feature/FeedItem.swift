//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Muhammed Azharudheen on 07/07/2020.
//  Copyright © 2020 Nagarro. All rights reserved.
//

import Foundation

public struct FeedItem {
    let id: String
    let description: String?
    let location: String?
    let imageURL: URL
}

extension FeedItem: Equatable { }
