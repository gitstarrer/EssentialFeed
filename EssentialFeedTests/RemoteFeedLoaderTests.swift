//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Himanshu on 28/07/25.
//

import Testing
import Foundation

class RemoteFeedLoader {
    let url: URL
    let client: HTTPClient
    
    init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    func load() {
        client.get(from: url)
    }
}

protocol HTTPClient {
    func get(from url: URL)
}

class HttpClientSpy: HTTPClient {
    var requestedURL: URL?
    
    func get(from url: URL) {
        requestedURL = url
    }
    
}

struct RemoteFeedLoaderTests {

    @Test("test init")
    func test_init() async throws {
        let url = URL(string: "https:/a-url.com")!
        let client = HttpClientSpy()
        _ = RemoteFeedLoader(url: url, client: client)
        #expect(client.requestedURL == nil)
    }

    @Test
    func test_load_requestDataFromURL() {
        let url = URL(string: "https:/a-url.com")!
        let client = HttpClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        
        sut.load()
        #expect(client.requestedURL == url)
    }
}
