//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Himanshu on 28/07/25.
//

import Testing
import Foundation

class RemoteFeedLoader {
    func load() {
        HTTPClient.shared.get(from: URL(string: "https:/a-url.com")!)
    }
}

class HTTPClient {
    static var shared = HTTPClient()
    
    func get(from url: URL) {
        
    }
}

class HttpClientSpy: HTTPClient {
    var requestedURL: URL?
    
    override func get(from url: URL) {
        requestedURL = url
    }
    
}

struct RemoteFeedLoaderTests {

    @Test("test init")
    func test_init() async throws {
        let client = HttpClientSpy()
        HTTPClient.shared = client
        _ = RemoteFeedLoader()
        #expect(client.requestedURL == nil)
    }

    @Test
    func test_load_requestDataFromURL() {
        let client = HttpClientSpy()
        HTTPClient.shared = client
        let sut = RemoteFeedLoader()
        
        sut.load()
        #expect(client.requestedURL != nil)
    }
}
