//
//  UIKit.swift
//  ABZTest_iOs_Bihun
//
//  Created by Roman Bigun on 19.06.2025.
//
import Foundation
import Combine
import class UIKit.UIImage

final class ImageLoader: ObservableObject {
    @Published var image = UIImage(named: "Logo")!
    private var subscriptions = Set<AnyCancellable>()
    
    init(url: URL?) {
        guard let url = url else {
            return
        }

        ImageURLStorage.shared
            .cachedImage(with: url)
            .map { image = $0 }

        ImageURLStorage.shared
            .getImage(for: url)
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] in
                    self?.image = $0
                })
            .store(in: &subscriptions)
    }
}

final class OptionalImageLoader: ObservableObject {
    @Published var image: UIImage?
    private var subscriptions = Set<AnyCancellable>()

    init(url: URL? = nil, placeholder: UIImage? = nil) {
        image = placeholder
        guard let url = url else {
            return
        }

        ImageURLStorage.shared
            .cachedImage(with: url)
            .map { image = $0 }

        ImageURLStorage.shared
            .getImage(for: url)
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] in
                    self?.image = $0
                })
            .store(in: &subscriptions)
    }
}
