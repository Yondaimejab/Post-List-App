//
//  PostViewController.swift
//  ImagePostApp
//
//  Created by Joel Alcantara burgos on 6/3/21.
//

import UIKit
import Combine
import Anchorage

protocol ImagePresenter {
    func presentImageWithBlur(for image: UIImage)
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
    var refreshControlStartSubcriber: AnyCancellable?
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
        imageViewToPresent.centerAnchors == viewForPresentingImages.centerAnchors
        imageViewToPresent.widthAnchor == viewForPresentingImages.widthAnchor * 0.75
        imageViewToPresent.heightAnchor == viewForPresentingImages.heightAnchor * 0.5

        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(closeImagePresentation(gesture:)))
        swipeGesture.direction = .down
        viewForPresentingImages.addGestureRecognizer(swipeGesture)

        viewForPresentingImages.isHidden = true
    }

    private func setupTableView() {
        postsTableView.register(OneImagePostTableViewCell.self, forCellReuseIdentifier: OneImagePostTableViewCell.cellIdentifier)
        postsTableView.register(TwoImagesPostTableViewCell.self, forCellReuseIdentifier: TwoImagesPostTableViewCell.cellIdentifier)
        postsTableView.register(ThreeImagesPostTableViewCell.self, forCellReuseIdentifier: ThreeImagesPostTableViewCell.cellIdentifier)
        postsTableView.register(FourOrMoreImagesPostTableViewCell.self, forCellReuseIdentifier: FourOrMoreImagesPostTableViewCell.cellIdentifier)
        postsTableView.delegate = self

        dataSource = PostDataSource(tableView: postsTableView, cellProvider: { (tableView, indexpath, viewModel) -> UITableViewCell? in
            var cell: UITableViewCell?
            switch viewModel.picturesUrls.count {
            case 1:
                cell = tableView.dequeueReusableCell(withIdentifier: OneImagePostTableViewCell.cellIdentifier, for: indexpath)
                if let oneImageCell = cell as? OneImagePostTableViewCell {
                    oneImageCell.configure(with: viewModel, delegete: self)
                }
            case 2:
                cell = tableView.dequeueReusableCell(withIdentifier: TwoImagesPostTableViewCell.cellIdentifier, for: indexpath)
                if let twoImagesCell = cell as? TwoImagesPostTableViewCell {
                    twoImagesCell.configure(with: viewModel, delegate: self)
                }
            case 3:
                cell = tableView.dequeueReusableCell(withIdentifier: ThreeImagesPostTableViewCell.cellIdentifier, for: indexpath)
                if let threeImagesCell = cell as? ThreeImagesPostTableViewCell {
                    threeImagesCell.configure(with: viewModel, delegate: self)
                }
            default:
                cell = tableView.dequeueReusableCell(withIdentifier: FourOrMoreImagesPostTableViewCell.cellIdentifier, for: indexpath)
                if let fourOrMoreImagesCell = cell as? FourOrMoreImagesPostTableViewCell {
                    fourOrMoreImagesCell.configureView(with: viewModel, delegate: self)
                }
            }
            return cell
        })
    }

    private func updateDataSource(postList: [PostCellViewModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<Sections, PostCellViewModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(postList, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    func presentImageWithBlur(for image: UIImage) {
        self.view.bringSubviewToFront(viewForPresentingImages)
        viewForPresentingImages.isUserInteractionEnabled = true
        imageViewToPresent.image = image
        self.viewForPresentingImages.isHidden = false
        viewForPresentingImages.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        self.imageViewToPresent.isHidden = false
        self.imageViewToPresent.layer.opacity = 0.0
        self.viewForPresentingImages.layer.opacity = 0.0

        UIView.animate(withDuration: 3.0) {
            self.imageViewToPresent.layer.opacity = 1.0
            self.viewForPresentingImages.layer.opacity = 1.0
        }
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
}

extension PostViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentYoffset = scrollView.contentOffset.y

        if contentYoffset < -100 {
            if !requestInitiated {
                requestInitiated = true
                self.refreshRequestSubscriber = self.presenter.refreshPostList()
                    .sink(receiveCompletion: { (completion) in
                        switch completion {
                        case .failure(let error):
                            // presentAlert if failed
                            print(error.localizedDescription)
                        case .finished:
                            print("Success")
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


