//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Muhammed Azharudheen on 24/11/2021.
//  Copyright © 2021 Nagarro. All rights reserved.
//

import Foundation

struct RemoteFeedItem: Decodable {
    let id: UUID
    let description: String?
    let location: String?
    let image: URL
}
