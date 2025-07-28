//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Himanshu on 28/07/25.
//

import Foundation

public struct FeedItem: Equatable {
    let id: String
    let description: String?
    let location: String?
    let imageURL: URL
}
