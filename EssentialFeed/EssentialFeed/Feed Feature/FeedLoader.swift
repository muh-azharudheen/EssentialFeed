
//  Created by Muhammed Azharudheen on 07/07/2020.

import Foundation

public protocol FeedLoader {
    
    typealias Result = Swift.Result<[FeedImage], Error>
    
    func load(completion: @escaping (Result) -> Void)
}
