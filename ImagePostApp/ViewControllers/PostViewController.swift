//
//  PostViewController.swift
//  ImagePostApp
//
//  Created by Joel Alcantara burgos on 6/3/21.
//

import UIKit
import Combine
import Anchorage

protocol ImagePresenter: AnyObject {
    func presentImageWithBlur(for image: UIImage)
    func presentImageViewWithBlur(_ imageView: UIImageView)
}

class PostViewController: UIViewController, ImagePresenter {
    enum Sections {
        case main
    }

    typealias PostDataSource = UITableViewDiffableDataSource<Sections, PostCellViewModel>

    // Outlets
    @IBOutlet weak var postsTableView: UITableView!

    // properties
    var dataSource: PostDataSource!
    var presenter = PostPresenter()
    var postSubscriber: AnyCancellable?
    var requestSubscriber: AnyCancellable?
    var viewForPresentingImages = UIView()
    let imageViewToPresent = UIImageView()
    let refreshControl = UIRefreshControl()
    var refreshControlStartSubscriber: AnyCancellable?
    var refreshRequestSubscriber: AnyCancellable?
    var requestInitiated = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        postSubscriber = presenter.$postList
            .sink { [weak self] (postList) in
                guard let self = self, postList.count > 0 else {return}
                self.updateDataSource(postList: postList)
            }
        requestSubscriber = presenter.getNextPosts()
            .sink(receiveCompletion: { (completion) in
                print(completion)
            }, receiveValue: { (didLoadPosts) in
                print(didLoadPosts)
            })
    }

    private func setupView() {
        postsTableView.separatorStyle = .none
        postsTableView.rowHeight = UITableView.automaticDimension
        postsTableView.separatorInset.top = 10
        postsTableView.refreshControl = refreshControl
        setupTableView()

        self.view.addSubview(viewForPresentingImages)
        viewForPresentingImages.addSubview(imageViewToPresent)
        viewForPresentingImages.widthAnchor == self.view.widthAnchor
        viewForPresentingImages.heightAnchor == self.view.heightAnchor

        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(closeImagePresentation(gesture:)))
        swipeGesture.direction = .down
        viewForPresentingImages.addGestureRecognizer(swipeGesture)
        viewForPresentingImages.isHidden = true
        
        let action = #selector(pinchToZoom(_:))
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: action)
        imageViewToPresent.addGestureRecognizer(pinchGesture)
        imageViewToPresent.isUserInteractionEnabled = true
    }

    @objc func pinchToZoom(_ gesture: UIPinchGestureRecognizer) {
        guard let imageView = gesture.view as? UIImageView else { return }
        imageView.transform = .identity.scaledBy(x: gesture.scale, y: gesture.scale)
    }
    
    private func setupTableView() {
        postsTableView.register(OneImagePostTableViewCell.self, forCellReuseIdentifier: OneImagePostTableViewCell.cellIdentifier)
        postsTableView.register(TwoImagesPostTableViewCell.self, forCellReuseIdentifier: TwoImagesPostTableViewCell.cellIdentifier)
        postsTableView.register(ThreeImagesPostTableViewCell.self, forCellReuseIdentifier: ThreeImagesPostTableViewCell.cellIdentifier)
        postsTableView.register(FourOrMoreImagesPostTableViewCell.self, forCellReuseIdentifier: FourOrMoreImagesPostTableViewCell.cellIdentifier)
        postsTableView.delegate = self
        dataSource = PostDataSource(tableView: postsTableView, cellProvider: { (tableView, indexPath, viewModel) -> UITableViewCell? in
            var cell: UITableViewCell?
            switch viewModel.picturesUrls.count {
            case 1:
                let identifier = OneImagePostTableViewCell.cellIdentifier
                cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
                (cell as? OneImagePostTableViewCell)?.configure(with: viewModel, delegate: self)
            case 2:
                let identifier = TwoImagesPostTableViewCell.cellIdentifier
                cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
                (cell as? TwoImagesPostTableViewCell)?.configure(with: viewModel, delegate: self)
            case 3:
                let identifier = ThreeImagesPostTableViewCell.cellIdentifier
                cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
                (cell as? ThreeImagesPostTableViewCell)?.configure(with: viewModel, delegate: self)
            default:
                let identifier = FourOrMoreImagesPostTableViewCell.cellIdentifier
                cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
                (cell as? FourOrMoreImagesPostTableViewCell)?.configureView(with: viewModel, delegate: self)
            }
            return cell
        })
    }

    private func updateDataSource(postList: [PostCellViewModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<Sections, PostCellViewModel>()
        if dataSource.snapshot().numberOfSections <= 0 {
            snapshot.appendSections([.main])
            snapshot.appendItems(postList, toSection: .main)
        } else {
            snapshot = dataSource.snapshot()
            let oldItems = dataSource.snapshot().itemIdentifiers.filter({ postList.contains($0) })
            if oldItems.count > 0 { snapshot.reloadItems(oldItems) }
            let newItems = dataSource.snapshot().itemIdentifiers.filter({ !postList.contains($0) })
            if newItems.count > 0 {  snapshot.appendItems(newItems) }
        }
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    @objc func closeImagePresentation(gesture: UISwipeGestureRecognizer) {
        if gesture.state == .ended {
            switch gesture.direction {
            case .down:
                UIView.animate(withDuration: 2.0) {
                    self.viewForPresentingImages.layer.opacity = 0.0
                    self.viewForPresentingImages.isHidden = true
                }
            default:
                break
            }
        }
    }
    
    // Delegate
    func presentImageWithBlur(for image: UIImage) {
        view.bringSubviewToFront(viewForPresentingImages)
        viewForPresentingImages.isUserInteractionEnabled = true
        imageViewToPresent.image = image
        viewForPresentingImages.isHidden = false
        viewForPresentingImages.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        imageViewToPresent.isHidden = false
        imageViewToPresent.layer.opacity = 0.7
        imageViewToPresent.clipsToBounds = true
        imageViewToPresent.layer.maskedCorners = .allCorners
        imageViewToPresent.layer.cornerRadius = 12
        viewForPresentingImages.layer.opacity = 0.5
        self.imageViewToPresent.transform = .identity.scaledBy(x: 0.3, y: 0.3)
        UIView.animate(withDuration: 1.0, animations: {
            self.imageViewToPresent.layer.opacity = 1.0
            self.viewForPresentingImages.layer.opacity = 1.0
            UIView.animate(withDuration: 0.5, animations: {
                self.imageViewToPresent.transform = .identity
            })
        })
    }
    
    func presentImageViewWithBlur(_ imageView: UIImageView) {
        view.bringSubviewToFront(viewForPresentingImages)
        imageViewToPresent.removeConstraints(imageViewToPresent.constraints)
        viewForPresentingImages.isUserInteractionEnabled = true
        imageViewToPresent.image = imageView.image
        let oldOrigin = imageView.originInLastSuperView
        imageViewToPresent.frame = CGRect(origin: oldOrigin, size: imageView.bounds.size)
        viewForPresentingImages.isHidden = false
        viewForPresentingImages.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        imageViewToPresent.isHidden = false
        imageViewToPresent.layer.opacity = 0.7
        imageViewToPresent.clipsToBounds = true
        imageViewToPresent.layer.maskedCorners = .allCorners
        imageViewToPresent.layer.cornerRadius = 12
        viewForPresentingImages.layer.opacity = 0.5
        let newOrigin = CGPoint(x: view.frame.width * 0.1, y: view.frame.height * 0.25)
        let newSize = CGSize(width: view.bounds.width * 0.8, height: view.bounds.height / 2)
        UIView.animate(withDuration: 0.5, animations: {
            self.imageViewToPresent.layer.opacity = 1.0
            self.viewForPresentingImages.layer.opacity = 1.0
        }, completion: { _ in
            UIView.animate(withDuration: 2, animations: {
                self.imageViewToPresent.frame = CGRect(origin: newOrigin, size: newSize)
            })
        })
    }
}

extension PostViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentYOffset = scrollView.contentOffset.y
        if contentYOffset < -100 {
            if !requestInitiated {
                requestInitiated = true
                self.refreshRequestSubscriber = self.presenter.refreshPostList()
                    .sink(receiveCompletion: { (completion) in
                        switch completion {
                        case .failure(let error): print(error.localizedDescription)
                        case .finished: print("Success")
                        }
                        self.requestInitiated = false
                    }, receiveValue: { (_) in
                        self.requestInitiated = false
                        self.postsTableView.refreshControl?.endRefreshing()
                    })
            }
        }
    }
}


