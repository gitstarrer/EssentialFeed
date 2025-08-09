//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Himanshu on 09/08/25.
//

import Foundation

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}
