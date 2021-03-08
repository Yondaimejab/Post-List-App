//
//  User.swift
//  ImagePostApp
//
//  Created by Joel Alcantara burgos on 6/3/21.
//

import Foundation

struct User: Codable, Equatable {

    var uid: String
    var name: String
    var email: String
    var profilePicture: String
    var post: Post

    init(name: String, email: String, pictureUrl: String, post: Post) {
        self.uid = UUID().uuidString
        self.name = name
        self.email = email
        self.profilePicture = pictureUrl
        self.post = post
    }

    enum CodingKeys: String, CodingKey {
        case uid
        case name
        case email
        case profilePicture = "profile_pic"
        case post = "post"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(String.self, forKey: .uid)
        let name = try container.decode(String.self, forKey: .name)
        let email = try container.decode(String.self, forKey: .email)
        let profilePic = try container.decode(String.self, forKey: .profilePicture)
        let post = try container.decodeIfPresent(Post.self, forKey: .post)
        self.uid = id
        self.name = name
        self.email = email
        self.profilePicture = profilePic
        self.post = post ?? mockList[0]
    }

    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.uid == rhs.uid && lhs.post.id == rhs.post.id
    }

    func getData() -> [String: Any] {
        let data: [String: Any] = [
            "uid": uid,
            "name": name,
            "email": email,
            "profile_pic": profilePicture,
            "post": post.getData()
        ]
        return data
    }
}
