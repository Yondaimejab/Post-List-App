//
//  ArrayExtension.swift
//  ImagePostApp
//
//  Created by Joel Alcantara burgos on 7/3/21.
//

import Foundation

// this functions helps remove duplicated posts since
extension Array where Element: Equatable {
    func removeAnyDuplicates() -> [Element] {
        var result = [Element]()
        for value in self {
            if result.contains(value) == false {
                result.append(value)
            }
        }
        return result
    }
}
