//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Himanshu on 28/07/25.
//

import Foundation

public final class RemoteFeedLoader {
    let url: URL
    let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public enum Result: Equatable {
        case success([FeedItem])
        case failure(Error)
    }
    
    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (RemoteFeedLoader.Result) -> Void) {
        client.get(from: url, completion: { result in
            switch result {
            case let .success(data, response):
                completion(FeedItemsMapper.map(data, response: response))
            case .failure:
                completion(.failure(.connectivity))
            }
        })
    }
}
