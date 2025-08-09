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
                do {
                    let items = try FeedItemsMapper.map(data, response: response)
                    completion(.success(items))
                } catch {
                    completion(.failure(.invalidData))
                }
            case .failure:
                completion(.failure(.connectivity))
            }
        })
    }
}

private class FeedItemsMapper {
    
    private struct Root: Decodable {
        let items: [Item]
    }

    private struct Item: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL
        
        var item: FeedItem {
            .init(
                id: id,
                description: description,
                location: location,
                imageURL: image
            )
        }
    }
    
    static var OK_200: Int { 200 }
    
    static func map(_ data: Data, response: HTTPURLResponse) throws -> [FeedItem] {
        guard response.statusCode == OK_200  else {
            throw RemoteFeedLoader.Error.invalidData
        }
        let root = try JSONDecoder().decode(Root.self, from: data)
        return root.items.map(\.item)
    }
}

