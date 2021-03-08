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
                        postViewModelList.append(
                            PostCellViewModel(
                                id: "\(user.post.id)",
                                userViewModel: UsersUIViewViewModel(name: user.name, email: user.email, imageUrl: user.profilePicture, date: user.post.date.date.short),
                                picturesUrls: user.post.pics
                            )
                        )
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

    func refreshPostList() -> AnyPublisher<Bool, Error> {
        let publisher = Future<Bool,Error> { [weak self] promise in

            guard let self = self else {
                promise(.failure(PostError.couldNotFindReference))
                return
            }

            self.requestSubscriber = self.userProvider.refreshData()
                .map({ (user) -> [PostCellViewModel] in
                    var postViewModelList: [PostCellViewModel] = []
                    user.forEach { (user) in
                        postViewModelList.append(
                            PostCellViewModel(
                                id: "\(user.post.id)",
                                userViewModel: UsersUIViewViewModel(name: user.name, email: user.email, imageUrl: user.profilePicture, date: user.post.date.date.short),
                                picturesUrls: user.post.pics
                            )
                        )
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
