//
//  UserUIViewViewModel.swift
//  ImagePostApp
//
//  Created by Joel Alcantara burgos on 6/3/21.
//

import Foundation

struct UsersUIViewViewModel {
    // var id: String = UUID().uuidString
    var name: String
    var email: String
    var imageUrl: String
    var date: String

    init(name: String, email: String, imageUrl: String, date: String) {
        self.name = name
        self.email = email
        self.imageUrl = imageUrl
        self.date = date
    }
}
