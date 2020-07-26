
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
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWith: .failure(.connectivity), when: {
            client.complete(with: NSError(domain: "test", code: 0))
        })
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500, 600]
        samples.enumerated().forEach() { item in
            
            expect(sut, toCompleteWith: .failure(.invalidData), when: {
                client.complete(withStatusCode: item.element, at: item.offset)
            })
        }
    }
    
    func test_load_deliversErrorOnNon200HTTPResponseWithInvalidJson() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWith: .failure(.invalidData), when: {
            let invalidJson = Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJson)
        })
    }
    
    func test_load_deliversNoItemsOnHTTPResponseWithEmptyJsonList() {
        
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWith: .success([]), when: {
            let emptyListJson = Data("{\"items\":[]}".utf8)
            client.complete(withStatusCode: 200, data: emptyListJson)
        })
    }
    
    func test_load_deliversItemsOn200HTTPResponseWithJsonItems() {
        
        let item1 = FeedItem(id: UUID(),
                            description: nil,
                            location: nil,
                            imageURL: URL(string: "http://a-url.com")!)
        
        let item1Json = [
            "id": item1.id.uuidString,
            "image": item1.imageURL.absoluteString
            
        ]
        
        let item2 = FeedItem(id: UUID(),
                             description: "a description",
                             location: "a location",
                             imageURL: URL(string: "http://another-url.com")!)
        let item2Json = [
            "id": item2.id.uuidString,
            "description": item2.description,
            "location": item2.location,
            "image": item2.imageURL.absoluteString
        ]
        
        let itemsJson = [
            "items": [item1Json, item2Json]
        ]
        
        let (sut, client) = makeSUT()
        
        
        expect(sut, toCompleteWith: .success([item1, item2]), when: {

            let json = try! JSONSerialization.data(withJSONObject: itemsJson)
            client.complete(withStatusCode: 200, data: json)
            
        })
    }
}

// MARK: Helpers
private extension RemoteFeedLoaderTests {
    func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        return (RemoteFeedLoader(url: url, client: client), client)
    }
    
    func expect(_ sut: RemoteFeedLoader, toCompleteWith result: RemoteFeedLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        
        var capturedResults = [RemoteFeedLoader.Result]()
        sut.load() { capturedResults.append($0) }
        action()
        
        XCTAssertEqual(capturedResults, [result], file: file, line: line)
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
