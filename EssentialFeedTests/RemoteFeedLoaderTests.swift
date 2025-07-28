//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Himanshu on 28/07/25.
//

import Testing
import Foundation

class RemoteFeedLoader {
    let client: HTTPClient
    init(client: HTTPClient) {
        self.client = client
    }
    
    func load() {
        client.get(from: URL(string: "https:/a-url.com")!)
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
        let client = HttpClientSpy()
        _ = RemoteFeedLoader(client: client)
        #expect(client.requestedURL == nil)
    }

    @Test
    func test_load_requestDataFromURL() {
        let client = HttpClientSpy()
        let sut = RemoteFeedLoader(client: client)
        
        sut.load()
        #expect(client.requestedURL != nil)
    }
}
