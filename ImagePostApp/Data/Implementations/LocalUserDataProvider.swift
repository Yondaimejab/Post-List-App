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
                try Database.copy(
                    fromPath: path,
                    toDatabase: Constants.databaseName,
                    withConfig: nil
                )
            } catch {
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
                        let query = QueryBuilder.select(SelectResult.all(), SelectResult.expression(Meta.id))
                            .from(DataSource.database(self.database))
                            .where(
                                Expression.property("uid").equalTo(Expression.string(item.uid))
                            )

                        var existsDocument = false
                        for results in try query.execute() {
                            results.toDictionary()
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
            } catch {
                print(error.localizedDescription)
                promise(.success(false))
            }
        }
        return future.eraseToAnyPublisher()
    }

    func getUsers() -> AnyPublisher<[User], Error> {
        let future = Future<[User], Error> { [weak self] promise in
            if let self = self {
                var users: [User] = []
                let query = QueryBuilder.select(SelectResult.all(), SelectResult.expression(Meta.id))
                    .from(DataSource.database(self.database))
                    .where(
                        Expression.property("type").equalTo(Expression.string(Constants.documentType))
                    )

                do {
                    self.usersSubscriber = try query.execute().publisher
                        .sink(receiveCompletion: { (completion) in
                            switch completion {
                            case.failure:
                                fatalError("it never should faile couchlite")
                            case .finished:
                                promise(.success(users))
                            }
                            print(completion)
                        }, receiveValue: { (result) in
                            if let dictValues = result.toDictionary()["usersDatabase"] as? [String: Any] {
                                let userValuesDict = dictValues.filter { (dict) -> Bool in
                                    if dict.key == "type" {
                                        return false
                                    } else {
                                        return true
                                    }
                                }

                                if let jsonObject = try? JSONSerialization.data(withJSONObject: userValuesDict, options: .prettyPrinted) {
                                    if let user = try? JSONDecoder().decode(User.self, from: jsonObject) {
                                        users.append(user)
                                    }
                                }
                            }
                        })
                } catch {
                    promise(.failure(error))
                }
            } else {
                promise(.failure(localDbUsersError.couldNotGetReferences))
            }
        }
        return future.eraseToAnyPublisher()
    }

    func validateUserExist() -> AnyPublisher<Bool, Never> {
        let future = Future<Bool, Never> { promise in
            var users: [User] = []
            let query = QueryBuilder.select(SelectResult.all())
                .from(DataSource.database(self.database))
                .where(
                    Expression.property("type").equalTo(Expression.string(Constants.documentType))
                )

            do {
                if let result = try? query.execute() {
                    promise(.success(true))
                }else {
                    promise(.success(false))
                }
            } catch {
                print(error.localizedDescription)
                promise(.success(false))
            }
        }.eraseToAnyPublisher()
        return future
    }

}
