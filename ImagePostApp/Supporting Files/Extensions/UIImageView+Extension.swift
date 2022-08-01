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
        case retrieveImageError
        case imageConversionError
    }

    func loadImageFrom(url: String) -> Future<Bool, Error> {
        return  Future<Bool, Error> { promise in
            DispatchQueue.global().async {
                guard let url = URL(string: url) else { return promise(.failure(ImageLoadingError.invalidURL)) }
                guard let data = try? Data(contentsOf: url) else {
                    return promise(.failure(ImageLoadingError.retrieveImageError))
                }
                guard let imageResult = UIImage(data: data) else {
                    return promise(.failure(ImageLoadingError.imageConversionError))
                }
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.image = imageResult
                    promise(.success(true))
                }
            }
        }
    }
}
