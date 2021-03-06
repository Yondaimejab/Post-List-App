//
//  PostProvidingProtocol.swift
//  ImagePostApp
//
//  Created by Joel Alcantara burgos on 6/3/21.
//

import Foundation
import Combine

protocol UserProviding {
    func getAllUsers() -> AnyPublisher<[User], Error>
}
