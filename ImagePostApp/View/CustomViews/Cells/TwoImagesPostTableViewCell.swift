//
//  TwoImagesPostTableViewCell.swift
//  ImagePostApp
//
//  Created by Joel Alcantara burgos on 6/3/21.
//

import UIKit

class TwoImagesPostTableViewCell: UITableViewCell {
    static let cellIdentifier = "TwoImagesPostTableViewCellID"

    // Properties
    var viewModel: PostCellViewModel?
    // Views
    lazy var userView = PostUserView(frame: .zero)

    func bindTo(viewModel: PostCellViewModel) {

    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // Private
    private func configure() {

    }

    private func buildInterface() {

    }

    private func displayDefaultLayout() {

    }
}
