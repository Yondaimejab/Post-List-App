//
//  PostsPovider.swift
//  ImagePostApp
//
//  Created by Joel Alcantara burgos on 6/3/21.
//

import Foundation
import Combine


class UserProvider: UserProviding {


    static var shared = UserProvider()

    enum PostRequestError: Error {
        case loadingFailed
        case undefined
    }

    func getAllUsers() -> AnyPublisher<[User], Error> {
        return Future<[User], Error> { promise in
            // promise(.failure(PostRequestError.undefined))
            promise(.success(mockUsers))
        }.eraseToAnyPublisher()
    }
}

var mockUsers: [User] = [
    User(uid: UUID().uuidString, name: "Joel", email: "Alcantara0729@gmail.com", profilePicture: "http://hd.wallpaperswide.com/thumbs/assassins_creed_valhalla_video_game_ragnar_lothbrok-t1.jpg", posts: mockList),
    User(uid: UUID().uuidString, name: "Enmanuel", email: "Lider2189@gmail.com", profilePicture: "http://hd.wallpaperswide.com/thumbs/colorful_5-t1.jpg", posts: secondMock)
]

var mockList: [Post] = [
    Post(id: UUID().uuidString, data: Date(), pics: [
            "http://hd.wallpaperswide.com/thumbs/hogwarts_legacy-t1.jpg"
    ]),
    Post(id: UUID().uuidString, data: Date(), pics: [
        "http://hd.wallpaperswide.com/thumbs/spider_man_14-t1.jpg",
        "http://hd.wallpaperswide.com/thumbs/hogwarts_legacy-t1.jpg"
    ]),
    Post(id: UUID().uuidString, data: Date(), pics: [
        "http://hd.wallpaperswide.com/thumbs/beautiful_mountain_landscape_winter_3-t1.jpg",
        "http://hd.wallpaperswide.com/thumbs/hogwarts_legacy-t1.jpg",
        "http://hd.wallpaperswide.com/thumbs/atlantis_nebula_14-t1.jpg"
    ]),
    Post(id: UUID().uuidString, data: Date(), pics: [
        "http://hd.wallpaperswide.com/thumbs/spider_man_14-t1.jpg",
        "http://hd.wallpaperswide.com/thumbs/hogwarts_legacy-t1.jpg",
        "http://hd.wallpaperswide.com/thumbs/atlantis_nebula_14-t1.jpg",
        "http://hd.wallpaperswide.com/thumbs/desert_night-t1.jpg"
    ])
]

var secondMock = [
    Post(id: UUID().uuidString, data: Date(), pics: [
        "http://hd.wallpaperswide.com/thumbs/beautiful_mountain_landscape_winter_3-t1.jpg",
        "http://hd.wallpaperswide.com/thumbs/hogwarts_legacy-t1.jpg",
        "http://hd.wallpaperswide.com/thumbs/atlantis_nebula_14-t1.jpg"
    ]),
    Post(id: UUID().uuidString, data: Date(), pics: [
        "http://hd.wallpaperswide.com/thumbs/spider_man_14-t1.jpg",
        "http://hd.wallpaperswide.com/thumbs/hogwarts_legacy-t1.jpg",
        "http://hd.wallpaperswide.com/thumbs/atlantis_nebula_14-t1.jpg",
        "http://hd.wallpaperswide.com/thumbs/desert_night-t1.jpg"
    ])
]

