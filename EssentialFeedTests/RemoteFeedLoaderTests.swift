
import XCTest

class RemoteFeedLoader {
    
    let url: URL
    let client: HTTPClient
    
    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    func load() {
        client.get(from: url)
    }
}

protocol HTTPClient {
    func get(from url: URL)
}

class HTTPClientSpy: HTTPClient {
    
    var requestedURL: URL?
    
    func get(from url: URL) {
        requestedURL = url
    }
}

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        
        let client = HTTPClientSpy()
        _ = RemoteFeedLoader(url: URL(string: "https://a-url.com")!, client: client)
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL() {
        
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: URL(string: "https://a-url.com")!, client: client)
        sut.load()
        
        XCTAssertEqual(client.requestedURL, URL(string: "https://a-url.com"))
    }
}
