//
//  User.swift
//  ImagePostApp
//
//  Created by Joel Alcantara burgos on 6/3/21.
//

import Foundation

struct User: Codable {
    var uid: String
    var name: String
    var email: String
    var profilePicture: String
    var posts: [Post]

    enum CodingKeys: String, CodingKey {
        case uid
        case name
        case email
        case profilePicture = "profile_pic"
        case posts
    }
}
