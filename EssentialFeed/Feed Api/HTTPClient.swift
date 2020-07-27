//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Muhammed Azharudheen on 27/07/2020.
//  Copyright © 2020 Nagarro. All rights reserved.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
