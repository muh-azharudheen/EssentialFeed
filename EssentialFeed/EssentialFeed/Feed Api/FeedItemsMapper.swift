//
//  Created by Muhammed Azharudheen on 27/07/2020.

import Foundation

internal class FeedItemsMapper {
    
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }
    
    private static var OK_200: Int { 200 }
    
    internal static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard response.statusCode == OK_200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteFeedLoader.Error.invalidData
        }
        return root.items
    }
}
