//
//  PostsPovider.swift
//  ImagePostApp
//
//  Created by Joel Alcantara burgos on 6/3/21.
//

import Foundation
import Combine


class PostProvider: PostProviding {

    static var shared = PostProvider()

    enum PostRequestError: Error {
        case loadingFailed
        case undefined
    }

    func getAllPosts() -> AnyPublisher<[Post], Error> {
        return Future<[Post], Error> { promise in
            promise(.failure(PostRequestError.undefined))
        }.eraseToAnyPublisher()
    }
}
