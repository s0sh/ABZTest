//
//  UIKit.swift
//  ABZTest_iOs_Bihun
//
//  Created by Roman Bigun on 19.06.2025.
//


import Foundation
import Combine
import class UIKit.UIImage

/// A protocol that defines the requirements for an image storage system.
///
/// This abstraction allows for different caching strategies to be used interchangeably
/// and simplifies testing by enabling mock implementations.
public protocol ImageStorage: AnyObject {
    /// Asynchronously retrieves an image for a given URL.
    /// - Parameter url: The URL of the image to retrieve.
    /// - Returns: A Combine publisher that emits the image or an error.
    func getImage(for url: URL) -> AnyPublisher<UIImage?, Error>
    
    /// Synchronously retrieves an image from the cache.
    /// - Parameter url: The URL of the image to look up in the cache.
    /// - Returns: The cached `UIImage` or `nil` if it's not in the cache.
    func cachedImage(with url: URL) -> UIImage?
    
    /// Clears all cached images from the storage.
    func clearStorage()
}

/// A lightweight image caching service that uses `URLCache` for in-memory and on-disk caching.
///
/// This class conforms to the `ImageStorage` protocol and provides a shared singleton instance
/// for easy access throughout the application. It's configured with a default cache size
/// and a session that prioritizes revalidating cache data.
public final class ImageURLStorage: ImageStorage {
    public static let shared: ImageStorage = ImageURLStorage()

    private let cache: URLCache
    private let session: URLSession
    private let cacheSize: Int = .megaBytes(150)

    private init() {
        let config = URLSessionConfiguration.default
        cache = URLCache(memoryCapacity: cacheSize, diskCapacity: cacheSize)
        config.urlCache = cache
        config.requestCachePolicy = .reloadRevalidatingCacheData
        config.httpMaximumConnectionsPerHost = 5

        session = URLSession(configuration: config)
    }

    public func getImage(for url: URL) -> AnyPublisher<UIImage?, Error> {
            latestData(with: url)
                .map(UIImage.init)
                .eraseToAnyPublisher()
    }

    public func cachedImage(with url: URL) -> UIImage? {
        let request = URLRequest(url: url)
        let data = cache.cachedResponse(for: request)?.data
        return data.flatMap(UIImage.init)
    }

    public func clearStorage() {
        cache.removeAllCachedResponses()
    }
}

extension ImageURLStorage {
    private func latestData(with url: URL)  -> AnyPublisher<Data, Error> {
        let request = URLRequest(url: url)

        return session
            .dataTaskPublisher(for: request)
            .map(\.data)
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
}

private extension Int {
    static func megaBytes(_ number: Int) -> Int {
        number * 1024 * 1024
    }
}
