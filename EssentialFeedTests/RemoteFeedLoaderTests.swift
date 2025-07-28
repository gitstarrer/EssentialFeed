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
        
        sut.load()
        
        #expect(client.requestedURLs == [url])
    }
    
    @Test
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https:/a-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load()
        sut.load()
        
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
    
    //MARK: Helper
    private  func makeSUT(url: URL = URL(string: "https:/a-url.com")!) -> (sut: RemoteFeedLoader, client: HttpClientSpy) {
        let client = HttpClientSpy()
        return (sut: RemoteFeedLoader(url: url, client: client), client: client)
    }
    
    private class HttpClientSpy: HTTPClient {
        var requestedURLs = [URL]()
        var completions: [(Error) -> Void] = []
        
        func get(from url: URL, completion: @escaping (Error) -> Void) {
            completions.append(completion)
            requestedURLs.append(url)
        }
        
        func complete(with error: Error, at index: Int = 0) {
            completions[index](error)
        }
        
    }
}
