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

    enum Sections {
        case main
    }

    typealias ImagesDataSource = UICollectionViewDiffableDataSource<Sections, UIImageView>

    enum Constants {
        static let userViewHeight: CGFloat = 45.0
        static let mainImageHeight: CGFloat = 300.0
        static let otherImagesHeight: CGFloat = 130.0
        static let cellSize = CGSize(width: 130.0, height: 80.0)
    }

    static let cellIdentifier = "FourImagesPostTableViewCellID"

    // Properties
    var viewModel: PostCellViewModel?
    var imagesLoadingSubscriber = Set<AnyCancellable>()
    @Published private var loadedImages: Int = 0

    // Views
    var userView = PostUserView(frame: .zero)
    let mainContainerStackView = UIStackView()
    var mainPostImage = UIImageView()
    let collectionView = UICollectionView(frame: CGRect(origin: .zero, size: CGSize(width: 1000, height: 130)), collectionViewLayout: UICollectionViewLayout())
    var collectionViewLayout = UICollectionViewFlowLayout()
    var imagePresenterDelegate: ImagePresenter?
    var containerForCollectionView = UIView()
    var imageList: [UIImageView] = []

    func configureView(with viewModel: PostCellViewModel, delegate: ImagePresenter) {
        imagePresenterDelegate = delegate
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

        guard let firsImageUrl = viewModel.picturesUrls.first else {return}
        mainPostImage.loadImageFrom(url: firsImageUrl)
            .sink(receiveCompletion: {[weak self] (completion) in
                switch completion {
                case .failure(let error):
                    print("=== An Error has happend \(error.localizedDescription) ===")
                    self?.mainPostImage.image = UIImage(named: "image_placeholder")
                    self?.loadedImages += 1
                case .finished:
                    print("Success")
                }
            }, receiveValue: { [weak self] (imageLoaded) in
                guard let self = self else {return}
                if !imageLoaded {
                    self.mainPostImage.image = UIImage(named: "image_placeholder")
                }
                self.loadedImages += 1
            }).store(in: &imagesLoadingSubscriber)


        for index in 1..<viewModel.picturesUrls.count {

            let imageView = UIImageView()

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

            imageList.append(imageView)
        }

        $loadedImages.receive(on: DispatchQueue.main).sink { [weak self] (value) in
            guard let self = self else { return }
            if value == viewModel.picturesUrls.count {
                self.collectionView.contentSize = CGSize(width: 1000, height: 130)
                self.collectionView.reloadData()
                self.hideSkeleton()
            }
        }.store(in: &imagesLoadingSubscriber)
        
    }

    @objc func imageTapped(gesture: UITapGestureRecognizer) {
        guard let imageView = gesture.view as? UIImageView else {return}
        guard  let image = imageView.image else { return }
        imagePresenterDelegate?.presentImageWithBlur(for: image)
    }

    override func prepareForReuse() {
        loadedImages = 0
        imageList = []
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        collectionView.dataSource = self
        collectionView.delegate = self
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
        mainContainerStackView.axis = .vertical

        mainPostImage.contentMode = .scaleToFill
        collectionView.backgroundColor = .white
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(gesture:)))
        mainPostImage.addGestureRecognizer(tapGesture)
        mainPostImage.isUserInteractionEnabled = true
        collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: ImageCollectionViewCell.Constants.identifier)
        collectionView.isUserInteractionEnabled = true
        collectionView.isScrollEnabled = true
        collectionView.clipsToBounds = false
        collectionViewLayout.estimatedItemSize = Constants.cellSize
        collectionViewLayout.scrollDirection = .horizontal
        collectionViewLayout.minimumInteritemSpacing = 12
        collectionView.collectionViewLayout = collectionViewLayout
    }

    private func buildInterface() {
        contentView.addSubview(userView)
        contentView.addSubview(mainContainerStackView)

        mainContainerStackView.addArrangedSubview(mainPostImage)
        mainContainerStackView.addArrangedSubview(containerForCollectionView)
        containerForCollectionView.addSubview(collectionView)
    }

    private func displayDefaultLayout() {
        userView.topAnchor == contentView.topAnchor
        userView.horizontalAnchors == contentView.horizontalAnchors
        userView.heightAnchor == Constants.userViewHeight

        mainContainerStackView.topAnchor == userView.bottomAnchor + 12
        mainContainerStackView.leadingAnchor == contentView.leadingAnchor
        mainContainerStackView.trailingAnchor  == contentView.trailingAnchor
        mainContainerStackView.bottomAnchor == contentView.bottomAnchor - 10
        mainContainerStackView.heightAnchor == Constants.mainImageHeight + 12.0 + Constants.otherImagesHeight
        mainPostImage.heightAnchor == Constants.mainImageHeight
        collectionView.contentSize = CGSize(width: 1000, height: 130)
    }
}

extension FourOrMoreImagesPostTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.Constants.identifier, for: indexPath)
        if let imageCell = cell as? ImageCollectionViewCell {
            imageCell.configureView(with: self.imageList[indexPath.row].image, delegate: imagePresenterDelegate)
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return Constants.cellSize
    }
}
