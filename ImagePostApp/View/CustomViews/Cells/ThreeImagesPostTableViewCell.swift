//
//  ThreeImagesPostTableViewCell.swift
//  ImagePostApp
//
//  Created by Joel Alcantara burgos on 6/3/21.
//

import UIKit
import SkeletonView
import Combine
import Anchorage

class ThreeImagesPostTableViewCell: UITableViewCell {
    static let cellIdentifier = "ThreeImagesPostTableViewCellID"

    enum Constants {
        static let userViewHeight: CGFloat = 45.0
        static let mainImageHeight: CGFloat = 300
        static let otherImagesHeight: CGFloat = 300 * 0.4
    }

    // Properties
    var viewModel: PostCellViewModel?
    var imagesLoadingSubscriber = Set<AnyCancellable>()
    @Published private var loadedImages: Int = 0

    // Views
    var userView = PostUserView(frame: .zero)
    var mainContainerStackView = UIStackView()
    var mainPostImage = UIImageView()
    var secondaryContainerStackView = UIStackView()
    var leftImageView = UIImageView()
    var rightImageView = UIImageView()

    func configure(with viewModel: PostCellViewModel) {
        imagesLoadingSubscriber.removeAll()

        userView.configureView(for: viewModel.userViewModel)

        guard viewModel.picturesUrls.count == 3 else {
            var cellName = ""
            switch viewModel.picturesUrls.count {
            case 1:
                cellName = "OneImagePostTableViewCell"
            case 2:
                cellName = "TwoImagesPostTableViewCell"
            default:
                cellName = "FourOrMoreImagesPostTableViewCell"
            }
            fatalError("=== Error dequeued wrong cell has you cell should have \(viewModel.picturesUrls.count)  use = \(cellName) ")
        }

        var newDict: [Int: UIImageView] = [:]
        newDict[0] = mainPostImage
        newDict[1] = leftImageView
        newDict[2] = rightImageView

        for (key, imageView) in newDict {
            imageView.loadImageFrom(url: viewModel.picturesUrls[key])
                .sink(receiveCompletion: {[weak self] (completion) in
                    switch completion {
                    case .failure(let error):
                        print("=== An Error has happend \(error.localizedDescription) ===")
                        imageView.image = UIImage(named: "image_placeholder")
                        self?.loadedImages += 1
                    case .finished:
                        print("Success")
                    }
                }, receiveValue: { [weak self] (imageLoaded) in
                    guard let self = self else {return}
                    if !imageLoaded {
                        imageView.image = UIImage(named: "image_placeholder")
                    }
                    self.loadedImages += 1
                }).store(in: &imagesLoadingSubscriber)
        }

        $loadedImages.sink { (value) in
            if value >= 3 {
                self.hideSkeleton()
            }
        }.store(in: &imagesLoadingSubscriber)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Private
    private func configure() {
        mainContainerStackView.spacing = 12
        secondaryContainerStackView.spacing = 12

        isSkeletonable = true
        mainContainerStackView.isSkeletonable = true
        leftImageView.isSkeletonable = true
        rightImageView.isSkeletonable = true
        self.showGradientSkeleton()
    }

    private func buildInterface() {
        addSubview(userView)
        addSubview(mainContainerStackView)

        mainContainerStackView.addArrangedSubview(mainPostImage)
        mainContainerStackView.addArrangedSubview(secondaryContainerStackView)
        secondaryContainerStackView.addArrangedSubview(leftImageView)
        secondaryContainerStackView.addArrangedSubview(rightImageView)
    }

    private func displayDefaultLayout() {
        userView.topAnchor == topAnchor
        userView.horizontalAnchors == horizontalAnchors
        userView.heightAnchor == Constants.userViewHeight

        mainContainerStackView.topAnchor == userView.bottomAnchor + 12
        mainContainerStackView.horizontalAnchors == horizontalAnchors
        mainContainerStackView.bottomAnchor == bottomAnchor

        mainPostImage.heightAnchor == Constants.mainImageHeight
        secondaryContainerStackView.heightAnchor == Constants.otherImagesHeight
    }
}
