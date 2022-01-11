//
//  URLSessionHTTPClient.swift
//  EssentialFeed
//
//  Created by Muhammed Azharudheen on 24/07/2021.
//  Copyright © 2021 Nagarro. All rights reserved.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {
    
    private var session: URLSession
    
    public init(session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    private struct UnexpectedValuesReperesentation: Error { }
    
    
    public func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
        session.dataTask(with: url) { data, response, error in
            
            completion(Result {
                if let err = error {
                    throw err
                } else if let data = data, let response = response as? HTTPURLResponse {
                    return (data, response)
                } else {
                    throw UnexpectedValuesReperesentation()
                }
            })
        }.resume()
    }
}
