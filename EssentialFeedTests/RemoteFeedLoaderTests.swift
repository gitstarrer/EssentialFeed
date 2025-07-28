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
        HTTPClient.shared.requestedURL = URL(string: "https:/a-url.com")!
    }
}

class HTTPClient {
    static let shared = HTTPClient()
    
    private init() {}
    
    var requestedURL: URL?
}

struct RemoteFeedLoaderTests {

    @Test("test init")
    func test_init() async throws {
        let client = HTTPClient.shared
        _ = RemoteFeedLoader()
        #expect(client.requestedURL == nil)
    }

    @Test
    func test_load_requestDataFromURL() {
        let client = HTTPClient.shared
        let sut = RemoteFeedLoader()
        
        sut.load()
        #expect(client.requestedURL != nil)
    }
}
