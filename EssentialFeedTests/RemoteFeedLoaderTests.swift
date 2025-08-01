//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Himanshu on 28/07/25.
//

import Foundation
import Testing
import EssentialFeed

struct RemoteFeedLoaderTests {

    @Test("test init")
    func test_init() async throws {
        let (_, client) =  makeSUT()
        #expect(client.requestedURLs == [])
    }

    @Test
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https:/a-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        
        #expect(client.requestedURLs == [url])
    }
    
    @Test
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https:/a-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        sut.load { _ in }
        
        #expect(client.requestedURLs == [url, url])
    }
    
    @Test
    func test_load_deliversErrorOnClientError() async throws {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWith: .failure(.connectivity)) {
            let clientError = NSError(domain: "test", code: 0)
            client.complete(with: clientError)
        }
    }
    
    @Test
    func test_load_deliversErrorOnNon200Response() async throws {
        let (sut, client) = makeSUT()
        let samples = [199, 201, 300, 400, 501]
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: .failure(.invalidData)) {
                let json = makeItemsJSON([])
                client.complete(withStatusCode: code, data: json, at: index)
            }
        }
    }
    
    @Test
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWith: .failure(.invalidData)) {
            let invalidJSON = Data("invalid JSON".utf8)
            client.complete(withStatusCode: 200, data:  invalidJSON)
        }
    }

    @Test
    func test_load_deliversNoItemsOnEmptyListJSON() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWith: .success([])) {
            let emptyJSON = Data("{\"items\": []}".utf8)
            client.complete(withStatusCode: 200, data: emptyJSON)
        }
    }
    
    @Test
    func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()
        
        let item1 = makeItem(id: UUID(), imageURL: URL(string: "https://a-url.com")!)
        let item2 = makeItem(id: UUID(), description: "a description",
                             location: "a location", imageURL: URL(string: "https://another-url.com")!)
        
        expect(sut, toCompleteWith: .success([item1.item, item2.item]), action: {
            let jsonData = makeItemsJSON([item1.itemJSON, item2.itemJSON])
            client.complete(withStatusCode: 200, data: jsonData)
        })
    }
    
    //MARK: Helper
    private func makeSUT(url: URL = URL(string: "https:/a-url.com")!) -> (sut: RemoteFeedLoader, client: HttpClientSpy) {
        let client = HttpClientSpy()
        return (sut: RemoteFeedLoader(url: url, client: client), client: client)
    }
    
    private func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) -> (item: FeedItem, itemJSON: [String: Any]) {
        let feedItem = FeedItem(id: id, description: description, location: location, imageURL: imageURL)
        let feedItemJSON = [
            "id": id.uuidString,
            "description": description,
            "location": location,
            "image": imageURL.absoluteString
        ].reduce(into: [String: Any]()){ (acc, e) in
            if let value = e.value { acc[e.key] = value }
        }
        
        return (feedItem, feedItemJSON)
    }
    
    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        let json = ["items": items]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func expect(_ sut: RemoteFeedLoader, toCompleteWith result: RemoteFeedLoader.Result, action: () -> Void, sourceLocation: SourceLocation = #_sourceLocation) {
        
        var capturedResults = [RemoteFeedLoader.Result]()
        sut.load { capturedResults.append($0) }
        
        action()
        
        #expect(capturedResults == [result], sourceLocation: sourceLocation)
    }
    
    private class HttpClientSpy: HTTPClient {
        var messages = [(urls: URL, completion: (HTTPClientResult) -> Void)]()
        var requestedURLs: [URL] {
            messages.map(\.urls)
        }
        
        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int = 200, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index], statusCode: code, httpVersion: nil, headerFields: nil)!
            messages[index].completion(.success(data, response))
        }
    }
}
