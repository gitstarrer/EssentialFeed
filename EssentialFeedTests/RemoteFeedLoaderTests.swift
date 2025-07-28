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
    
    //MARK: Helper
    private  func makeSUT(url: URL = URL(string: "https:/a-url.com")!) -> (sut: RemoteFeedLoader, client: HttpClientSpy) {
        let client = HttpClientSpy()
        return (sut: RemoteFeedLoader(url: url, client: client), client: client)
    }
    
    private class HttpClientSpy: HTTPClient {
        var requestedURLs = [URL]()
        
        func get(from url: URL) {
            requestedURLs.append(url)
        }
        
    }
}
