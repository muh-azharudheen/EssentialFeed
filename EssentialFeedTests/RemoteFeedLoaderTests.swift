
import XCTest
import EssentialFeed

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        
        let url = URL(string: "https://a-url.com")!
        let (sut, client) = makeSUT()
        sut.load()
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURL() {
        
        let url = URL(string: "https://a-url.com")!
        let (sut, client) = makeSUT()
        sut.load()
        sut.load()
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
}

// MARK: Helpers
private extension RemoteFeedLoaderTests {
    func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        return (RemoteFeedLoader(url: url, client: client), client)
    }
}

private extension RemoteFeedLoaderTests {
    class HTTPClientSpy: HTTPClient {
        
        var requestedURLs = [URL]()
        
        func get(from url: URL) {            requestedURLs.append(url)
        }
    }
}
