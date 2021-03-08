//
//
//  UIImageView+Extension.swift
//  ImagePostApp
//
//  Created by Joel Alcantara burgos on 6/3/21.
//

import Foundation
import UIKit
import Combine

extension UIImageView {
    enum ImageLoadingError: Error {
        case invalidURL
        case retriveImageError
        case imageConvertionError
    }

    func loadImageFrom(url: String) -> Future<Bool, Error> {
        let publisher = Future<Bool, Error> { promise in
            DispatchQueue.global().async {
                if let url = URL(string: url) {
                    if let data = try? Data(contentsOf: url) {
                        if let imageResult = UIImage(data: data) {
                            DispatchQueue.main.async {
                                self.image = imageResult
                                promise(.success(true))
                            }
                        } else {
                            promise(.failure(ImageLoadingError.imageConvertionError))
                        }
                    } else {
                        promise(.failure(ImageLoadingError.retriveImageError))
                    }
                } else {
                    promise(.failure(ImageLoadingError.invalidURL))
                }
            }
        }
        return publisher
    }
}
