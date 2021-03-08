//
//  LocalDbUsersProviding.swift
//  ImagePostApp
//
//  Created by Joel Alcantara burgos on 7/3/21.
//

import Foundation
import Combine

protocol LocalDbUserProviding {
    func saveUsers(users: [User]) -> AnyPublisher<Bool, Never> 
    func getUsers() -> AnyPublisher<[User], Error>
    func validateUserExist() -> AnyPublisher<Bool, Never>
}
