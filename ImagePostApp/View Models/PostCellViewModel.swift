//
//  PostCellViewModel.swift
//  ImagePostApp
//
//  Created by Joel Alcantara burgos on 6/3/21.
//

import Foundation

struct PostCellViewModel {
    var id = UUID().uuidString
    var userViewModel: UsersUIViewViewModel
    var picturesUrls: [String]
}

extension PostCellViewModel: Equatable, Hashable {
    static func == (lhs: PostCellViewModel, rhs: PostCellViewModel) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
