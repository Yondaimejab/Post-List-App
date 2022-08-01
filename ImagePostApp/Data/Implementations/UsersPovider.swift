//
//  PostsPovider.swift
//  ImagePostApp
//
//  Created by Joel Alcantara burgos on 6/3/21.
//

import Foundation
import Combine
import Alamofire

class UserProvider: UserProviding {

    static var shared = UserProvider()
    private var localUserProvider: LocalDbUserProviding?
    private var requestSubscriber: AnyCancellable?
    private var localSaveSubscriber: AnyCancellable?
    private var localUsersSubscriber: AnyCancellable?
    private var localStorageHasData: Bool = false

    init(localUserProvider: LocalDbUserProviding? = try? LocalUserDataProvider()) {
        self.localUserProvider = localUserProvider
        validate()
    }

    func validate() {
        localSaveSubscriber = localUserProvider?.validateUserExist().sink(receiveValue: { (hasValues) in
            self.localStorageHasData = hasValues
        })
    }

    enum PostRequestError: Error {
        case loadingFailed
        case undefined
        case noLocalDbFound
        case noInternetConnection
        case noInternetOrLocalData
        case alamofireReachabilityError
    }

    func getAllUsers() -> AnyPublisher<[User], Error> {
        // Validate internet connection
        if let networkManager = NetworkReachabilityManager() {
            if networkManager.isReachable {
                guard localStorageHasData else { return getUsersFromWeb() }
                return getUserListFromLocalDb()
            } else {
                guard !localStorageHasData else { return getUserListFromLocalDb() }
                return Future<[User], Error> {
                    promise in promise(.failure(PostRequestError.noInternetOrLocalData))
                }.eraseToAnyPublisher()
            }
        } else {
            return Future<[User], Error> { promise in
                promise(.failure(PostRequestError.alamofireReachabilityError))
            }.eraseToAnyPublisher()
        }
    }

    private func getUsersFromWeb() -> AnyPublisher<[User], Error> {
        return Future<[User], Error> { promise in
            let endPoint = EndPoints.posts
            guard let url = URL(string: Routes.baseUrl.rawValue + endPoint.rawValue) else {
                return promise(.failure(PostRequestError.loadingFailed))
            }
            self.requestSubscriber = AF.request(url, method: .get)
                .publishData()
                .compactMap({ (response) -> Data? in
                    guard let data = response.data else { return nil }
                    let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                    guard let jsonDictionary = jsonObject as? [String: Any] else { return nil }
                    guard let dict = jsonDictionary["data"] as? [[String: Any]] else { return nil }
                    return try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
                }).decode(type: [User].self, decoder: JSONDecoder())
                .sink(receiveCompletion: { (completion) in
                    switch completion {
                    case .failure(let error): promise(.failure(error))
                    case .finished: print("Success")
                    }
                }, receiveValue: { (users) in
                    let userList = users.removeAnyDuplicates()
                    self.saveUsersToLocalDb(users: userList)
                    promise(.success(userList))
                })
        }.eraseToAnyPublisher()
    }

    private func saveUsersToLocalDb(users: [User]) {
        localSaveSubscriber = localUserProvider?.saveUsers(users: users)
            .sink(receiveValue: { (didSave) in
                if !didSave {
                    print("error has happend")
                } else {
                    print("Success Saving locally")
                }
            })
    }

    private func getUserListFromLocalDb() -> AnyPublisher<[User], Error> {
        if let userPublisher = localUserProvider?.getUsers() { return userPublisher }
        return Future<[User], Error> { promise in
            promise(.failure(PostRequestError.noLocalDbFound))
        }.eraseToAnyPublisher()
    }

    func refreshData() -> AnyPublisher<[User], Error> {
        if let networkManager = NetworkReachabilityManager() {
            guard !networkManager.isReachable else { return getUsersFromWeb() }
            return Future<[User], Error> {
                promise in promise(.failure(PostRequestError.noInternetConnection))
            }.eraseToAnyPublisher()
        }
        return Future<[User], Error> { promise in
            promise(.failure(PostRequestError.alamofireReachabilityError))
        }.eraseToAnyPublisher()
    }
}

