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
        var capturedError = [RemoteFeedLoader.Error]()
        
        sut.load { capturedError.append($0) }
        let clientError = NSError(domain: "test", code: 0)
        client.complete(with: clientError)
        
        #expect(capturedError == [.connectivity])
    }
    
    @Test
    func test_load_deliversErrorOnNon200Response() async throws {
        let (sut, client) = makeSUT()
        var capturedError = [RemoteFeedLoader.Error]()
        
        sut.load { capturedError.append($0) }
        let clientError = NSError(domain: "test", code: 0)
        client.complete(with: 200)
        
        #expect(capturedError == [.invalidData])
    }
    
    //MARK: Helper
    private  func makeSUT(url: URL = URL(string: "https:/a-url.com")!) -> (sut: RemoteFeedLoader, client: HttpClientSpy) {
        let client = HttpClientSpy()
        return (sut: RemoteFeedLoader(url: url, client: client), client: client)
    }
    
    private class HttpClientSpy: HTTPClient {
        var messages = [(urls: URL, completion: (Error?, HTTPURLResponse?) -> Void)]()
        var requestedURLs: [URL] {
            messages.map(\.urls)
        }
        
        func get(from url: URL, completion: @escaping (Error?, HTTPURLResponse?) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(error, nil)
        }
        
        func complete(with statusCode: Int = 200, at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index], statusCode: statusCode, httpVersion: nil, headerFields: nil)
            messages[index].completion(nil, response)
        }
        
    }
}
