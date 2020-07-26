
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
        sut.load() { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURL() {
        
        let url = URL(string: "https://a-url.com")!
        let (sut, client) = makeSUT()
        sut.load() { _ in }
        sut.load() { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        var capturedErrors = [RemoteFeedLoader.Error]()
        let (sut, client) = makeSUT()
        
        sut.load() { capturedErrors.append($0) }
        client.complete(with: NSError(domain: "test", code: 0))
        
        XCTAssertEqual(capturedErrors, [.connectivity])
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500, 600]
        samples.enumerated().forEach() {
            
            var capturedErrors = [RemoteFeedLoader.Error]()
            sut.load(completion: { capturedErrors.append($0) })
            
            client.complete(withStatusCode: $0.element, at: $0.offset)
            
            XCTAssertEqual(capturedErrors, [.invalidData])
            
        }
    }
    
    func test_load_deliversErrorOnNon200HTTPResponseWithInvalidJson() {
        let (sut, client) = makeSUT()
        var capturedErrors = [RemoteFeedLoader.Error]()
        sut.load() { capturedErrors.append($0) }
        let invalidJson = Data("invalid json".utf8)
        client.complete(withStatusCode: 200, data: invalidJson)
        
        XCTAssertEqual(capturedErrors, [.invalidData])
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
        
        private var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()

        var requestedURLs: [URL] {
            messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index], statusCode: code, httpVersion: nil, headerFields: nil)!
            messages[index].completion(.success(data, response))
        }
    }
}
