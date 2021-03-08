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
    var imagePresenterDelegate: ImagePresenter?

    func configure(with viewModel: PostCellViewModel, delegete: ImagePresenter) {
        imagePresenterDelegate = delegete
        postMainImage.gestureRecognizers?.removeAll()
        userView.configureView(for: viewModel.userViewModel)

        guard let pictureUrl = viewModel.picturesUrls.first else {
            fatalError("== Error:  wrong cell dequeued viewModel has no picture URL ===")
        }

        imageLoadingSubscriber = postMainImage.loadImageFrom(url: pictureUrl)
            .sink(receiveCompletion: { (completion) in
                switch completion {
                case .failure(let error):
                    print("=== An Error has happend \(error.localizedDescription) ===")
                    self.postMainImage.image = UIImage(named: "user_placeholder")
                    self.hideSkeleton()
                case .finished:
                    print("Success")
                }
            }, receiveValue: {[weak self] (imageLoaded) in
                guard let self = self else {return}
                if !imageLoaded {
                    self.postMainImage.image = UIImage(named: "user_placeholder")
                }
                self.hideSkeleton()
            })

        postMainImage.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(gesture:)))
        postMainImage.addGestureRecognizer(tapGesture)
    }

    @objc func imageTapped(gesture: UITapGestureRecognizer) {
        if let image = postMainImage.image {
            imagePresenterDelegate?.presentImageWithBlur(for: image)
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        configure()
        buildInterface()
        displayDefaultLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Private
    private func configure() {
        isSkeletonable = true
        postMainImage.isSkeletonable = true
        postMainImage.contentMode = .scaleToFill

        self.showAnimatedGradientSkeleton()
    }

    private func buildInterface() {
        addSubview(userView)
        addSubview(postMainImage)
    }

    private func displayDefaultLayout() {
        userView.topAnchor == topAnchor
        userView.horizontalAnchors == horizontalAnchors
        userView.heightAnchor == Constants.userViewHeight

        postMainImage.topAnchor == userView.bottomAnchor + 12
        postMainImage.heightAnchor == Constants.imageHeight
        postMainImage.horizontalAnchors == horizontalAnchors
        postMainImage.bottomAnchor == bottomAnchor - 10
    }

}
