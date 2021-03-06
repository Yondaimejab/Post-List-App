//
//  PostsPresenter.swift
//  ImagePostApp
//
//  Created by Joel Alcantara burgos on 6/3/21.
//

import Foundation
import Combine

class PostPresenter {
    // properties
    private var postProvider: PostProviding
    @Published var postList: [PostCellViewModel] = []

    init(postProvider: PostProviding = PostProvider.shared) {
        self.postProvider = postProvider
    }


}
