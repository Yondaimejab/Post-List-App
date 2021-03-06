//
//  PostsPresenter.swift
//  ImagePostApp
//
//  Created by Joel Alcantara burgos on 6/3/21.
//

import Foundation
import Combine

class PostPresenter {

    enum PostError: Error {
        case couldNotFindReference
    }

    // properties
    private var userProvider: UserProvider
    private var requestSubscriber: AnyCancellable?

    @Published var postList: [PostCellViewModel] = []

    init(userProvider: UserProvider = UserProvider.shared) {
        self.userProvider = userProvider
    }

    func getNextPosts() -> AnyPublisher<Bool, Error> {
        let publisher = Future<Bool,Error> { [weak self] promise in

            guard let self = self else {
                promise(.failure(PostError.couldNotFindReference))
                return
            }

            self.requestSubscriber = self.userProvider.getAllUsers()
                .map({ (user) -> [PostCellViewModel] in
                    var postViewModelList: [PostCellViewModel] = []
                    user.forEach { (user) in
                        user.posts.forEach { (post) in
                            postViewModelList.append(
                                PostCellViewModel(
                                    id: post.id, //post.data
                                    userViewModel: UsersUIViewViewModel(name: user.name, email: user.email, imageUrl: user.profilePicture, date: "hoy"),
                                    picturesUrls: post.pics
                                )
                            )
                        }
                    }

                    return postViewModelList
                })
                .sink(receiveCompletion: { (completion) in
                    switch completion {
                    case .failure(let error):
                        print(error.localizedDescription)
                        promise(.failure(error))
                    case .finished:
                        promise(.success(true))
                    }
                }, receiveValue: { [weak self] (postList) in
                    self?.postList = postList
                })
        }

        return publisher.eraseToAnyPublisher()
    }

}
