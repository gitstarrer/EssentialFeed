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
        expect(sut, toCompleteWith: .connectivity) {
            let clientError = NSError(domain: "test", code: 0)
            client.complete(with: clientError)
        }
    }
    
    @Test
    func test_load_deliversErrorOnNon200Response() async throws {
        let (sut, client) = makeSUT()
        let samples = [199, 201, 300, 400, 501]
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: .invalidData) {
                client.complete(with: code, at: index)
            }
        }
    }
    
    @Test
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWith: .invalidData) {
            let invalidJSON = Data("invalid JSON".utf8)
            client.complete(with: 200, data:  invalidJSON)
        }
    }
    
    //MARK: Helper
    private  func makeSUT(url: URL = URL(string: "https:/a-url.com")!) -> (sut: RemoteFeedLoader, client: HttpClientSpy) {
        let client = HttpClientSpy()
        return (sut: RemoteFeedLoader(url: url, client: client), client: client)
    }
    
    private func expect(_ sut: RemoteFeedLoader, toCompleteWith error: RemoteFeedLoader.Error, action: () -> Void, sourceLocation: SourceLocation = #_sourceLocation) {
        var capturedErrors = [RemoteFeedLoader.Error]()
        sut.load { capturedErrors.append($0) }
        action()
        #expect(capturedErrors == [error], sourceLocation: sourceLocation)
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
        
        func complete(with statusCode: Int = 200, data: Data = Data(), at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index], statusCode: statusCode, httpVersion: nil, headerFields: nil)!
            messages[index].completion(.success(data, response))
        }
    }
}