var mockUsers: [User] = [
    User(name: "Joel", email: "Alcantara029@gmail.com", pictureUrl: "https://images.ctfassets.net/hrltx12pl8hq/4plHDVeTkWuFMihxQnzBSb/aea2f06d675c3d710d095306e377382f/shutterstock_554314555_copy.jpg", post: mockList[0]),
    User(name: "Enmanuel", email: "Alcantar12312329@gmail.com", pictureUrl: "https://image.shutterstock.com/image-illustration/royaltyfree-abstract-technology-blue-neon-260nw-1182863752.jpg", post: mockList[1])
]

var mockList: [Post] = [
    Post(id: 7, date: "01/01/1999", pics: [
            "https://images.ctfassets.net/hrltx12pl8hq/4plHDVeTkWuFMihxQnzBSb/aea2f06d675c3d710d095306e377382f/shutterstock_554314555_copy.jpg"
    ]),
    Post(id: 6, date: "01/01/1999", pics: [
        "https://image.shutterstock.com/image-illustration/royaltyfree-abstract-technology-blue-neon-260nw-1182863752.jpg",
        "https://image.shutterstock.com/image-illustration/royaltyfree-abstract-blue-violet-lines-260nw-1119674990.jpg"
    ]),
    Post(id: 5, date: "01/01/1999", pics: [
        "https://images.ctfassets.net/hrltx12pl8hq/4plHDVeTkWuFMihxQnzBSb/aea2f06d675c3d710d095306e377382f/shutterstock_554314555_copy.jpg",
        "https://image.shutterstock.com/image-illustration/royaltyfree-abstract-technology-blue-neon-260nw-1182863752.jpg",
        "https://image.shutterstock.com/image-illustration/royaltyfree-abstract-blue-violet-lines-260nw-1119674990.jpg"
    ]),
    Post(id: 4, date: "01/01/1999", pics: [
        "https://images.ctfassets.net/hrltx12pl8hq/5596z2BCR9KmT1KeRBrOQa/4070fd4e2f1a13f71c2c46afeb18e41c/shutterstock_451077043-hero1.jpg",
        "https://images.ctfassets.net/hrltx12pl8hq/4plHDVeTkWuFMihxQnzBSb/aea2f06d675c3d710d095306e377382f/shutterstock_554314555_copy.jpg",
        "https://image.shutterstock.com/image-illustration/royaltyfree-abstract-technology-blue-neon-260nw-1182863752.jpg",
        "https://image.shutterstock.com/image-illustration/royaltyfree-abstract-blue-violet-lines-260nw-1119674990.jpg"
    ])
]

var secondMock = [
    Post(id: 1, date: "01/01/1999", pics: [
        "http://hd.wallpaperswide.com/thumbs/beautiful_mountain_landscape_winter_3-t1.jpg",
        "http://hd.wallpaperswide.com/thumbs/hogwarts_legacy-t1.jpg",
        "http://hd.wallpaperswide.com/thumbs/atlantis_nebula_14-t1.jpg"
    ]),
    Post(id: 2, date: "01/01/1999", pics: [
        "http://hd.wallpaperswide.com/thumbs/spider_man_14-t1.jpg",
        "http://hd.wallpaperswide.com/thumbs/hogwarts_legacy-t1.jpg",
        "http://hd.wallpaperswide.com/thumbs/atlantis_nebula_14-t1.jpg"
    ]),
    Post(id: 3, date: "01/01/1999", pics: [
        "http://hd.wallpaperswide.com/thumbs/spider_man_14-t1.jpg",
        "http://hd.wallpaperswide.com/thumbs/hogwarts_legacy-t1.jpg",
        "http://hd.wallpaperswide.com/thumbs/atlantis_nebula_14-t1.jpg",
        "http://hd.wallpaperswide.com/thumbs/desert_night-t1.jpg",
        "http://hd.wallpaperswide.com/thumbs/spider_man_14-t1.jpg",
        "http://hd.wallpaperswide.com/thumbs/hogwarts_legacy-t1.jpg",
        "http://hd.wallpaperswide.com/thumbs/atlantis_nebula_14-t1.jpg",
        "http://hd.wallpaperswide.com/thumbs/desert_night-t1.jpg"
    ])
]

