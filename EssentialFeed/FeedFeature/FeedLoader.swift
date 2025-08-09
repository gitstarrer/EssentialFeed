//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Himanshu on 28/07/25.
//

import Foundation

public enum LoadFeedResult<Error: Swift.Error> {
    case success([FeedItem])
    case failure(Error)
}

extension LoadFeedResult: Equatable where Error: Equatable { }

protocol FeedLoader {
    associatedtype Error: Swift.Error
    func load(completion: (LoadFeedResult<Error>) -> Void)
}
