//
//  Routing.swift
//  ImagePostApp
//
//  Created by Joel Alcantara burgos on 7/3/21.
//

import Foundation
import Alamofire

enum Routes: String {
    case baseUrl = "https://mock.koombea.io/mt/api/"
}

enum EndPoints: String {
    case posts

    var rawValue: String {
        switch self {
        default:
            return  "posts"
        }
    }

    var method: HTTPMethod {
        switch self {
        default:
            return .get
        }
    }

    var parameters: [String:Any] {
        switch self {
        default:
            return [:]
        }
    }
}

