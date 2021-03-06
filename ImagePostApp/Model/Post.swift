//
//  Post.swift
//  ImagePostApp
//
//  Created by Joel Alcantara burgos on 6/3/21.
//

import Foundation

struct Post: Codable {
    var id: String
    var data: Date
    var pics: [String]
}

