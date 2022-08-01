//
//  PostTableViewCell.swift
//  ImagePostApp
//
//  Created by Joel Alcantara burgos on 6/3/21.
//

import UIKit
import Anchorage
import Combine
import SkeletonView

class OneImagePostTableViewCell: UITableViewCell {

    enum Constants {
        static let userViewHeight: CGFloat = 45.0
        static let imageHeight: CGFloat = 300.0
    }

    static let cellIdentifier = "OneImagePostTableViewCellID"

    // Properties
    var viewModel: PostCellViewModel?
    var imageLoadingSubscriber: AnyCancellable?

    // Views
    var userView = PostUserView(frame: .zero)
    var postMainImage = UIImageView()
    weak var imagePresenterDelegate: ImagePresenter?

    func configure(with viewModel: PostCellViewModel, delegate: ImagePresenter) {
        imagePresenterDelegate = delegate
        userView.configureView(for: viewModel.userViewModel)
        guard let pictureUrl = viewModel.picturesUrls.first else {
            fatalError("== Error: wrong cell dequeued viewModel has no picture URL ===")
        }
        imageLoadingSubscriber = postMainImage.loadImageFrom(url: pictureUrl)
            .sink(receiveCompletion: { (completion) in
                switch completion {
                case .failure(let error): print("=== \(error.localizedDescription) ===")
                case .finished: print("Success")
                }
            }, receiveValue: { [weak self] (imageLoaded) in
                guard let self = self else { return }
                guard imageLoaded else { return self.postMainImage.image = .placeholder }
                self.hideSkeleton()
            })
    }

    @objc func imageTapped(gesture: UITapGestureRecognizer) {
        imagePresenterDelegate?.presentImageViewWithBlur(postMainImage)
        /*
        guard let image = postMainImage.image else { return }
        imagePresenterDelegate?.presentImageWithBlur(for: image)*/
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
        buildInterface()
        displayDefaultLayout()
        showAnimatedGradientSkeleton()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Private
    private func configure() {
        isSkeletonable = true
        postMainImage.isSkeletonable = true
        postMainImage.contentMode = .scaleToFill
        postMainImage.clipsToBounds = true
        postMainImage.layer.maskedCorners = .allCorners
        postMainImage.layer.cornerRadius = 12.0
        let gesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(gesture:)))
        postMainImage.addGestureRecognizer(gesture)
        postMainImage.isUserInteractionEnabled = true
    }

    private func buildInterface() {
        contentView.addSubview(userView)
        contentView.addSubview(postMainImage)
        bringSubviewToFront(postMainImage)
    }

    private func displayDefaultLayout() {
        userView.topAnchor == contentView.topAnchor
        userView.horizontalAnchors == contentView.horizontalAnchors
        userView.heightAnchor == Constants.userViewHeight
        postMainImage.topAnchor == userView.bottomAnchor + 12
        postMainImage.heightAnchor == Constants.imageHeight
        postMainImage.leadingAnchor == contentView.leadingAnchor + 12
        postMainImage.trailingAnchor == contentView.trailingAnchor
        postMainImage.bottomAnchor == contentView.bottomAnchor - 12
    }

}
