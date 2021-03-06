//
//  PostUserView.swift
//  ImagePostApp
//
//  Created by Joel Alcantara burgos on 6/3/21.
//

import Foundation
import UIKit
import Anchorage
import Combine
import SkeletonView

class PostUserView: UIView {

    // Views
    let containerStackView = UIStackView()
    let profilePicture = UIImageView()
    let verticalUserInfoContainerView = UIStackView()
    let userNameLabel = UILabel()
    let userEmailLabel = UILabel()
    let dateLabel = UILabel()

    // Properties
    var imageLoadinSubscriber: Cancellable?

    init(frame: CGRect) {
        super.init(frame: frame)

        configure()
        buildInterface()
        displayDefaultLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init with coder not implemented")
    }

    private func configure() {
        containerStackView.axis = .horizontal
        containerStackView.spacing = 15

        verticalUserInfoContainerView.axis = .vertical
        verticalUserInfoContainerView.spacing = 8

        isSkeletonable = true
        containerStackView.isSkeletonable = true
        profilePicture.isSkeletonable = true
        verticalUserInfoContainerView.isSkeletonable = true
        userNameLabel.isSkeletonable = true
        userEmailLabel.isSkeletonable = true
        dateLabel.isSkeletonable = true

        showGradientSkeleton()
    }

    private func buildInterface() {
        addSubview(containerStackView)

        containerStackView.addArrangedSubview(profilePicture)
        containerStackView.addArrangedSubview(verticalUserInfoContainerView)
        containerStackView.addArrangedSubview(dateLabel)

        verticalUserInfoContainerView.addArrangedSubview(userNameLabel)
        verticalUserInfoContainerView.addArrangedSubview(userEmailLabel)
    }

    private func displayDefaultLayout() {
        containerStackView.edgeAnchors == edgeAnchors

        profilePicture.widthAnchor == 50
        dateLabel.widthAnchor == 30
    }

    func configureView(with user: UsersUIViewViewModel) {
        imageLoadinSubscriber = profilePicture.loadImageFrom(url: user.imageUrl)
            .sink(receiveCompletion: ( {_ in} ), receiveValue: { (imageLoaded) in
                if !imageLoaded {
                    self.profilePicture.image = UIImage(named: "user_placeholder")
                }
                self.hideSkeleton()
            })

        userNameLabel.text = user.name
        userEmailLabel.text = user.email
        dateLabel.text = user.date
    }
}
