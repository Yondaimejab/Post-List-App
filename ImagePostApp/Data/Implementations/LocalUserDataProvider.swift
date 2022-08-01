//
//  LocalUserDataProvider.swift
//  ImagePostApp
//
//  Created by Joel Alcantara burgos on 7/3/21.
//

import Foundation
import CouchbaseLiteSwift
import Combine

class LocalUserDataProvider: LocalDbUserProviding {

    enum localDbUsersError: Error {
        case couldNotGetReferences
        case couldNotloadFromCoachLite
    }

    enum Constants {
        static let databaseName = "usersDatabase"
        static let documentType = "users"
    }

    private var database: Database
    private var usersSubscriber: AnyCancellable?

    init() throws {
        if let path = Bundle.main.path(forResource: Constants.databaseName, ofType: "cblite2"),
           !Database.exists(withName: Constants.databaseName) {
            do {
                try Database.copy(fromPath: path, toDatabase: Constants.databaseName, withConfig: nil)
            } catch let error {
                print(error.localizedDescription)
                fatalError("== Error could not create database copy of existing db==")
            }
        }
        do {
            database = try Database(name: Constants.databaseName)
        } catch {
            fatalError("== Error Could not create new database ==")
        }
    }

    func saveUsers(users: [User]) -> AnyPublisher<Bool, Never> {
        let future = Future<Bool, Never> { [self] promise in
            do {
                try self.database.inBatch {
                    for item in users {
                        let expression = Expression.property("uid").equalTo(Expression.string(item.uid))
                        let query = QueryBuilder.select(SelectResult.all(), SelectResult.expression(Meta.id))
                            .from(DataSource.database(self.database))
                            .where(expression)
                        var existsDocument = false
                        for results in try query.execute() {
                            _ = results.toDictionary()
                            existsDocument = true
                        }
                        if !existsDocument {
                            let document = MutableDocument(data: item.getData())
                            document.setString(Constants.documentType, forKey: "type")
                            try self.database.saveDocument(document)
                        }
                    }
                }
                promise(.success(true))
            } catch let error {
                print(error.localizedDescription)
                promise(.success(false))
            }
        }
        return future.eraseToAnyPublisher()
    }

    func getUsers() -> AnyPublisher<[User], Error> {
        return Future<[User], Error> { [weak self] promise in
            guard let self = self  else { return promise(.failure(localDbUsersError.couldNotGetReferences)) }
            let expression = Expression.property("type").equalTo(Expression.string(Constants.documentType))
            let query = QueryBuilder.select(SelectResult.all(), SelectResult.expression(Meta.id))
                .from(DataSource.database(self.database))
                .where(expression)
            var users: [User] = []
            do {
                self.usersSubscriber = try query.execute().publisher
                    .sink(receiveCompletion: { (completion) in
                        switch completion {
                        case.failure: fatalError("it never should fail couchlite")
                        case .finished: promise(.success(users))
                        }
                    }, receiveValue: { (result) in
                        if let dictValues = result.toDictionary()["usersDatabase"] as? [String: Any] {
                            let userValues = dictValues.filter { !($0.key == "type") }
                            if let jsonObject = try? JSONSerialization.data(
                                withJSONObject: userValues, options: .prettyPrinted
                            ) {
                                if let user = try? JSONDecoder().decode(User.self, from: jsonObject) {
                                    users.append(user)
                                }
                            }
                        }
                    })
            } catch let error {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }

    func validateUserExist() -> AnyPublisher<Bool, Never> {
        return Future<Bool, Never> { promise in
            let expressionProtocol = Expression.string(Constants.documentType)
            let expression = Expression.property("type").equalTo(expressionProtocol)
            let query = QueryBuilder.select(SelectResult.all())
                .from(DataSource.database(self.database))
                .where(expression)
            if let resultSet = try? query.execute(), !resultSet.allResults().isEmpty {
                promise(.success(true))
            } else {
                promise(.success(false))
            }
        }.eraseToAnyPublisher()
    }

}
