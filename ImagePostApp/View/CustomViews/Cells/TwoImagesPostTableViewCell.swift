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

        for (index, item) in viewModel.picturesUrls.enumerated() {
            if index == viewModel.picturesUrls.startIndex {
                leftImageView.loadImageFrom(url: item)
                    .sink(receiveCompletion: { (completion) in
                        switch completion {
                        case .failure(let error):
                            print("=== An Error has happend \(error.localizedDescription) ===")
                            self.leftImageView.image = UIImage(named: "image_placeholder")
                            self.loadedImages += 1
                        case .finished:
                            print("Success")
                        }
                    }, receiveValue: {[weak self] (imageLoaded) in
                        guard let self = self else {return}
                        if !imageLoaded {
                            self.leftImageView.image = UIImage(named: "image_placeholder")
                        }
                        self.loadedImages += 1
                    }).store(in: &imagesLoadingSubscriber)
            } else if index == (viewModel.picturesUrls.endIndex - 1) {
                rightImageView.loadImageFrom(url: item)
                    .sink(receiveCompletion: { (completion) in
                        switch completion {
                        case .failure(let error):
                            print("=== An Error has happend \(error.localizedDescription) ===")
                            self.rightImageView.image = UIImage(named: "image_placeholder")
                            self.loadedImages += 1
                        case .finished:
                            print("Success")
                        }
                    }, receiveValue: {[weak self] (imageLoaded) in
                        guard let self = self else {return}
                        if !imageLoaded {
                            self.rightImageView.image = UIImage(named: "image_placeholder")
                        }
                        self.loadedImages += 1
                    }).store(in: &imagesLoadingSubscriber)
            } else {
                var cellName = ""
                switch viewModel.picturesUrls.count {
                case 1:
                    cellName = "OneImagePostTableViewCell"
                case 3:
                    cellName = "ThreeImagesPostTableViewCell"
                default:
                    cellName = "FourOrMoreImagesPostTableViewCell"
                }
                fatalError("=== Error dequeued wrong cell has you cell should have \(viewModel.picturesUrls.count)  use = \(cellName) ")
            }
        }

        $loadedImages.sink { (value) in
            if value >= 2 {
                self.hideSkeleton()
            }
        }.store(in: &imagesLoadingSubscriber)
    }

    @objc func imageTapped(gesture: UITapGestureRecognizer) {
        guard let imageView = gesture.view as? UIImageView else {return}
        guard  let image = imageView.image else { return }
        imagePresenterDelegate?.presentImageWithBlur(for: image)
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
        mainContainerStackView.spacing = 12
        mainContainerStackView.axis = .horizontal
        mainContainerStackView.distribution = .fillEqually

        leftImageView.contentMode = .scaleToFill
        rightImageView.contentMode = .scaleToFill
        leftImageView.isUserInteractionEnabled = true
        rightImageView.isUserInteractionEnabled = true

        isSkeletonable = true
        mainContainerStackView.isSkeletonable = true
        leftImageView.isSkeletonable = true
        rightImageView.isSkeletonable = true
        self.showAnimatedGradientSkeleton()


        let leftImagetapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(gesture:)))
        let rightImagetapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(gesture:)))
        leftImageView.addGestureRecognizer(leftImagetapGesture)
        rightImageView.addGestureRecognizer(rightImagetapGesture)
    }

    private func buildInterface() {
        addSubview(userView)
        addSubview(mainContainerStackView)

        mainContainerStackView.addArrangedSubview(leftImageView)
        mainContainerStackView.addArrangedSubview(rightImageView)
    }

    private func displayDefaultLayout() {
        userView.topAnchor == topAnchor
        userView.horizontalAnchors == horizontalAnchors
        userView.heightAnchor == Constants.userViewHeight

        mainContainerStackView.topAnchor == userView.bottomAnchor + 12
        mainContainerStackView.heightAnchor == Constants.imageHeight
        mainContainerStackView.horizontalAnchors == horizontalAnchors
        mainContainerStackView.bottomAnchor == bottomAnchor - 10
    }
}
