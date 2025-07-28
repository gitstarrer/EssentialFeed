//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Himanshu on 28/07/25.
//

import Testing
import Foundation

class RemoteFeedLoader {
    
}

class HTTPClient {
    var requestedURL: URL?
}

struct RemoteFeedLoaderTests {

    @Test("test init")
    func test_init() async throws {
        let client = HTTPClient()
        _ = RemoteFeedLoader()
        #expect(client.requestedURL == nil)
    }

}
