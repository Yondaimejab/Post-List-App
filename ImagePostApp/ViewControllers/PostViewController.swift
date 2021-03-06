//
//  PostViewController.swift
//  ImagePostApp
//
//  Created by Joel Alcantara burgos on 6/3/21.
//

import UIKit
import Combine

class PostViewController: UIViewController {
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

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    private func setupView() {
        postsTableView.separatorStyle = .none

        setupTableView()
    }

    private func setupTableView() {

        dataSource = PostDataSource(tableView: postsTableView, cellProvider: { (tableView, indexpath, viewModel) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: "asdad")
            return cell
        })

        postSubscriber = presenter.$postList
            .sink { [weak self] (postList) in
                guard let self = self else {return}
                self.updateDataSource(postList: postList)
            }
    }

    private func updateDataSource(postList: [PostCellViewModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<Sections, PostCellViewModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(postList, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)
    }

}
