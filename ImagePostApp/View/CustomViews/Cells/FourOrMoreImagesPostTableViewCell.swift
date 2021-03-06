//
//  FourOrMoreImagesPostTableViewCell.swift
//  ImagePostApp
//
//  Created by Joel Alcantara burgos on 6/3/21.
//

import UIKit
import Anchorage
import Combine
import SkeletonView

class FourOrMoreImagesPostTableViewCell: UITableViewCell {

    enum Constants {
        static let userViewHeight: CGFloat = 45.0
        static let mainImageHeight: CGFloat = 300.0
        static let otherImagesHeight: CGFloat = 130.0
    }

    static let cellIdentifier = "ThreeImagesPostTableViewCellID"

    // Properties
    var viewModel: PostCellViewModel?
    var imagesLoadingSubscriber = Set<AnyCancellable>()
    @Published private var loadedImages: Int = 0

    // Views
    var userView = PostUserView(frame: .zero)
    let mainContainerStackView = UIStackView()
    let mainPostImage = UIImageView()
    let scrollView = UIScrollView()
    let scrollViewContentStackView = UIStackView()

    func bindTo(viewModel: PostCellViewModel) {
        imagesLoadingSubscriber.removeAll()

        userView.configureView(for: viewModel.userViewModel)

        guard viewModel.picturesUrls.count > 3 else {
            var cellName = ""
            switch viewModel.picturesUrls.count {
            case 1:
                cellName = "OneImagePostTableViewCell"
            case 2:
                cellName = "TwoImagesPostTableViewCell"
            default:
                cellName = "ThreeImagesPostTableViewCell"
            }
            fatalError("=== Error dequeued wrong cell has you cell should have \(viewModel.picturesUrls.count)  use = \(cellName) ")
        }

        for index in 0..<viewModel.picturesUrls.count {

            let imageView = index == 0 ? mainPostImage : UIImageView()

            imageView.loadImageFrom(url: viewModel.picturesUrls[index])
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

        $loadedImages.sink { [weak self] (value) in
            guard let self = self else { return }
            if value >= viewModel.picturesUrls.count {
                self.scrollView.contentSize = self.scrollViewContentStackView.frame.size
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
        mainContainerStackView.axis = .vertical

        scrollViewContentStackView.spacing = 12
        scrollViewContentStackView.axis = .horizontal
    }

    private func buildInterface() {
        addSubview(userView)
        addSubview(mainContainerStackView)

        mainContainerStackView.addArrangedSubview(mainPostImage)
        mainContainerStackView.addArrangedSubview(scrollView)

        scrollView.addSubview(scrollViewContentStackView)
    }

    private func displayDefaultLayout() {
        userView.topAnchor == topAnchor
        userView.horizontalAnchors == horizontalAnchors
        userView.heightAnchor == Constants.userViewHeight

        mainContainerStackView.topAnchor == userView.bottomAnchor + 12
        mainContainerStackView.horizontalAnchors == horizontalAnchors
        mainContainerStackView.bottomAnchor == bottomAnchor

        mainPostImage.heightAnchor == Constants.mainImageHeight
        scrollView.heightAnchor == Constants.otherImagesHeight
        scrollViewContentStackView.edgeAnchors == scrollView.edgeAnchors

        scrollView.contentSize = scrollViewContentStackView.frame.size
    }
}
