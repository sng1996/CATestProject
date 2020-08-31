//
//  PhotosClient.swift
//  CATestProject
//
//  Created by Сергей Гаврилко on 26.08.2020.
//  Copyright © 2020 Сергей Гаврилко. All rights reserved.
//

import ComposableArchitecture
import UIKit
import Photos
import Combine

struct PhotosClient {
  var photos: () -> Effect<[UIImage], Failure>

  struct Failure: Error, Equatable {}
}

extension PhotosClient {
    static let live = PhotosClient(
        photos: {
            return Publishers.PhotosPublisher()
                .mapError { _ in Failure() }
                .eraseToEffect()
        }
    )
}

extension Publishers {
    
    class PhotosSubscription<S: Subscriber>: Subscription where S.Input == [UIImage], S.Failure == Error {
        
        private var result: PHFetchResult<PHAsset>?
        private var subscriber: S?
        
        init(subscriber: S) {
            self.subscriber = subscriber
            sendRequest()
        }
        
        func request(_ demand: Subscribers.Demand) { }
        
        func cancel() {
            subscriber = nil
        }
        
        private func sendRequest() {
            guard let subscriber = subscriber else { return }
            fetchAssetResult() { result in
                guard let asset = result?.firstObject else {
                    subscriber.receive(completion: Subscribers.Completion.failure(NSError(domain: "Can't get photo", code: 0, userInfo: nil)))
                    return
                }
                
                guard let image = self.getImage(asset) else {
                    subscriber.receive(completion: Subscribers.Completion.failure(NSError(domain: "Can't get photo", code: 1, userInfo: nil)))
                    return
                }
                
                _ = subscriber.receive([image])
            }
        }
        
        private func fetchAssetResult(completion: @escaping (PHFetchResult<PHAsset>?) -> Void) {
            PHPhotoLibrary.requestAuthorization { status in
                switch status {
                case .authorized:
                    print("Good to proceed")
                    let result = PHAsset.fetchAssets(with: .image, options: PHFetchOptions())
                    completion(result)
                case .denied, .restricted:
                    print("Not allowed")
                case .notDetermined:
                    print("Not determined yet")
                @unknown default:
                    return
                }
            }
        }
        
        private func getImage(_ asset: PHAsset) -> UIImage? {
            let manager = PHImageManager.default()
            let option = PHImageRequestOptions()
            var image: UIImage?
            let imageSide = (UIScreen.main.bounds.width - 8) / 3
            option.isSynchronous = true
            manager.requestImage(for: asset,
                                 targetSize: CGSize(width: imageSide, height: imageSide),
                                 contentMode: .aspectFit,
                                 options: option,
                                 resultHandler: { result, _ -> Void in image = result })
            return image
        }
    }
}

extension Publishers {
    
    struct PhotosPublisher: Publisher {
        typealias Output = [UIImage]
        typealias Failure = Error
        
        func receive<S: Subscriber>(subscriber: S) where
            PhotosPublisher.Failure == S.Failure, PhotosPublisher.Output == S.Input {
                let subscription = PhotosSubscription(subscriber: subscriber)
                subscriber.receive(subscription: subscription)
        }
    }
}

