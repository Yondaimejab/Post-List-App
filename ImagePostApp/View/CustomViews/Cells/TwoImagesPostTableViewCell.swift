//
//  TwoImagesPostTableViewCell.swift
//  ImagePostApp
//
//  Created by Joel Alcantara burgos on 6/3/21.
//

import UIKit
import Anchorage
import Combine
import SkeletonView

class TwoImagesPostTableViewCell: UITableViewCell {

    enum Constants {
        static let userViewHeight: CGFloat = 45.0
        static let imageHeight: CGFloat = 300 * 0.5
    }

    static let cellIdentifier = "TwoImagesPostTableViewCellID"

    // Properties
    var viewModel: PostCellViewModel?
    var imagesLoadingSubscriber = Set<AnyCancellable>()
    @Published private var loadedImages: Int = 0
    // Views
    var userView = PostUserView(frame: .zero)
    var mainContainerStackView = UIStackView()
    var leftImageView = UIImageView()
    var rightImageView = UIImageView()

    var imagePresenterDelegate: ImagePresenter?

    func configure(with viewModel: PostCellViewModel, delegate: ImagePresenter) {
        imagePresenterDelegate = delegate
        userView.configureView(for: viewModel.userViewModel)
        viewModel.picturesUrls.enumerated().forEach { index, item in
            var imageView: UIImageView
            let isStartIndex = index == viewModel.picturesUrls.startIndex
            let isEndIndex = index == (viewModel.picturesUrls.endIndex - 1)
            guard isStartIndex || isEndIndex else {
                fatalError("=== Error dequeued wrong cell use = \(Self.cellIdentifier) ===")
            }
            imageView = isEndIndex ? leftImageView : rightImageView
            imageView.loadImageFrom(url: item)
                .sink(receiveCompletion: { (completion) in
                    switch completion {
                    case .failure(let error): print("=== \(error.localizedDescription) ===")
                    case .finished:print("Success")
                    }
                }, receiveValue: { [weak self] (imageLoaded) in
                    guard let self = self else {return}
                    guard imageLoaded else { return self.leftImageView.image = .placeholder }
                    self.loadedImages += 1
                }).store(in: &imagesLoadingSubscriber)
        }
        $loadedImages.sink { if $0 >= 2 { self.hideSkeleton() } }.store(in: &imagesLoadingSubscriber)
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
        mainContainerStackView.isSkeletonable = true
        leftImageView.isSkeletonable = true
        rightImageView.isSkeletonable = true
        mainContainerStackView.spacing = 12
        mainContainerStackView.axis = .horizontal
        mainContainerStackView.distribution = .fillEqually
        leftImageView.contentMode = .scaleToFill
        leftImageView.clipsToBounds = true
        leftImageView.layer.maskedCorners = .allCorners
        leftImageView.layer.cornerRadius = 12.0
        rightImageView.contentMode = .scaleToFill
        rightImageView.clipsToBounds = true
        rightImageView.layer.maskedCorners = .allCorners
        rightImageView.layer.cornerRadius = 12.0
        let action = #selector(imageTapped(gesture:))
        leftImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: action))
        rightImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: action))
        leftImageView.isUserInteractionEnabled = true
        rightImageView.isUserInteractionEnabled = true
    }

    private func buildInterface() {
        contentView.addSubview(userView)
        contentView.addSubview(mainContainerStackView)
        mainContainerStackView.addArrangedSubview(leftImageView)
        mainContainerStackView.addArrangedSubview(rightImageView)
    }

    private func displayDefaultLayout() {
        userView.topAnchor == contentView.topAnchor
        userView.horizontalAnchors == contentView.horizontalAnchors
        userView.heightAnchor == Constants.userViewHeight
        mainContainerStackView.topAnchor == userView.bottomAnchor + 12
        mainContainerStackView.heightAnchor == Constants.imageHeight
        mainContainerStackView.leadingAnchor == contentView.leadingAnchor + 12
        mainContainerStackView.trailingAnchor == contentView.trailingAnchor
        mainContainerStackView.bottomAnchor == contentView.bottomAnchor - 10
    }
    
    @objc func imageTapped(gesture: UITapGestureRecognizer) {
        guard let imageView = gesture.view as? UIImageView else { return }
        imagePresenterDelegate?.presentImageViewWithBlur(imageView)
//        guard let image = imageView.image else { return }
//        imagePresenterDelegate?.presentImageWithBlur(for: image)
    }
}
