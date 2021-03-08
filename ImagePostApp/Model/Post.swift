//
//  Post.swift
//  ImagePostApp
//
//  Created by Joel Alcantara burgos on 6/3/21.
//

import Foundation

struct Post: Codable {
    var id: Int
    var date: String
    var pics: [String]
    
    init(id: Int, date: String, pics: [String]) {
        self.id = id
        self.date = date
        self.pics = pics
    }

    func getData() -> [String: Any] {
        let data: [String: Any] = [
            "id": id,
            "date": date,
            "pics": pics
        ]
        return data
    }
}

